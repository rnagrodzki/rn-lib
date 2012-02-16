/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf
{
	import com.rnlib.net.*;
	import com.rnlib.net.amf.connections.AMFULConnection;
	import com.rnlib.net.amf.connections.IAMFConnection;
	import com.rnlib.net.amf.processor.AMFHeader;
	import com.rnlib.queue.IQueue;
	import com.rnlib.queue.PriorityQueue;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.FileReference;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	import mx.managers.CursorManager;
	import mx.rpc.mxml.IMXMLSupport;

	[Event(name="netStatus", type="flash.events.NetStatusEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	[Event(name="asyncError", type="flash.events.AsyncErrorEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	/**
	 * Event dispatched after receive result status from server
	 */
	[Event(name="result", type="com.rnlib.net.amf.AMFEvent")]
	/**
	 * Event dispatched after receive fault status from server
	 */
	[Event(name="fault", type="com.rnlib.net.amf.AMFEvent")]

	use namespace flash_proxy;

	public dynamic class RemoteAmfService extends Proxy implements IEventDispatcher, IMXMLSupport
	{
		private var _queue:IQueue = new PriorityQueue();

		protected var _nc:IAMFConnection;

		protected var _service:String;

		protected var _endpoint:String;

		protected var _result:Function;

		protected var _fault:Function;

		protected var _remoteMethods:Dictionary = new Dictionary();

		protected var _defaultMethods:Array;

		protected var _dispatcher:IEventDispatcher;

		protected var _concurrency:String = RequestConcurrency.QUEUE;

		protected var _isPendingRequest:Boolean = false;

		protected var _requests:Dictionary = new Dictionary();

		private var _reqCount:int = 0;

		private static var _CALL_UID:int = 0;

		/**
		 * Determine execute all request in queue after error occure.
		 */
		public var proceedAfterError:Boolean = true;

		protected var _showBusyCursor:Boolean = true;

		public function RemoteAmfService()
		{
			defaultMethods();
			init();
		}

		protected function init():void
		{
			_dispatcher = new EventDispatcher(this);
			connection = new AMFULConnection();
		}

		//---------------------------------------------------------------
		//              <------ CONNECTION ------>
		//---------------------------------------------------------------

		public function get connection():IAMFConnection
		{
			return _nc;
		}

		public function set connection(value:IAMFConnection):void
		{
			if (value != _nc)
			{
				if (_nc)
				{
					_nc.dispose();
				}

				_nc = value;

				if (!value) return;

				if (_amfHeaders && _amfHeaders.length)
				{
					for each (var header:AMFHeader in _amfHeaders)
					{
						_nc.addHeader(header.name, header.mustUnderstand, header.data);
					}
				}

				_nc.redispatcher = this;
				_nc.reconnectRepeatCount = 3;

				if (_endpoint) _nc.connect(_endpoint);
			}
		}

		protected function disconnect():void
		{
			if (_nc)
				_nc.close();
		}

		//---------------------------------------------------------------
		//              <------ DEVELOPER INTERFACE METHODS ------>
		//---------------------------------------------------------------

		/**
		 * Dispose all request, connections and remote methods.
		 */
		public function dispose():void
		{
			if (_nc)
			{
				_nc.dispose();
			}

			ignoreAllPendingRequests(_concurrency != RequestConcurrency.LAST);

			for each (var vo:MethodHelperVO in _remoteMethods)
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
			_files = new Dictionary();
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
		 * <li>queue - All requests are queued and called sequentially one after the other. This is the default.</li>
		 * <li>multiple - Existing requests are not cancelled, and the developer is
		 * responsible for ensuring the consistency of returned data by carefully
		 * managing the event stream.</li>
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

		public function get showBusyCursor():Boolean
		{
			return _showBusyCursor;
		}

		public function set showBusyCursor(value:Boolean):void
		{
			if (_showBusyCursor && !value) CursorManager.removeBusyCursor();

			_showBusyCursor = value;
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

		//---------------------------------------------------------------
		//              <------ MANAGE REMOTE METHODS ------>
		//---------------------------------------------------------------

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
			var vo:MethodHelperVO = new MethodHelperVO(name);
			vo.result = result || _result;
			vo.fault = fault || _fault;

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
					MethodHelperVO(_remoteMethods[name]).dispose();
			} catch (e:Error)
			{
			}

			_remoteMethods[name] = null;
			delete _remoteMethods[name];
		}

		//---------------------------------------------------------------
		//              <------ PAUSE AND RESUME ------>
		//---------------------------------------------------------------

		protected var _isPaused:Boolean = false;

		/**
		 * Pause execute requests in queue. Please notice that method take effect
		 * only then concurrency is set to <code>RequestConcurrency.QUEUE</code>
		 *
		 * @see #concurrency
		 * @see com.rnlib.net.RequestConcurrency#QUEUE
		 */
		public function pause():void
		{
			_isPaused = true;
		}

		/**
		 * Resume execute requests in queue. Please notice that method take effect
		 * only then concurrency is set to <code>RequestConcurrency.QUEUE</code>.
		 * If in queue are any requests after call this method they will be execute.
		 *
		 * @see #concurrency
		 * @see #queue
		 * @see com.rnlib.net.RequestConcurrency#QUEUE
		 */
		public function resume():void
		{
			_isPaused = false;

			if (concurrency == RequestConcurrency.QUEUE && !_isPendingRequest && queue && queue.length > 0)
				callRemoteMethod(_queue.item);
		}

		//---------------------------------------------------------------
		//          <------ MANAGE SERVICE AND ENDPOINT ------>
		//---------------------------------------------------------------

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

			if (connection && !connection.connected)
				connection.connect(_endpoint);
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
		//              <------ AMF HEADERS ------>
		//---------------------------------------------------------------

		private var _amfHeaders:Array; // Array of AMFHeader

		/**
		 * Adds an AMF packet-level header which is sent with every request for
		 * the life of this AMFConnection.
		 */
		public function addHeader(name:String, mustUnderstand:Boolean = false, data:* = undefined):void
		{
			if (!_amfHeaders)
				_amfHeaders = [];

			var header:AMFHeader = new AMFHeader(name, mustUnderstand, data);
			_amfHeaders.push(header);

			if (connection) connection.addHeader(name, mustUnderstand, data);
		}

		/**
		 * Removes any AMF headers found with the name given.
		 *
		 * @param name The name of the header(s) to remove.
		 *
		 * @return true if a header existed with the given name.
		 */
		public function removeHeader(name:String):Boolean
		{
			var exists:Boolean = false;

			if (_amfHeaders)
			{
				for (var i:uint = 0; i < _amfHeaders.length; i++)
				{
					var header:AMFHeader = _amfHeaders[i] as AMFHeader;
					if (header.name == name)
					{
						_amfHeaders.splice(i, 1);
						exists = true;
					}
				}
			}

			if (connection) connection.removeHeader(name);

			return exists;
		}

		//---------------------------------------------------------------
		//          <------ PART OF PROXY BEHAVIOR ------>
		//---------------------------------------------------------------

		override flash_proxy function callProperty(name:*, ...rest):*
		{
			var hasProp:Boolean = hasOwnProperty(name);
			if (hasProp && _remoteMethods[name])
			{
				var mvo:MethodHelperVO = _remoteMethods[name];
				var vo:MethodVO = new MethodVO();
				vo.uid = _CALL_UID++;
				vo.name = name;
				vo.args = rest;
				vo.result = mvo.result;
				vo.fault = mvo.fault;

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
				return vo.uid;
			}
			else if (hasProp)
			{
				return super.callProperty.apply(null, [name].concat(rest));
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
			if (_defaultMethods.lastIndexOf(name) >= 0)
				return true;

			return Boolean(_remoteMethods[name]);
		}

		//---------------------------------------------------------------
		//              <------ CONCURRENCY METHODS ------>
		//---------------------------------------------------------------

		protected function concurrencyQueue(vo:MethodVO):void
		{
			if (_isPendingRequest || _isPaused)
				_queue.push(vo);
			else
				callRemoteMethod(vo);
		}

		protected function concurrencyLast(vo:MethodVO):void
		{
			ignoreAllPendingRequests(false);
			callRemoteMethod(vo);
		}

		protected function concurrencySingle(vo:MethodVO):void
		{
			ignoreAllPendingRequests(true);
			callRemoteMethod(vo);
		}

		protected function concurrencyMultiple(vo:MethodVO):void
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
		protected function callRemoteMethod(vo:MethodVO):void
		{
			_isPendingRequest = true;

			if (vo.args)
			{
				for (var i:int = 0; i < vo.args.length; i++)
				{
					var object:Object = vo.args[i];
					if (object is FileReference && object.data)
					{
						vo.args[i] = object.data;
					}
					else if (object is FileReference && !object.data)
					{
						waitForFileContent(object as FileReference, vo);
						return;
					}
				}
			}

			var rm:ResultMediatorVO = new ResultMediatorVO();
			rm.uid = vo.uid;
			rm.id = _reqCount++;
			rm.name = vo.name;
			rm.resultHandler = vo.result; // force call currently specified method handler
			rm.faultHandler = vo.fault; // force call currently specified method handler
			rm.internalFaultHandler = onFault;
			rm.internalResultHandler = onResult;

			_requests[rm.id] = rm;

			var fullName:String = _service ? _service + "." + vo.name : vo.name;
			var args:Array = [fullName, rm.result, rm.fault];

			_nc.call.apply(_nc, args.concat(vo.args));

			if (_showBusyCursor) CursorManager.setBusyCursor();
		}

		//---------------------------------------------------------------
		//              <------ LOAD FILES JUST IN TIME ------>
		//---------------------------------------------------------------

		protected var _files:Dictionary = new Dictionary();

		protected function waitForFileContent(fr:FileReference, vo:MethodVO):void
		{
			fr.addEventListener(Event.COMPLETE, onCompleteLoadFileContent, false, 0, true);
			_files[fr] = vo;
			fr.load();
		}

		private function onCompleteLoadFileContent(e:Event):void
		{
			var fr:FileReference = e.target as FileReference;
			var vo:MethodVO = _files[fr];
			_files[fr] = null;
			delete _files[fr];
			fr.removeEventListener(Event.COMPLETE, onCompleteLoadFileContent, false);
			callRemoteMethod(vo);
		}

		//---------------------------------------------------------------
		//              <------ GLOBAL RESPONSE HANDLERS ------>
		//---------------------------------------------------------------

		/**
		 * Global internal result handler
		 * @param result Response from server
		 * @param name Name remote method
		 * @param id Request id
		 */
		protected function onResult(result:Object, name:String, id:int, uid:int):void
		{
			if (_showBusyCursor) CursorManager.removeBusyCursor();

			var vo:ResultMediatorVO = _requests[id];

			if (vo.resultHandler != null)
				vo.resultHandler(result);
			else if (this.result != null)
				this.result(result);

			dispatchEvent(new AMFEvent(AMFEvent.RESULT, uid, result));

			_isPendingRequest = false;

			_requests[id] = null;
			delete _requests[id];
			if (_concurrency == RequestConcurrency.QUEUE && _queue && _queue.length > 0 && !_isPaused && continueAfterFault)
				callRemoteMethod(_queue.item);
		}

		/**
		 * Determine if requests in queue should execute
		 * after received fault from pending request
		 */
		public var continueAfterFault:Boolean = false;

		/**
		 * Global internal fault handler
		 * @param fault Response from server
		 * @param name Name remote method
		 * @param id Request id
		 */
		protected function onFault(fault:Object, name:String, id:int, uid:int):void
		{
			if (_showBusyCursor) CursorManager.removeBusyCursor();

			var vo:ResultMediatorVO = _requests[id];

			if (vo.faultHandler != null)
				vo.faultHandler(fault);
			else if (this.fault != null)
				this.fault(fault);

			dispatchEvent(new AMFEvent(AMFEvent.FAULT, uid, fault));

			_isPendingRequest = false;

			_requests[id] = null;
			delete _requests[id];
		}

		//---------------------------------------------------------------
		//              <------ IGNORE PENDING REQUESTS ------>
		//---------------------------------------------------------------

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

			if (_showBusyCursor) CursorManager.removeBusyCursor();
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

class MethodHelperVO
{
	public var name:String;
	public var result:Function;
	public var fault:Function;

	public function MethodHelperVO(name:String = null)
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
	public var uid:int;
	public var id:int;
	public var name:String;

	public var resultHandler:Function;
	public var internalResultHandler:Function;

	public function result(r:Object):void
	{
		internalResultHandler(r, name, id, uid);
		dispose();
	}

	public var faultHandler:Function;
	public var internalFaultHandler:Function;

	public function fault(f:Object):void
	{
		internalFaultHandler(f, name, id, uid);
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
