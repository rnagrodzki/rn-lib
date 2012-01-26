/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net
{
	import com.rnlib.queue.IQueue;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	public dynamic class RemoteAmfService extends Proxy implements IEventDispatcher
	{
		protected var _queue:IQueue;

		protected var _nc:NetConnection;

		protected var _service:String;

		protected var _endpoint:String;

		protected var _result:Function;

		protected var _fault:Function;

		protected var _remoteMethods:Array = [];

		public function RemoteAmfService()
		{
		}

		public function addMethod(name:String):Boolean
		{
			var idx:int = _remoteMethods.lastIndexOf(name);

			if (idx == -1)
				_remoteMethods.push(name);

			return idx == -1;
		}

		public function removeMethod(name:String):Boolean
		{
			var idx:int = _remoteMethods.lastIndexOf(name);

			if (idx != -1)
				_remoteMethods.splice(idx, 1);

			return idx != -1;
		}

		public function get service():String
		{
			return _service;
		}

		public function set service(value:String):void
		{
			if (_service == value)
				return;

			_service = value;
		}

		public function get endpoint():String
		{
			return _endpoint;
		}

		public function set endpoint(value:String):void
		{
			if (_endpoint == value)
				return;

			_endpoint = value;

			_nc.close();
			_nc.connect(value);
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
			if (hasProperty(name))
			{
				var arg:Array = [name];
				callRemoteMethod.apply(this, arg.concat(rest));
			}
			else
			{
				throw new Error("First add " + name + " to remote methods by addMethod function");
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
			return _remoteMethods.lastIndexOf(name) != -1;
		}

		//---------------------------------------------------------------
		//              <------ CALLING REMOTE SERVICE ------>
		//---------------------------------------------------------------

		public function callRemoteMethod(name:String, result:Function, fault:Function, ...rest):void
		{
			var fullName:String = _service ? _service + "." + name : name;
			var args:Array = [fullName, new Responder(result, fault)];
			_nc.call.apply(_nc, args.concat(rest));
		}

		//---------------------------------------------------------------
		//       <------ IMPLEMENT EVENT DISPATCHER METHODS ------>
		//---------------------------------------------------------------

		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return false;
		}

		public function hasEventListener(type:String):Boolean
		{
			return false;
		}

		public function willTrigger(type:String):Boolean
		{
			return false;
		}
	}
}
