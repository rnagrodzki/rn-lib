/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net
{
	import flash.net.NetConnection;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	public dynamic class RemoteAmfService extends Proxy
	{
		protected var _nc:NetConnection;

		protected var _service:String;

		private var _endpoint:String;

		private var _result:Function;

		private var _fault:Function;

		public function RemoteAmfService()
		{
		}

		public function get endpoint():String
		{
			return _endpoint;
		}

		public function set endpoint(value:String):void
		{
			if (_endpoint == value) return;

			_endpoint = value;
		}

		//---------------------------------------------------------------
		//              <------ GLOBAL RESULT HANDLERS ------>
		//---------------------------------------------------------------

		public function get result():Function
		{
			return _result;
		}

		public function set result(value:Function):void
		{
			_result = value;
		}

		public function get fault():Function
		{
			return _fault;
		}

		public function set fault(value:Function):void
		{
			_fault = value;
		}

		//---------------------------------------------------------------
		//          <------ PART OF PROXY BEHAVIOR ------>
		//---------------------------------------------------------------

		override flash_proxy function callProperty(name:*, ...rest):*
		{
			trace("callProperty");

			if (hasOwnProperty(name))
				return super.flash_proxy::callProperty(name, rest);
			else
			{
				trace("property doesn't exist");
			}
		}

		override flash_proxy function setProperty(name:*, value:*):void
		{
			if (hasOwnProperty(name))
				super.flash_proxy::setProperty(name, value);
		}

		override flash_proxy function getProperty(name:*):*
		{
			if (hasOwnProperty(name))
				return super.flash_proxy::getProperty(name);

			return undefined;
		}

		override flash_proxy function hasProperty(name:*):Boolean
		{
			return super.flash_proxy::hasProperty(name);
		}
	}
}
