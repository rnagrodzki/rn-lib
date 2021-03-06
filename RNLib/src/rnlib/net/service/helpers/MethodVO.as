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
package rnlib.net.service.helpers
{
	import rnlib.collections.IQueue;
	import rnlib.interfaces.IDisposable;
	import rnlib.net.service.*;
	import rnlib.rnlib;

	/**
	 * @private
	 *
	 * Helper for data storage calls of remote methods
	 *
	 * @see rnlib.net.service.RemoteService
	 */
	public class MethodVO implements IDisposable
	{
		public var isDisposed:Boolean;
		/**
		 * Unique identifier for any remote call
		 */
		public var uid:int;
		/**
		 * Name of remote methods to call
		 */
		public var name:String;
		/**
		 * Callback to invoke after receive
		 * response from server
		 */
		public var result:Function;
		/**
		 * Callback to invoke after receive
		 * response from server
		 */
		public var fault:Function;
		/**
		 * Arguments to pass to remote method
		 */
		public var args:Object;
		/**
		 * Request object
		 */
		public var request:Request;
		/**
		 * Queue
		 */
		public var queue:IQueue;

		public var cancelRequest:Function;

		public function cancel():void
		{
			if (cancelRequest != null)
				cancelRequest(this);
		}

		public function dispose():void
		{
			name = null;
			result = null;
			fault = null;
			args = null;
			request = null; // don't dispose this
			queue = null;
			cancelRequest = null;
			isDisposed = true;
		}

		public function clone():MethodVO
		{
			var vo:MethodVO = new MethodVO();
			vo.args = args;
			vo.name = name;
			vo.result = result;
			vo.fault = fault;
			vo.uid = uid;
			vo.request = request;
			vo.queue = queue;
			return vo;
		}

		public function updateQueue(priority:int):void
		{
			if (!queue) return;
			queue.updateItemPriority(this, priority);
		}

		public function shouldTryReconnection():Boolean {return request.rnlib::allowReconnecting();}

		public function isReconnecting():Boolean {return request.rnlib::reconnectionsCount >= 0;}

		public function getReconnectionDelay():int {return request.rnlib::getReconnectionDelay();}

		public function reconnect():void {request.rnlib::reconnect();}
	}
}
