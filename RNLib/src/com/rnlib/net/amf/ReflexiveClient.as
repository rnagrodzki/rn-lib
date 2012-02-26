/***************************************************************************************************
 Copyright (c) 2012. Rafał Nagrodzki (rafal.nagrodzki.dev@gmail.com)
 http://rafal-nagrodzki.com/

 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/
package com.rnlib.net.amf
{
	import com.rnlib.interfaces.IDisposable;

	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	/**
	 * Class supported recognize all unregistered
	 * amf headers calls and of course these registered.
	 * If NetConnection attempt to call specified method
	 * event will be fired with header details.
	 */
	public dynamic class ReflexiveClient extends Proxy implements IDisposable
	{
		public function ReflexiveClient()
		{
		}

		/**
		 * Callback to react on receive headers
		 */
		public var callback:Function;

		private var _dispatcher:IEventDispatcher;

		/**
		 * If is set class will also dispatch <code>AMFEvent.HEADER</code>
		 * with passed arguments by server
		 */
		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}

		public function set dispatcher(value:IEventDispatcher):void
		{
			_dispatcher = value;
		}

		override flash_proxy function callProperty(name:*, ...rest):*
		{
			var vo:ClientVO = new ClientVO(name, rest);

			if (callback != null)
				callback.apply(null, [vo]);

			//todo: add uid support for event
			if (_dispatcher)
				_dispatcher.dispatchEvent(new AMFEvent(AMFEvent.HEADER, -1, vo));
		}

		override flash_proxy function hasProperty(name:*):Boolean
		{
			return true;
		}

		public function dispose():void
		{
			callback = null;
			_dispatcher = null;
		}
	}
}
