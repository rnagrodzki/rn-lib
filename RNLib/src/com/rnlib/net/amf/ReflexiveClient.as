/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf
{
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	public class ReflexiveClient extends Proxy
	{
		public function ReflexiveClient()
		{
		}

		public var callback:Function;

		private var _dispatcher:IEventDispatcher;

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
			if (callback)
				callback.apply(null, [name].concat(rest));
		}

		override flash_proxy function hasProperty(name:*):Boolean
		{
			return true;
		}
	}
}
