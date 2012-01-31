/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.connections
{
	import flash.events.EventDispatcher;

	import mx.core.ClassFactory;

	public class AMFURLLoaderAdapter extends EventDispatcher implements IAMFConnection
	{
		protected var _factory:ClassFactory;

		protected var _headers:Array;

		public function AMFURLLoaderAdapter()
		{
			init();
		}

		protected function init():void
		{
			_factory = new ClassFactory(AMFURLLoaderConnection);
		}

		public function connect(uri:String):void
		{
		}

		public function call(command:String, result:String = null, fault:String = null, ...args):void
		{
			var loader : AMFURLLoaderConnection = _factory.newInstance();
			loader.call.apply(this,[command,result,fault].concat(args));
		}

		public function close():void
		{
		}

		public function dispose():void
		{
		}

		public function get objectEncoding():uint
		{
			return 0;
		}

		public function set objectEncoding(value:uint):void
		{
		}

		public function get client():Object
		{
			return null;
		}

		public function set client(value:Object):void
		{
		}

		public function get connected():Boolean
		{
			return false;
		}

		public function addHeader(name:String, mustUnderstand:Boolean = false, data:* = undefined):void
		{
		}

		public function removeHeader(name:String):Boolean
		{
			return false;
		}
	}
}
