/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
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

package rnlib.net.amf
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.clearTimeout;
	import flash.utils.flash_proxy;
	import flash.utils.setTimeout;

	import mx.managers.CursorManager;
	import mx.rpc.mxml.IMXMLSupport;

	import rnlib.interfaces.IDisposable;
	import rnlib.net.*;
	import rnlib.net.amf.connections.AMFULConnection;
	import rnlib.net.amf.connections.IAMFConnection;
	import rnlib.net.amf.processor.AMFHeader;
	import rnlib.net.cache.IResponseCacheManager;
	import rnlib.net.cache.rules.CacheRuleConstants;
	import rnlib.net.cache.rules.ICacheRule;
	import rnlib.net.plugins.INetMultipartPlugin;
	import rnlib.net.plugins.INetPlugin;
	import rnlib.net.plugins.INetPluginFactory;
	import rnlib.net.plugins.INetPluginVO;
	import rnlib.net.plugins.NetPluginEvent;
	import rnlib.queue.IQueue;
	import rnlib.queue.PriorityQueue;

	[Event(name="netStatus", type="flash.events.NetStatusEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	[Event(name="asyncError", type="flash.events.AsyncErrorEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	/**
	 * Event dispatched after receive result status from server
	 */
	[Event(name="result", type="rnlib.net.amf.AMFEvent")]
	/**
	 * Event dispatched after receive fault status from server
	 */
	[Event(name="fault", type="rnlib.net.amf.AMFEvent")]

	/**
	 * Dispatch then new plugin is created
	 */
	[Event(name="pluginCreated", type="rnlib.net.plugins.NetPluginEvent")]

	/**
	 * Dispatch then plugin is disposed
	 */
	[Event(name="pluginDisposed", type="rnlib.net.plugins.NetPluginEvent")]

	use namespace flash_proxy;

	public dynamic class RemoteAmfService extends Proxy implements IEventDispatcher, IMXMLSupport, IDisposable
	{
		/**
		 * @private
		 */
		protected var _nc:IAMFConnection;

		/**
		 * @private
		 */
		protected var _service:String;

		/**
		 * @private
		 */
		protected var _remoteMethods:Dictionary = new Dictionary();

		/**
		 * @private
		 */
		protected var _defaultMethods:Array;

		/**
		 * @private
		 */
		protected var _isPendingRequest:Boolean = false;

		/**
		 * @private
		 */
		protected var _requests:Dictionary = new Dictionary();

		private var _reqCount:int = 0;

		private static var _CALL_UID:int = 0;

		/**
		 * Determine execute all request in queue after error occurs.
		 */
		public var proceedAfterError:Boolean = true;

		public function RemoteAmfService()
		{
			defaultMethods();
			init();
		}

		/**
		 * @private
		 */
		protected var _dispatcher:IEventDispatcher;

		/**
		 * @private
		 */
		protected function init():void
		{
			_dispatcher = new EventDispatcher(this);
			silentIgnoreErrors = true;
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
		//              <------ SILENT IGNORE ERRORS ------>
		//---------------------------------------------------------------

		private var _silentIgnoreErrors:Boolean = false;

		public function get silentIgnoreErrors():Boolean
		{
			return _silentIgnoreErrors;
		}

		public function set silentIgnoreErrors(value:Boolean):void
		{
			_silentIgnoreErrors = value;
			if (value) registerErrorEvents();
			else removeErrorEvents();
		}

		protected function registerErrorEvents():void
		{
			addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
		}

		protected function removeErrorEvents():void
		{
			removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			removeEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
		}

		protected function onIOError(ev:IOErrorEvent):void
		{
		}

		protected function onSecurityError(ev:SecurityErrorEvent):void
		{
		}

		protected function onStatus(e:HTTPStatusEvent):void
		{

		}

		//---------------------------------------------------------------
		//              	<------ CURSORS ------>
		//---------------------------------------------------------------

		/**
		 * @private
		 */
		protected var _showBusyCursor:Boolean = true;

		public function get showBusyCursor():Boolean
		{
			return _showBusyCursor;
		}

		public function set showBusyCursor(value:Boolean):void
		{
			try
			{ if (_showBusyCursor && !value) CursorManager.removeBusyCursor();} catch (e:Error)
			{ }

			_showBusyCursor = value;
		}

		/**
		 * @private
		 */
		protected static var _currentCursorID:int = -1;

		protected function showCursor():void
		{
			if (_currentCursorID != -1) removeCursor();

			if (_showBusyCursor)
			{
				try
				{
					CursorManager.setBusyCursor();
					_currentCursorID = CursorManager.currentCursorID;
				} catch (e:Error)
				{ }
			}
		}

		/**
		 * Method implemented because standard CursorManager.removeBusyCursor()
		 * doesn't work.
		 */
		protected function removeCursor():void
		{
			try
			{ if (_showBusyCursor) CursorManager.removeCursor(_currentCursorID);} catch (e:Error)
			{ }
			_currentCursorID = -1;
		}

		//---------------------------------------------------------------
		//              <------ CACHE MANAGER ------>
		//---------------------------------------------------------------

		protected var _cacheManager:IResponseCacheManager;

		public function get cacheManager():IResponseCacheManager
		{
			return _cacheManager;
		}

		public function set cacheManager(value:IResponseCacheManager):void
		{
			_cacheManager = value;
		}

		//---------------------------------------------------------------
		//              <------ DEVELOPER INTERFACE METHODS ------>
		//---------------------------------------------------------------

		private function defaultMethods():void
		{
			_defaultMethods = [
				"toString",
				"toLocaleString",
				"valueOf"
			];
		}

		//---------------------------------------------------------------
		//              <------ CONCURRENCY ------>
		//---------------------------------------------------------------

		/**
		 * @private
		 */
		protected var _concurrency:String = RequestConcurrency.QUEUE;

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
		 * @see rnlib.net.RequestConcurrency
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

		//---------------------------------------------------------------
		//              		<------ QUEUE ------>
		//---------------------------------------------------------------

		/**
		 * @private
		 */
		private var _queue:IQueue = new PriorityQueue();

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
		 * Add remote method to dynamic invoke at runtime.
		 * <p>If method is already registered re adding method on this same name override last one.</p>
		 *
		 * @param name Name of remote method to invoke
		 * @param result Result handler
		 * @param fault Fault handler
		 * @param cacheRule
		 *
		 * @example The following code show how use addMethod()
		 * <listing version="3.0">
		 * var ras : RemoteAmfService = new RemoteAmfService();
		 * ras.endpoint = "http://example.com/gateway";
		 * ras.service = "MyExampleService";
		 *
		 * ras.addMethod("myRemoteFunction",resultCallback,faultCallback);
		 * ras.myRemoteFunction(); // this will invoke remote method "myRemoteFunction" on remote service "MyExampleService"
		 *
		 * // or you can also send parameters to remote method as shown below
		 * ras.myRemoteFunction("param1",2,{name:"x",url:"http://example.com"}); // or more complex structures
		 * </listing>
		 *
		 * @see #removeMethod()
		 */
		public function addMethod(name:String, result:Function = null, fault:Function = null, cacheRule:ICacheRule = null):void
		{
			var vo:MethodHelperVO = _remoteMethods[name];

			if (!vo || vo.mockGenerationFunc === null)
			{
				removeMethod(name);
				vo = new MethodHelperVO(name);
			}

			vo.cacheRule = cacheRule;
			vo.result = result || _result;
			vo.fault = fault || _fault;

			_remoteMethods[name] = vo
		}

		/**
		 * Mock method registered in service
		 * @param name Name of remote function to mock
		 * @param mockFunc Reference to function witch return mock data in form of array with 3 values
		 * <ul>Values of array:
		 * <li><code>Boolean</code> - if <code>true</code> call result, otherwise call fault.</li>
		 * <li><code>uint</code> - interval to responde. If 0 call without interval.</li>
		 * <li><code>Array</code> of arguments to pass as result.</li>
		 * </ul>
		 */
		public function addMockMethod(name:String, mockFunc:Function):void
		{
			var vo:MethodHelperVO = _remoteMethods[name];

			if (!vo)
				vo = new MethodHelperVO(name);
			vo.mockGenerationFunc = mockFunc;
			vo.result ||= _result;
			vo.fault ||= _fault;

			_remoteMethods[name] = vo
		}

		/**
		 * Remove remote method to dynamic invoke at runtime
		 * @param name
		 *
		 * @example The following code show how use removeMethod()
		 * <listing version="3.0">
		 * var ras : RemoteAmfService = new RemoteAmfService();
		 * ras.endpoint = "http://example.com/gateway";
		 * ras.service = "MyExampleService";
		 *
		 * ras.addMethod("myRemoteFunction",resultCallback,faultCallback);
		 * ras.addMethod("mySecondRemoteFunction",resultCallback,faultCallback);
		 *
		 * ras.myRemoteFunction(); // ok
		 * ras.mySecondRemoteFunction(); // ok
		 *
		 * ras.removeMethod("mySecondRemoteFunction");
		 * ras.mySecondRemoteFunction(); // throw Error
		 * </listing>
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

		/**
		 * @private
		 */
		protected var _isPaused:Boolean = false;

		/**
		 * Pause execute requests in queue. Please notice that method take effect
		 * only then concurrency is set to <code>RequestConcurrency.QUEUE</code>
		 *
		 * @see #concurrency
		 * @see rnlib.net.RequestConcurrency#QUEUE
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
		 * @see rnlib.net.RequestConcurrency#QUEUE
		 */
		public function resume():void
		{
			_isPaused = false;

			if (!_isPendingRequest && queue && queue.length > 0)
				callRemoteMethod(_queue.getItem());
		}

		//---------------------------------------------------------------
		//          <------ MANAGE SERVICE AND ENDPOINT ------>
		//---------------------------------------------------------------

		/**
		 * Declare service for remote calls. If not set all calls
		 * of remote method will be interpret as calling global
		 * remote methods and not method of remote service.
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
		 * @private
		 */
		protected var _endpoint:String;

		/**
		 * AMF endpoint.
		 * @example endpoint = "http://myhost.com/amf"
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
		 * @private
		 */
		protected var _result:Function;

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
		 * @private
		 */
		protected var _fault:Function;

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
		//              <------ SET CREDENTIALS ------>
		//---------------------------------------------------------------

		/**
		 * Set credentials
		 * @param user user name
		 * @param password password
		 */
		public function setCredentials(user:String, password:String):void
		{
			removeHeader("Credentials");
			addHeader("Credentials", false, {userid: user, password: password});
		}

		//---------------------------------------------------------------
		//          <------ PART OF PROXY BEHAVIOR ------>
		//---------------------------------------------------------------

		/**
		 * Method which check if is registered Plugin for given PluginVO
		 * @param rest
		 * @return <code>-1</code> if not found PluginVO, <code>1</code> if founded PluginVO
		 * have registered Plugin or <code>0</code> if PluginVO is not acceptable by any
		 * registered Plugin
		 */
		protected function testParamsRemoteMethod(...rest):INetPluginVO
		{
			if (!rest) return null;

			for (var i:int = 0; i < rest.length; i++)
			{
				var param:Object = rest[i];

				if (param is INetPluginVO)
				{
					var vo:INetPluginVO = param as INetPluginVO;

					if (!pluginVOisSupported(vo))
						throw new ArgumentError("Not found associated INetPlugin with given IPluginVO");

					rest.splice(i, 1);
					if (rest.length > 0)
						vo.args = vo.args ? vo.args.concat(rest) : rest;

					return vo;
				}
			}

			return null;
		}

		/**
		 * Method responsible for transparent call remote methods
		 * @param name
		 * @param rest
		 * @return
		 */
		override flash_proxy function callProperty(name:*, ...rest):*
		{
			if (name is QName) name = QName(name).localName;

			var hasProp:Boolean = hasOwnProperty(name);
			if (hasProp && _remoteMethods[name])
			{
				if (!_endpoint)
					throw new Error("Endpoint not set");

				var pluginVO:INetPluginVO = testParamsRemoteMethod.apply(this, rest) as INetPluginVO;

				var mvo:MethodHelperVO = _remoteMethods[name]; // dictionary of registered methods
				var vo:MethodVO = new MethodVO();
				vo.uid = _CALL_UID++;
				vo.name = name;
				vo.args = pluginVO ? pluginVO : rest;
				vo.result = mvo.result;
				vo.fault = mvo.fault;
				vo.queue = _queue;

				var request:AMFRequest = new AMFRequest(vo.uid);
				vo.request = request;
				request.updateQueue = vo.updateQueue;
				if (mvo.cacheRule)
				{
					request.cacheID = mvo.cacheRule.resolveID(name, vo.uid, rest);
					request.cacheTrigger = mvo.cacheRule.policy || CacheRuleConstants.POLICY_NEVER;
				}

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
				return request;
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

		/**
		 * @private
		 * @param name
		 * @param value
		 */
		override flash_proxy function setProperty(name:*, value:*):void
		{
			if (hasOwnProperty(name))
				super.flash_proxy::setProperty(name, value);
		}

		/**
		 * @private
		 * @param name
		 * @return
		 */
		override flash_proxy function getProperty(name:*):*
		{
			if (hasOwnProperty(name))
				return super.flash_proxy::getProperty(name);

			return undefined;
		}

		/**
		 * @private
		 * @param name
		 * @return
		 */
		override flash_proxy function hasProperty(name:*):Boolean
		{
			if (_defaultMethods.lastIndexOf(name) >= 0)
				return true;

			return Boolean(_remoteMethods[name]);
		}

		//---------------------------------------------------------------
		//              <------ CONCURRENCY METHODS ------>
		//---------------------------------------------------------------

		/**
		 * @private
		 * @param vo
		 */
		protected function concurrencyQueue(vo:MethodVO):void
		{
			if (_isPendingRequest || _isPaused)
				_queue.push(vo);
			else
				callAsyncRemoteMethod(vo);
		}

		/**
		 * @private
		 * @param vo
		 */
		protected function concurrencyLast(vo:MethodVO):void
		{
			ignoreAllPendingRequests(false);
			callAsyncRemoteMethod(vo);
		}

		/**
		 * @private
		 * @param vo
		 */
		protected function concurrencySingle(vo:MethodVO):void
		{
			ignoreAllPendingRequests(true);
			callAsyncRemoteMethod(vo);
		}

		/**
		 * @private
		 * @param vo
		 */
		protected function concurrencyMultiple(vo:MethodVO):void
		{
			if (_maxConnections && _activeConnections >= _maxConnections)
			{
				_queue.push(vo);
				return;
			}

			callAsyncRemoteMethod(vo);
		}

		//---------------------------------------------------------------
		//              <------ MAX CONNECTIONS ------>
		//---------------------------------------------------------------

		protected var _activeConnections:uint;

		private var _maxConnections:uint = 0;

		public function get maxConnections():uint
		{
			return _maxConnections;
		}

		public function set maxConnections(value:uint):void
		{
			_maxConnections = value;
		}

		//---------------------------------------------------------------
		//              <------ CALLING REMOTE SERVICE ------>
		//---------------------------------------------------------------

		/**
		 * @private
		 * Identifier asynchronous caller
		 */
		protected var _asyncCallerID:Dictionary = new Dictionary();

		/**
		 * Make truly asynchronous calling remote method
		 * @param vo
		 */
		protected function callAsyncRemoteMethod(vo:MethodVO):void
		{
			_activeConnections += 1;
			_isPendingRequest = true;
			_asyncCallerID[vo] = setTimeout(callSyncRemoteMethod, 1, vo);
		}

		/**
		 * Handler for asynchronous call remote method cleaning up all mess.
		 * Method never should be call directly by developer.
		 * @param vo
		 */
		protected function callSyncRemoteMethod(vo:MethodVO):void
		{
			clearTimeout(_asyncCallerID[vo]);
			delete _asyncCallerID[vo];

			callRemoteMethod(vo);
		}

		/**
		 * Separator.
		 *
		 * @default "."
		 */
		public var separator:String = ".";

		/**
		 * Invoke register remote method
		 * @param vo
		 * @param plugin
		 */
		protected function callRemoteMethod(vo:MethodVO, plugin:INetPlugin = null):void
		{
			_isPendingRequest = true;
			var rm:ResultMediatorVO = prepareResultMediator(vo);
			var cacheID:Object = vo.request.cacheID;

			if (checkAndExecuteIfMock(rm, vo.args as Array)) return;

			if (cacheManager &&
					vo.request.cacheTrigger == CacheRuleConstants.POLICY_BEFORE_REQUEST &&
					cacheID && cacheManager.isCached(cacheID))
			{
				rm = prepareResultMediator(vo);
				onResult(cacheManager.getResponse(cacheID), rm.name, rm.id, rm.uid);
				return;
			}

			if (vo.args is INetPluginVO)
			{
				waitForPlugin(vo);
				return;
			}

			if (plugin is INetMultipartPlugin)
			{
				rm.plugin = plugin;
				rm.internalFaultHandler = onPluginFault;
				rm.internalResultHandler = onPluginResult;
			}
			else
			{
				rm.internalFaultHandler = onFault;
				rm.internalResultHandler = onResult;
			}

			var fullName:String = _service ? _service + separator + vo.name : vo.name;
			var args:Array = [fullName, rm.result, rm.fault];

			rm.request.requestSend = true;
			_nc.call.apply(_nc, args.concat(vo.args));

			showCursor();
		}

		/**
		 * Method responsible for check request if is mocked.
		 * @param vo
		 * @param userArgs
		 * @return
		 */
		protected function checkAndExecuteIfMock(vo:ResultMediatorVO, userArgs:Array):Boolean
		{
			var h:MethodHelperVO = _remoteMethods[vo.name];
			vo.internalFaultHandler = onFault;
			vo.internalResultHandler = onResult;

			// this remote method is not mark as mock
			if (h.mockGenerationFunc === null) return false;

			/**
			 * Value object created by mock generate function.
			 * Contains all necessary values to call response method.
			 */
			var mockVO:MockResponseVO = h.mockGenerationFunc.apply(null, userArgs);

			if (mockVO.interval == 0)
				executeMockImpl(vo, mockVO);
			else
				setTimeout(executeMockImpl, mockVO.interval, vo, mockVO);

			return true;
		}

		/**
		 * Call response handlers with passed data.
		 * @param vo
		 * @param mock
		 */
		protected function executeMockImpl(vo:ResultMediatorVO, mock:MockResponseVO):void
		{
			if (mock.success)
				onResult(mock.responseArgs, vo.name, vo.id, vo.uid);
			else
				onFault(mock.responseArgs, vo.name, vo.id, vo.uid);
		}

		/**
		 * Encapsulate rewriting MethodVO object on ResultMediatorVO
		 * and registering new instance in _requests Dictionary
		 *
		 * @param vo MethodVO to rewrite on ResultMediatorVO
		 * @return new instance of ResultMediatorVO
		 */
		protected function prepareResultMediator(vo:MethodVO):ResultMediatorVO
		{
			var rm:ResultMediatorVO = new ResultMediatorVO();
			rm.uid = vo.uid;
			rm.id = _reqCount++;
			rm.name = vo.name;
			rm.resultHandler = vo.result; // force call currently specified method handler
			rm.faultHandler = vo.fault; // force call currently specified method handler
			rm.request = vo.request;

			_requests[rm.id] = rm;

			return rm;
		}

		//---------------------------------------------------------------
		//			<------ EXECUTE PLUGINS JUST IN TIME ------>
		//---------------------------------------------------------------

		/**
		 * End of lifecycle single method call notifying about fault
		 * @param vo
		 * @param data
		 */
		protected function callFinalFault(vo:MethodVO, data:Object = null):void
		{
			var rm:ResultMediatorVO = prepareResultMediator(vo);
			vo.dispose();

			onFault(data, rm.name, rm.id, rm.uid);
		}

		/**
		 * Global handler for IMultipartPlugins
		 * @param plugin
		 * @param r Object with result
		 */
		protected function onPluginResult(plugin:INetMultipartPlugin, r:Object):void
		{
			try
			{ plugin.onResult(r);}
			catch (e:Error)
			{
				disposePlugin(plugin);
				var vo1:MethodVO = _plugins[plugin];
				if (vo1) callFinalFault(vo1, e);
			}

			// check if plugin wasn't disposed
			var vo2:MethodVO = _plugins[plugin];
			if (vo2)
			{
				try
				{ plugin.next();}
				catch (e:Error)
				{
					disposePlugin(plugin);
					var vo3:MethodVO = _plugins[plugin];
					if (vo3) callFinalFault(vo3, e);
				}
			}
		}

		/**
		 * Global handler for IMultipartPlugins
		 * @param plugin
		 * @param f Object with fault information
		 */
		protected function onPluginFault(plugin:INetMultipartPlugin, f:Object):void
		{
			try
			{ plugin.onFault(f);}
			catch (e:Error)
			{
				disposePlugin(plugin);
				var vo1:MethodVO = _plugins[plugin];
				if (vo1) callFinalFault(vo1, e);
			}

			// check if plugin wasn't disposed
			var vo2:MethodVO = _plugins[plugin];
			if (vo2)
			{
				try
				{ plugin.next();}
				catch (e:Error)
				{
					disposePlugin(plugin);
					var vo3:MethodVO = _plugins[plugin];
					if (vo3) callFinalFault(vo3, e);
				}
			}
		}

		/**
		 * @private
		 * Dictionary of IPlugins
		 */
		protected var _plugins:Dictionary = new Dictionary();

		/**
		 * Plugin can execute asynchronously methods so we wait until dispatch event
		 * that is ready to go
		 * @param vo
		 */
		protected function waitForPlugin(vo:MethodVO):void
		{
			var pluginVO:INetPluginVO = vo.args as INetPluginVO;
			if (!pluginVO) return;

			var plugin:INetPlugin = matchPlugin(pluginVO);
			plugin.dispatcher = this;

			dispatchEvent(new NetPluginEvent(NetPluginEvent.PLUGIN_CREATED, plugin));

			registerPluginHandlers(plugin);
			_plugins[plugin] = vo;

			try
			{
				plugin.init(pluginVO);
				dispatchEvent(new NetPluginEvent(NetPluginEvent.PLUGIN_INITIALIZED, plugin));

			}
			catch (e:Error)
			{
				var vo1:MethodVO = _plugins[plugin];
				disposePlugin(plugin);
				if (vo1)
				{
					callFinalFault(vo1, e);
					vo1.dispose();
				}
			}

			pluginVO = null;
			plugin = null;
		}

		/**
		 * Encapsulate disposing plugin
		 * @param plugin INetPlugin to dispose
		 */
		protected function disposePlugin(plugin:INetPlugin):void
		{
			_plugins[plugin] = null;
			delete _plugins[plugin];

			removePluginHandlers(plugin);

			dispatchEvent(new NetPluginEvent(NetPluginEvent.PREPARE_TO_DISPOSE, plugin));
			try
			{ plugin.dispose();} catch (e:Error)
			{ }

			dispatchEvent(new NetPluginEvent(NetPluginEvent.PLUGIN_DISPOSED, plugin));
		}

		/**
		 * Encapsulate register plugin handlers
		 * @param plugin
		 */
		protected function registerPluginHandlers(plugin:INetPlugin):void
		{
			plugin.addEventListener(NetPluginEvent.CANCEL, onPluginCancel, false, 0, true);

			if (plugin is INetMultipartPlugin)
			{
				plugin.addEventListener(NetPluginEvent.READY, onMultipartPluginReady, false, 0, true);
				plugin.addEventListener(NetPluginEvent.COMPLETE, onMultipartPluginComplete, false, 0, true);
			}
			else
			{
				plugin.addEventListener(NetPluginEvent.READY, onPluginComplete, false, 0, true);
				plugin.addEventListener(NetPluginEvent.COMPLETE, onPluginComplete, false, 0, true);
			}
		}

		/**
		 * Encapsulate remove plugin handlers
		 * @param plugin
		 */
		protected function removePluginHandlers(plugin:INetPlugin):void
		{
			plugin.removeEventListener(NetPluginEvent.CANCEL, onPluginCancel, false);

			if (plugin is INetMultipartPlugin)
			{
				plugin.removeEventListener(NetPluginEvent.READY, onMultipartPluginReady, false);
				plugin.removeEventListener(NetPluginEvent.COMPLETE, onMultipartPluginComplete, false);
			}
			else
			{
				plugin.removeEventListener(NetPluginEvent.READY, onPluginComplete, false);
				plugin.removeEventListener(NetPluginEvent.COMPLETE, onPluginComplete, false);
			}
		}

		/**
		 * If plugin cancel operation is forced call fault handler
		 * @param e
		 */
		private function onPluginCancel(e:NetPluginEvent):void
		{
			var plugin:INetPlugin = e.target as INetPlugin;
			var vo:MethodVO = _plugins[plugin];
			disposePlugin(plugin);

			var rm:ResultMediatorVO = prepareResultMediator(vo);
			vo.dispose();

			onFault(e.data, rm.name, rm.id, rm.uid);
		}

		/**
		 * We will proceed only on ready/complete event
		 * @param e
		 */
		private function onPluginComplete(e:NetPluginEvent):void
		{
			var plugin:INetPlugin = e.target as INetPlugin;
			var vo:MethodVO = _plugins[plugin];

			try
			{ vo.args = plugin.args;}
			catch (e:Error)
			{
				disposePlugin(plugin);
				callFinalFault(vo, e);
				vo.dispose();
				return;
			}

			disposePlugin(plugin);
			callRemoteMethod(vo);
			vo.dispose();
		}

		/**
		 * MultipartPlugin is ready to share arguments for remote method
		 * @param e
		 */
		protected function onMultipartPluginReady(e:NetPluginEvent):void
		{
			var plugin:INetMultipartPlugin = e.target as INetMultipartPlugin;
			var vo:MethodVO = _plugins[plugin];
			vo = vo.clone();

			try
			{ vo.args = plugin.args;}
			catch (e:Error)
			{
				disposePlugin(plugin);
				callFinalFault(vo, e);
				vo.dispose();
				return;
			}

			callRemoteMethod(vo, plugin);
			vo.dispose();
		}

		/**
		 * MultipartPlugin finish successfully his work
		 * @param e
		 */
		protected function onMultipartPluginComplete(e:NetPluginEvent):void
		{
			var plugin:INetMultipartPlugin = e.target as INetMultipartPlugin;
			var vo:MethodVO = _plugins[plugin];
			disposePlugin(plugin);

			var rm:ResultMediatorVO = prepareResultMediator(vo);
			vo.dispose();

			onResult(e.data, rm.name, rm.id, rm.uid);
		}

		//---------------------------------------------------------------
		//              <------ GLOBAL RESPONSE HANDLERS ------>
		//---------------------------------------------------------------

		/**
		 * Global internal result handler
		 * @param result Response from server
		 * @param name Name remote method
		 * @param id Request id
		 * @param uid Unique request id
		 */
		protected function onResult(result:Object, name:String, id:int, uid:int):void
		{
			removeCursor();

			var vo:ResultMediatorVO = _requests[id];

			// push response into cache if is mark as to cache and not cached already
			var cacheID:Object = vo.request.cacheID;
			if (cacheManager && cacheID)
			{
				if (vo.request.cacheTrigger == CacheRuleConstants.POLICY_AFTER_REQUEST && !cacheManager.isCached(cacheID))
					cacheManager.setResponse(cacheID, result);
				else if (vo.request.cacheTrigger == CacheRuleConstants.POLICY_BEFORE_REQUEST)
					cacheManager.setResponse(cacheID, result);
			}

			var res:Array = [result];
			if (vo.request.extraResult)
			{
				res = res.concat(vo.request.extraResult);
			}

			if (vo.resultHandler != null)
				vo.resultHandler.apply(null, res);
			else if (this.result != null)
				this.apply(null, res);

			dispatchEvent(new AMFEvent(AMFEvent.RESULT, uid, res.length == 1 ? res.shift() : res));

			_isPendingRequest = false;

			_requests[id] = null;
			delete _requests[id];
			vo.request.dispose();
			vo.dispose();
			_activeConnections -= 1;

			if (_queue && _queue.length > 0 && !_isPaused)
			{
				_activeConnections += 1;
				callRemoteMethod(_queue.getItem());
			}
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
		 * @param uid unique id
		 */
		protected function onFault(fault:Object, name:String, id:int, uid:int):void
		{
			removeCursor();

			var vo:ResultMediatorVO = _requests[id];

			// cache fallback
			var cacheID:Object = vo.request.cacheID;
			if (cacheManager &&
					cacheID &&
					vo.request.cacheTrigger == CacheRuleConstants.POLICY_AFTER_REQUEST &&
					cacheManager.isCached(cacheID))
			{
				onResult(cacheManager.getResponse(cacheID), name, id, uid);
				return;
			}

			var res:Array = [AMFErrorVO.rewrite(fault)];
			if (vo.request.extraFault)
			{
				res = res.concat(vo.request.extraFault);
			}

			if (vo.faultHandler != null)
				vo.faultHandler.apply(null, res);
			else if (this.fault != null)
				this.fault.apply(null, res);

			dispatchEvent(new AMFEvent(AMFEvent.FAULT, uid, res.length == 1 ? res.shift() : res));

			_isPendingRequest = false;

			_requests[id] = null;
			delete _requests[id];
			vo.request.dispose();
			vo.dispose();
			_activeConnections -= 1;

			if (_queue && _queue.length > 0 && !_isPaused && continueAfterFault)
			{
				_activeConnections += 1;
				callRemoteMethod(_queue.getItem());
			}
		}

		//---------------------------------------------------------------
		//              <------ IGNORE PENDING REQUESTS ------>
		//---------------------------------------------------------------

		/**
		 * Ignore all pending requests
		 * @param callFault
		 */
		protected function ignoreAllPendingRequests(callFault:Boolean = true):void
		{
			for (var key:Object in _asyncCallerID)
			{
				clearTimeout(_asyncCallerID[key]);
				delete _asyncCallerID[key];
			}

			disconnect();
			for each (var vo:ResultMediatorVO in _requests)
			{
				if (callFault && vo.faultHandler != null)
					vo.faultHandler("Ignore by user");
				_requests[vo.id] = null;
				delete _requests[vo.id];
				vo.dispose();
			}
			_isPendingRequest = false;
			_activeConnections = 0;

			removeCursor();
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

		//---------------------------------------------------------------
		//              <------ PLUGINS ------>
		//---------------------------------------------------------------

		[ArrayElementType("rnlib.net.plugins.INetPluginFactory")]
		/**
		 * @private
		 */
		protected var _pluginsFactories:Array;

		/**
		 * Collection of plugins associated with this object
		 */
		public function get pluginsFactories():Array
		{
			if (!_pluginsFactories) return null;
			return _pluginsFactories.concat(null);
		}

		public function set pluginsFactories(value:Array):void
		{
			if (value)
				_pluginsFactories = value.filter(filterPlugins);
			else
				_pluginsFactories = null;
		}

		private static function filterPlugins(item:*, index:int, array:Array):Boolean
		{
			return item is INetPluginFactory;
		}

		/**
		 * Check if passed ValueObject is supported by any registered INetPlugin
		 * @param vo
		 * @return
		 */
		protected function pluginVOisSupported(vo:INetPluginVO):Boolean
		{
			for each (var factory:INetPluginFactory in _pluginsFactories)
			{
				if (factory.isSupportVO(vo)) return true;
			}

			return false;
		}

		/**
		 * Find matching plugin to passed ValueObject
		 * @param vo
		 * @return
		 */
		protected function matchPlugin(vo:INetPluginVO):INetPlugin
		{
			for each (var factory:INetPluginFactory in _pluginsFactories)
			{
				if (factory.isSupportVO(vo)) return factory.newInstance();
			}

			return null;
		}

		//---------------------------------------------------------------
		//              <------ TO STRING ------>
		//---------------------------------------------------------------

		public function toString():String
		{
			var methods:String = "";
			for (var name:String in _remoteMethods)
				methods += "\n\t\t" + name;

			var str:String = "[RemoteAmfService]"
					+ "\n\t* endpoint:\t" + (_endpoint || "--not set--")
					+ "\n\t* service:\t" + (_service || "--not set--")
					+ "\n\t* concurrency:\t" + (_concurrency || "--not set--")
					+ "\n\t* register plugins:\t" + (_pluginsFactories || "[]")
					+ "\n\t* registered methods:" + methods
			;
			return str;
		}

		public function toLocaleString():Object
		{
			return toString();
		}

		//---------------------------------------------------------------
		//              <------ INTERFACE DISPOSABLE ------>
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
				delete _remoteMethods[vo.name];
				vo.dispose();
			}

			for each (var factory:INetPluginFactory in _pluginsFactories)
			{
				factory.dispose();
			}
			_pluginsFactories = null;

			if (_queue)
			{
				_queue.dispose();
			}

			_isPendingRequest = false;
			_remoteMethods = new Dictionary();
			_requests = new Dictionary();
			_plugins = new Dictionary();
		}
	}
}

import rnlib.interfaces.IDisposable;
import rnlib.net.amf.AMFRequest;
import rnlib.net.cache.rules.ICacheRule;
import rnlib.net.plugins.INetMultipartPlugin;
import rnlib.net.plugins.INetPlugin;

/**
 * @private
 */
class MethodHelperVO implements IDisposable
{
	public var name:String;
	public var result:Function;
	public var fault:Function;
	public var cacheRule:ICacheRule;
	/**
	 * If function have to be mock add here reference to mock generation function
	 */
	public var mockGenerationFunc:Function = null;

	public function MethodHelperVO(name:String = null)
	{
		this.name = name;
	}

	public function dispose():void
	{
		name = null;
		result = null;
		fault = null;
		cacheRule = null;
	}
}

/**
 * @private
 */
class ResultMediatorVO implements IDisposable
{
	public var uid:int;
	public var id:int;
	public var name:String;
	public var plugin:INetPlugin;
	public var request:AMFRequest;

	public var resultHandler:Function;
	public var internalResultHandler:Function;

	public function result(r:Object):void
	{
		if (plugin is INetMultipartPlugin)
		{
			internalResultHandler(plugin, r);
		}
		else
			internalResultHandler(r, name, id, uid);
		dispose();
	}

	public var faultHandler:Function;
	public var internalFaultHandler:Function;

	public function fault(f:Object):void
	{
		if (plugin is INetMultipartPlugin)
		{
			internalFaultHandler(plugin, f);
		}
		else
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
		plugin = null;
		request = null;
	}
}
