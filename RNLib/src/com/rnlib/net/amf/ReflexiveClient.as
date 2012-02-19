/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
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
