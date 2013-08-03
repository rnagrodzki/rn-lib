/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
 * A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/
package rnlib.net.amf
{
	import rnlib.interfaces.IDisposable;
	import rnlib.net.cache.rules.CacheRuleConstants;

	public class AMFRequest implements IDisposable
	{
		protected var _uid:int;

		public function AMFRequest(id:int)
		{
			_uid = id;
		}

		public function get uid():int
		{
			return _uid;
		}

		internal var extraResult:Array;

		/**
		 * Pass additional params on server response
		 * @param rest
		 * @return
		 */
		public function setExtraResultParams(...rest):AMFRequest
		{
			extraResult = rest;
			return this;
		}

		internal var extraFault:Array;

		/**
		 * Pass additional params on server response
		 * @param rest
		 * @return
		 */
		public function setExtraFaultParams(...rest):AMFRequest
		{
			extraFault = rest;
			return this;
		}

		/**
		 * Pass additional params on server response to both handlers
		 * @param rest
		 * @return
		 */
		public function setExtraParams(...rest):AMFRequest
		{
			extraResult = rest;
			extraFault = rest;
			return this;
		}

		internal var requestSend:Boolean = false;

		/**
		 * Is method already executed
		 */
		public function get called():Boolean
		{
			return requestSend;
		}

		internal var _priority:int = 1;
		internal var updateQueue:Function;

		internal var cacheID:Object;
		internal var cacheStorageTime:int;
		internal var cacheTrigger:String = CacheRuleConstants.POLICY_NEVER;

		/**
		 * Update cache property
		 * @param id Cache ID for this request
		 * @param storageTime Storage time
		 * @return
		 */
		public function setCacheID(id:Object, storageTime:int = -1):AMFRequest
		{
			cacheID = id;
			cacheStorageTime = storageTime;
			return this;
		}

		/**
		 * Set specific priority of request.
		 * <p>Change can be affected only before added to request queue.
		 * It means that in next frame change can't be made.</p>
		 * @param priority
		 * @return
		 */
		public function setPriority(priority:int = 1):AMFRequest
		{
			_priority = priority;
			updateQueue(priority);
			return this;
		}

		public function get priority():int
		{
			return _priority;
		}

		//---------------------------------------------------------------
		//              <------ IDisposable ------>
		//---------------------------------------------------------------

		public function dispose():void
		{
			extraResult = null;
			extraFault = null;
			updateQueue = null;
		}
	}
}
