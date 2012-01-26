/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net
{
	import com.rnlib.queue.IQueue;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	use namespace flash_proxy;

	public dynamic class RemoteAmfService extends Proxy implements IEventDispatcher
	{
		protected var _queue:IQueue;

		protected var _nc:NetConnection = new NetConnection();

		protected var _service:String;

		protected var _endpoint:String;

		protected var _result:Function;

		protected var _fault:Function;

		protected var _remoteMethods:Array = [];

		protected var _defaultMethods:Array;

		protected var _dispatcher:IEventDispatcher = new EventDispatcher();

		protected var _concurrency:String = RequestConcurrency.QUEUING_REQUESTS;

		protected var _isPendingRequest:Boolean = false;

		protected var _requests:Dictionary = new Dictionary();

		private var _reqCount:int = 10;

		public function RemoteAmfService()
		{
			defaultMethods();
		}

		private function defaultMethods():void
		{
			_defaultMethods = [
				"toString",
				"toLocaleString",
				"valueOf"
			];
		}

		public function get concurrency():String
		{
			return _concurrency;
		}

		public function set concurrency(value:String):void
		{
			_concurrency = value;
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
			if (hasOwnProperty(name))
			{
				var vo:RemoteMethodVO = new RemoteMethodVO();
				vo.name = name;
				vo.args = rest;

				_nc.connect(_endpoint);

				switch (_concurrency)
				{
					case RequestConcurrency.QUEUING_REQUESTS:
						concurrencyQueueing(vo);
						break;
					case RequestConcurrency.MULTIPLE:
						concurrencyMultiple(vo);
						break;
					case RequestConcurrency.LAST:
						concurrencyLast(vo);
						break;
					case RequestConcurrency.SINGLE:
						concurrencySingle(vo);
						break;
				}
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
		//              <------ CONCURRENCY METHODS ------>
		//---------------------------------------------------------------

		protected function concurrencyQueueing(vo:RemoteMethodVO):void
		{

		}

		protected function concurrencyLast(vo:RemoteMethodVO):void
		{

		}

		protected function concurrencySingle(vo:RemoteMethodVO):void
		{
			/*if (_isPendingRequest)
			{
				_nc.close();
			}*/
			callRemoteMethod(vo);
		}

		protected function concurrencyMultiple(vo:RemoteMethodVO):void
		{

		}

		//---------------------------------------------------------------
		//              <------ CALLING REMOTE SERVICE ------>
		//---------------------------------------------------------------

		protected function callRemoteMethod(vo:RemoteMethodVO):void
		{
			_isPendingRequest = true;

			var rm:ResultMediatorVO = new ResultMediatorVO();
			rm.id = _reqCount++;
			rm.faultHandler = vo.fault;
			rm.resultHandler = vo.result;
			rm.internalFaultHandler = onFault;
			rm.internalResultHandler = onResult;

			_requests[rm.id] = rm;

			var fullName:String = _service ? _service + "." + vo.name : vo.name;
			var args:Array = [fullName, new Responder(rm.result, rm.fault)];
			_nc.call.apply(_nc, args.concat(vo.args));
		}

		protected function onResult(result:Object, id:int):void
		{
			trace("onResult id: " + id);

			var vo:ResultMediatorVO = _requests[id];
			_requests[id] = null;

			if (vo.resultHandler)
				vo.resultHandler(result);
			else
				this.result(result);
		}

		protected function onFault(fault:Object, id:int):void
		{
			trace("onFault id: " + id);

			var vo:ResultMediatorVO = _requests[id];
			_requests[id] = null;

			if (vo.faultHandler)
				vo.faultHandler(result);
			else
				this.fault(fault);
		}

		//---------------------------------------------------------------
		//       <------ IMPLEMENT EVENT DISPATCHER METHODS ------>
		//---------------------------------------------------------------

		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			_dispatcher.addEventListener.apply(null, arguments);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			_dispatcher.removeEventListener.apply(null, arguments);
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return _dispatcher.dispatchEvent(event);
		}

		public function hasEventListener(type:String):Boolean
		{
			return _dispatcher.hasEventListener(type);
		}

		public function willTrigger(type:String):Boolean
		{
			return _dispatcher.willTrigger(type);
		}
	}
}

class ResultMediatorVO
{
	public var id:int;

	public var resultHandler:Function;
	public var internalResultHandler:Function;

	public function result(r:Object):void
	{
		internalResultHandler(r, id);
	}

	public var faultHandler:Function;
	public var internalFaultHandler:Function;

	public function fault(f:Object):void
	{
		internalFaultHandler(f, id);
	}
}
