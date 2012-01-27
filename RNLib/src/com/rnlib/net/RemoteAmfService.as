/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net
{
	import com.rnlib.queue.IQueue;
	import com.rnlib.queue.PriorityQueue;

	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	[Event(name="netStatus", type="flash.events.NetStatusEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	[Event(name="asyncError", type="flash.events.AsyncErrorEvent")]

	use namespace flash_proxy;

	public dynamic class RemoteAmfService extends Proxy implements IEventDispatcher
	{
		private var _queue:IQueue;

		protected var _nc:NetConnection;

		protected var _service:String;

		protected var _endpoint:String;

		protected var _result:Function;

		protected var _fault:Function;

		protected var _remoteMethods:Dictionary = new Dictionary();

		protected var _defaultMethods:Array;

		protected var _dispatcher:IEventDispatcher = new EventDispatcher();

		protected var _concurrency:String = RequestConcurrency.QUEUE;

		protected var _isPendingRequest:Boolean = false;

		protected var _requests:Dictionary = new Dictionary();

		private var _reqCount:int = 0;

		public var proceedAfterError:Boolean = true;

		public function RemoteAmfService()
		{
			defaultMethods();
		}

		//---------------------------------------------------------------
		//              <------ NETCONNECTION ------>
		//---------------------------------------------------------------

		protected function registerNetConnection():void
		{
			if (!_nc)
			{
				_nc = new NetConnection();
				_nc.addEventListener(NetStatusEvent.NET_STATUS, onStatusEvent, false, 0, true);
				_nc.addEventListener(IOErrorEvent.IO_ERROR, onIOErrorEvent, false, 0, true);
				_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityErrorEvent, false, 0, true);
				_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncErrorEvent, false, 0, true);
				_nc.connect(_endpoint);
			}
		}

		protected function disconnect():void
		{
			_nc.removeEventListener(NetStatusEvent.NET_STATUS, onStatusEvent);
			_nc.removeEventListener(IOErrorEvent.IO_ERROR, onIOErrorEvent);
			_nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityErrorEvent);
			_nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncErrorEvent);

			if (_nc)
				_nc.close();

			_nc = null;
		}

		protected function onStatusEvent(e:NetStatusEvent):void
		{
			if (e.info == "NetConnection.Call.BadVersion" || e.info == "NetConnection.Call.Failed")
			{
				disconnect();
				ignoreAllPendingRequests(_concurrency != RequestConcurrency.LAST);

				if (_queue && _queue.length > 0)
				{
					if (proceedAfterError)
					{
						registerNetConnection();
						callRemoteMethod(_queue.item);
					}
					else
					{
						_queue.dispose();
					}
				}

				dispatchEvent(e);
			}
			else if (e.info == "NetConnection.Connect.Closed")
			{
				disconnect();
			}
		}

		protected function onAsyncErrorEvent(e:AsyncErrorEvent):void
		{
			disconnect();
			dispatchEvent(e);
		}

		protected function onSecurityErrorEvent(e:SecurityErrorEvent):void
		{
			disconnect();
			dispatchEvent(e);
		}

		protected function onIOErrorEvent(e:IOErrorEvent):void
		{
			disconnect();
			dispatchEvent(e);
		}

		//---------------------------------------------------------------
		//              <------ DEVELOPER INTERFACE METHODS ------>
		//---------------------------------------------------------------

		/**
		 * Dispose all request, connections and remote methods.
		 */
		public function dispose():void
		{
			disconnect();

			ignoreAllPendingRequests(_concurrency != RequestConcurrency.LAST);

			for each (var vo:MethodVO in _remoteMethods)
			{
				_remoteMethods[vo.name] = null;
				vo.dispose();
			}

			if (_queue)
			{
				_queue.dispose();
			}

			_isPendingRequest = false;
			_remoteMethods = new Dictionary();
			_requests = new Dictionary();
		}

		private function defaultMethods():void
		{
			_defaultMethods = [
				"toString",
				"toLocaleString",
				"valueOf"
			];
		}

		/**
		 * Value that indicates how to handle multiple calls to the same service. The default
		 * value is queue. The following values are permitted:
		 * <ul>
		 * <li>queue - All requests are queued and called sequentially one after the other.</li>
		 * <li>multiple - Existing requests are not cancelled, and the developer is
		 * responsible for ensuring the consistency of returned data by carefully
		 * managing the event stream. This is the default.</li>
		 * <li>single - Making only one request at a time is allowed on the method; additional requests made
		 * while a request is outstanding are immediately faulted on the client and are not sent to the server.</li>
		 * <li>last - Making a request causes the client to ignore a result or fault for any current outstanding request.
		 * Only the result or fault for the most recent request will be dispatched on the client.
		 * This may simplify event handling in the client application, but care should be taken to only use
		 * this mode when results or faults for requests may be safely ignored.</li>
		 * </ul>
		 *
		 * @see com.rnlib.net.RequestConcurrency
		 */
		public function get concurrency():String
		{
			return _concurrency;
		}

		public function set concurrency(value:String):void
		{
			if (value == RequestConcurrency.QUEUE && !_queue)
				_queue = new PriorityQueue();

			_concurrency = value;
		}

		/**
		 * Property to change default queue class
		 */
		public function get queue():IQueue
		{
			return _queue;
		}

		public function set queue(value:IQueue):void
		{
			ignoreAllPendingRequests(_concurrency != RequestConcurrency.LAST);

			_queue = value;
		}

		/**
		 * Add remote method to dynamic invoke at runtime
		 * @param name Name of remote method to invoke
		 * @param result Result handler
		 * @param fault Fault handler
		 *
		 * @example <code>
		 *	 var ras : RemoteAmfService = new RemoteAmfService();
		 *	 ras.endpoint = "http://example.com/gateway";
		 *	 ras.service = "MyExampleService";
		 *	 ras.addMethod("myRemoteFunction",resultCallback,faultCallback);
		 *	 ras.myRemoteFunction(); // this will invoke remote method "myRemoteFunction" on remote service "MyExampleService"
		 *	 // or you can also send parameters to remote method as shown below
		 *	 ras.myRemoteFunction("param1",2,{name:"x",url:"http://example.com"}); // or more complex structures
		 * </code>
		 *
		 * @see #removeMethod()
		 */
		public function addMethod(name:String, result:Function = null, fault:Function = null):void
		{
			var vo:MethodVO = new MethodVO(name);
			vo.result = result || _result;
			vo.fault = fault || _fault;

			if (vo.result == null || vo.fault == null)
			{
				throw new Error("Global handlers not set. Set first them by property result & fault!")
			}

			removeMethod(name);
			_remoteMethods[name] = vo
		}

		/**
		 * Remove remote method to dynamic invoke at runtime
		 * @param name
		 *
		 * @example <code>
		 *	 var ras : RemoteAmfService = new RemoteAmfService();
		 *	 ras.endpoint = "http://example.com/gateway";
		 *	 ras.service = "MyExampleService";
		 *	 ras.addMethod("myRemoteFunction",resultCallback,faultCallback);
		 *	 ras.addMethod("mySecondRemoteFunction",resultCallback,faultCallback);
		 *	 ras.myRemoteFunction(); // ok
		 *	 ras.mySecondRemoteFunction(); // ok
		 *	 ras.removeMethod("mySecondRemoteFunction");
		 *	 ras.mySecondRemoteFunction(); // throw Error
		 * </code>
		 *
		 * @see #addMethod()
		 */
		public function removeMethod(name:String):void
		{
			try
			{
				if (_remoteMethods[name])
					MethodVO(_remoteMethods[name]).dispose();
			} catch (e:Error)
			{
			}

			_remoteMethods[name] = null;
		}

		/**
		 * Declare service for remote calls
		 */
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

		/**
		 * AMF endpoint.
		 * @exampleText endpoint = "http://myhost.com/amf"
		 */
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

		/**
		 * Global result handler for all invoke remote methods
		 */
		public function get result():Function
		{
			return _result;
		}

		public function set result(value:Function):void
		{
			_result = value;
		}

		/**
		 * Global fault handler for all invoke remote methods
		 */
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
				var mvo:MethodVO = _remoteMethods[name];
				var vo:RemoteMethodVO = new RemoteMethodVO();
				vo.name = name;
				vo.args = rest;
				vo.result = mvo.result;
				vo.fault = mvo.fault;

				registerNetConnection();

				switch (_concurrency)
				{
					case RequestConcurrency.QUEUE:
						concurrencyQueue(vo);
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
			return Boolean(_remoteMethods[name]);
		}

		//---------------------------------------------------------------
		//              <------ CONCURRENCY METHODS ------>
		//---------------------------------------------------------------

		protected function concurrencyQueue(vo:RemoteMethodVO):void
		{
			if (_isPendingRequest)
				_queue.push(vo);

			callRemoteMethod(vo);
		}

		protected function concurrencyLast(vo:RemoteMethodVO):void
		{
			ignoreAllPendingRequests(false);
			callRemoteMethod(vo);
		}

		protected function concurrencySingle(vo:RemoteMethodVO):void
		{
			ignoreAllPendingRequests(true);
			callRemoteMethod(vo);
		}

		protected function concurrencyMultiple(vo:RemoteMethodVO):void
		{
			callRemoteMethod(vo);
		}

		//---------------------------------------------------------------
		//              <------ CALLING REMOTE SERVICE ------>
		//---------------------------------------------------------------

		/**
		 * Invoke register remote method
		 * @param vo
		 */
		protected function callRemoteMethod(vo:RemoteMethodVO):void
		{
			_isPendingRequest = true;

			var rm:ResultMediatorVO = new ResultMediatorVO();
			rm.id = _reqCount++;
			rm.name = vo.name;
			rm.resultHandler = vo.result; // force call currently specified method handler
			rm.faultHandler = vo.fault; // force call currently specified method handler
			rm.internalFaultHandler = onFault;
			rm.internalResultHandler = onResult;

			_requests[rm.id] = rm;

			var fullName:String = _service ? _service + "." + vo.name : vo.name;
			var args:Array = [fullName, new Responder(rm.result, rm.fault)];
			_nc.call.apply(_nc, args.concat(vo.args));
		}

		/**
		 * Global internal result handler
		 * @param result Response from server
		 * @param name Name remote method
		 * @param id Request id
		 */
		protected function onResult(result:Object, name:String, id:int):void
		{
			_isPendingRequest = false;
//			trace("onResult id: " + id + " time: " + getTimer());

			var vo:ResultMediatorVO = _requests[id];

			if (vo.resultHandler != null)
				vo.resultHandler(result);
			else
				this.result(result);

			_requests[id] = null;
			if (_concurrency == RequestConcurrency.QUEUE && _queue && _queue.length > 0)
				callRemoteMethod(_queue.item);
		}

		/**
		 * Global internal fault handler
		 * @param fault Response from server
		 * @param name Name remote method
		 * @param id Request id
		 */
		protected function onFault(fault:Object, name:String, id:int):void
		{
			_isPendingRequest = false;
//			trace("onFault id: " + id + " time: " + getTimer());

			var vo:ResultMediatorVO = _requests[id];

			if (vo.faultHandler != null)
				vo.faultHandler(fault);
			else
				this.fault(fault);

			_requests[id] = null;
		}

		protected function ignoreAllPendingRequests(callFault:Boolean = true):void
		{
			disconnect();
			for each (var vo:ResultMediatorVO in _requests)
			{
				if (callFault && vo.faultHandler)
					vo.faultHandler("Ignore by user");
				vo.dispose();
				_requests[vo.id] = null;
			}
			_isPendingRequest = false;
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

class MethodVO
{
	public var name:String;
	public var result:Function;
	public var fault:Function;

	public function MethodVO(name:String = null)
	{
		this.name = name;
	}

	public function dispose():void
	{
		name = null;
		result = null;
		fault = null;
	}
}

class ResultMediatorVO
{
	public var id:int;
	public var name:String;

	public var resultHandler:Function;
	public var internalResultHandler:Function;

	public function result(r:Object):void
	{
		internalResultHandler(r, name, id);
		dispose();
	}

	public var faultHandler:Function;
	public var internalFaultHandler:Function;

	public function fault(f:Object):void
	{
		internalFaultHandler(f, name, id);
		dispose();
	}

	public function dispose():void
	{
		id = 0;
		name = null;
		internalFaultHandler = null;
		internalResultHandler = null;
		faultHandler = null;
		resultHandler = null;
	}
}
