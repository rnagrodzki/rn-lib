/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
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
package rnlib.net.service
{
	import rnlib.interfaces.IDisposable;
	import rnlib.net.cache.rules.CacheRuleConstants;
	import rnlib.rnlib;

	use namespace rnlib;

	/**
	 * Object is creating after every remote method call.
	 * <p>After receive reference to this object it's possible add extra params on result, fault, change priority set
	 * cache and so on.</p>
	 *
	 * @see rnlib.net.service.RemoteService
	 */
	public class Request implements IDisposable
	{
		/**
		 * @private
		 */
		rnlib var extraResult:Array;
		/**
		 * @private
		 */
		rnlib var extraFault:Array;
		/**
		 * @private
		 */
		rnlib var requestSend:Boolean = false;
		/**
		 * @private
		 */
		rnlib var updateQueue:Function;
		/**
		 * @private
		 */
		rnlib var cacheID:Object;
		/**
		 * @private
		 */
		rnlib var cacheStorageTime:int;
		/**
		 * @private
		 */
		rnlib var cacheTrigger:String = CacheRuleConstants.POLICY_NEVER;
		rnlib var cancelFunc:Function;
		rnlib var timeout:int = -1;

		private var _cancel:Boolean = false;
		private var _reconnectionsCounter:int = -1;
		private var _maxReconnections:int = -1;
		private var _customDelays:Array = [];
		private var _defaultDelay:int = 1;

		/**
		 * @private
		 * @param id
		 */
		public function Request(id:int)
		{_uid = id;}

		/**
		 * @private
		 */
		protected var _uid:int;

		/**
		 * Return unique identifier of request.
		 * <p>The identifier is uniqe between all instances of RemoteAMFService.</p>
		 */
		public function get uid():int
		{return _uid;}

		/**
		 * Is method already executed
		 */
		public function get called():Boolean
		{return requestSend;}

		/**
		 * @private
		 */
		internal var _priority:int = 1;

		public function get priority():int {return _priority;}

		/**
		 * Pass additional params on server response
		 * @param rest
		 * @return
		 */
		public function setExtraResultParams(...rest):Request
		{
			extraResult = rest;
			return this;
		}

		/**
		 * Pass additional params on server response
		 * @param rest
		 * @return
		 */
		public function setExtraFaultParams(...rest):Request
		{
			extraFault = rest;
			return this;
		}

		/**
		 * Pass additional params on server response to both handlers
		 * @param rest
		 * @return
		 */
		public function setExtraParams(...rest):Request
		{
			extraResult = rest;
			extraFault = rest;
			return this;
		}

		/**
		 * Update cache property
		 * @param id Cache ID for this request
		 * @param storageTime Storage time
		 * @return
		 */
		public function setCacheID(id:Object, storageTime:int = -1):Request
		{
			cacheID = id;
			cacheStorageTime = storageTime;
			return this;
		}

		/**
		 * Set specific priority of request.
		 * <p>Change can be affected only before added to request collections.
		 * It means that in next frame change can't be made.</p>
		 * @param priority
		 * @return
		 */
		public function setPriority(priority:int = 1):Request
		{
			_priority = priority;
			updateQueue(priority);
			return this;
		}

		public function setTimeout(ms:int = -1):Request
		{
			timeout = ms;
			return this;
		}

		/**
		 * Setup reconnection rules
		 * @param count
		 * @param defaultDelay Delay in ms
		 * @param customDelays Array of custom delays in ms
		 * @return
		 */
		public function setReconnections(count:int = 0, defaultDelay:int = 1, customDelays:Array = null):Request
		{
			_maxReconnections = Math.max(0, count);
			_defaultDelay = Math.max(1, defaultDelay);
			_customDelays = customDelays || [];
			return this;
		}

		rnlib function reconnect():Boolean
		{
			_reconnectionsCounter++;
			return _reconnectionsCounter < _maxReconnections;
		}

		rnlib function get reconnectionsCount():int {return _reconnectionsCounter;}

		rnlib function allowReconnecting():Boolean {return _maxReconnections > 0 && _reconnectionsCounter < _maxReconnections;}

		rnlib function getReconnectionDelay():int
		{
			if (_customDelays.length < _reconnectionsCounter)
				return _customDelays[_reconnectionsCounter];
			return _defaultDelay;
		}

		/**
		 * Close operation
		 */
		public function cancel():void
		{
			_cancel = true;
			if (cancelFunc != null)
				cancelFunc();
		}

		public function get isCanceled():Boolean {return _cancel;}

		//---------------------------------------------------------------
		//              <------ IDisposable ------>
		//---------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			extraResult = null;
			extraFault = null;
			updateQueue = null;
		}
	}
}
