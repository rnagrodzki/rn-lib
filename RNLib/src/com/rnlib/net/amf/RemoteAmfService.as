/***************************************************************************************************
 Copyright (c) 2012. Rafał Nagrodzki (rafal[dot]nagrodzki[dot]dev[at]gmail[dot]com)
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
	import com.rnlib.net.*;
	import com.rnlib.net.amf.connections.AMFULConnection;
	import com.rnlib.net.amf.connections.IAMFConnection;
	import com.rnlib.net.amf.processor.AMFHeader;
	import com.rnlib.net.plugins.INetMultipartPlugin;
	import com.rnlib.net.plugins.INetPlugin;
	import com.rnlib.net.plugins.INetPluginFactory;
	import com.rnlib.net.plugins.INetPluginVO;
	import com.rnlib.net.plugins.NetPluginEvent;
	import com.rnlib.queue.IQueue;
	import com.rnlib.queue.PriorityQueue;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.clearTimeout;
	import flash.utils.flash_proxy;
	import flash.utils.setTimeout;

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

	/**
	 * Dispatch then new plugin is created
	 */
	[Event(name="pluginCreated", type="com.rnlib.net.plugins.NetPluginEvent")]

	/**
	 * Dispatch then plugin is disposed
	 */
	[Event(name="pluginDisposed", type="com.rnlib.net.plugins.NetPluginEvent")]

	use namespace flash_proxy;

	public dynamic class RemoteAmfService extends Proxy implements IEventDispatcher, IMXMLSupport, IDisposable
	{

		protected var _nc:IAMFConnection;

		protected var _service:String;

		protected var _remoteMethods:Dictionary = new Dictionary();

		protected var _defaultMethods:Array;

		protected var _isPendingRequest:Boolean = false;

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

		protected var _dispatcher:IEventDispatcher;

		protected function init():void
		{
			_dispatcher = new EventDispatcher(this);
			connection = new AMFULConnection();
		}

		//--------------------------------------------md-------------------
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
		//              	<------ CURSORS ------>
		//---------------------------------------------------------------

		protected var _showBusyCursor:Boolean = true;

		public function get showBusyCursor():Boolean
		{
			return _showBusyCursor;
		}

		public function set showBusyCursor(value:Boolean):void
		{
			if (_showBusyCursor && !value) CursorManager.removeBusyCursor();

			_showBusyCursor = value;
		}

		protected static var _currentCursorID:int = -1;

		protected function showCursor():void
		{
			if (_currentCursorID != -1) removeCursor();

			if (_showBusyCursor)
			{
				CursorManager.setBusyCursor();
				_currentCursorID = CursorManager.currentCursorID;
			}
		}

		/**
		 * Method implemented because standard CursorManager.removeBusyCursor()
		 * doesn't work.
		 */
		protected function removeCursor():void
		{
			if (_showBusyCursor) CursorManager.removeCursor(_currentCursorID);
			_currentCursorID = -1;
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

		//---------------------------------------------------------------
		//              		<------ QUEUE ------>
		//---------------------------------------------------------------

		private var _queue:IQueue = new PriorityQueue();

		/**
		 * Property to change default queue class
		 */
		public function get queue():IQueue
		{
			if (!_queue) return null;
			return _queue.clone();
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
		 *     var ras : RemoteAmfService = new RemoteAmfService();
		 *     ras.endpoint = "http://example.com/gateway";
		 *     ras.service = "MyExampleService";
		 *     ras.addMethod("myRemoteFunction",resultCallback,faultCallback);
		 *     ras.myRemoteFunction(); // this will invoke remote method "myRemoteFunction" on remote service "MyExampleService"
		 *     // or you can also send parameters to remote method as shown below
		 *     ras.myRemoteFunction("param1",2,{name:"x",url:"http://example.com"}); // or more complex structures
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
		 *     var ras : RemoteAmfService = new RemoteAmfService();
		 *     ras.endpoint = "http://example.com/gateway";
		 *     ras.service = "MyExampleService";
		 *     ras.addMethod("myRemoteFunction",resultCallback,faultCallback);
		 *     ras.addMethod("mySecondRemoteFunction",resultCallback,faultCallback);
		 *     ras.myRemoteFunction(); // ok
		 *     ras.mySecondRemoteFunction(); // ok
		 *     ras.removeMethod("mySecondRemoteFunction");
		 *     ras.mySecondRemoteFunction(); // throw Error
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

		protected var _endpoint:String;

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
			var hasProp:Boolean = hasOwnProperty(name);
			if (hasProp && _remoteMethods[name])
			{
				if (!_endpoint)
					throw new Error("Endpoint not set");

				var pluginVO:INetPluginVO = testParamsRemoteMethod.apply(this, rest);

				var mvo:MethodHelperVO = _remoteMethods[name]; // dictionary of registered methods
				var vo:MethodVO = new MethodVO();
				vo.uid = _CALL_UID++;
				vo.name = name;
				vo.args = pluginVO ? pluginVO : rest;
				vo.result = mvo.result;
				vo.fault = mvo.fault;

				var request:AMFRequest = new AMFRequest();
				request.uid = vo.uid;
				vo.request = request;

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
				callAsyncRemoteMethod(vo);
		}

		protected function concurrencyLast(vo:MethodVO):void
		{
			ignoreAllPendingRequests(false);
			callAsyncRemoteMethod(vo);
		}

		protected function concurrencySingle(vo:MethodVO):void
		{
			ignoreAllPendingRequests(true);
			callAsyncRemoteMethod(vo);
		}

		protected function concurrencyMultiple(vo:MethodVO):void
		{
			callAsyncRemoteMethod(vo);
		}

		//---------------------------------------------------------------
		//              <------ CALLING REMOTE SERVICE ------>
		//---------------------------------------------------------------

		/**
		 * Identifier asynchronous caller
		 */
		protected var _asyncCallerID:int = -1;

		/**
		 * Make truly asynchronous calling remote method
		 * @param vo
		 */
		protected function callAsyncRemoteMethod(vo:MethodVO):void
		{
			if (_asyncCallerID != -1) clearTimeout(_asyncCallerID);

			_isPendingRequest = true;
			_asyncCallerID = setTimeout(callSyncRemoteMethod, 1, vo);
		}

		/**
		 * Handler for asynchronous call remote method cleaning up all mess.
		 * Method never should be call directly by developer.
		 * @param vo
		 */
		protected function callSyncRemoteMethod(vo:MethodVO):void
		{
			clearTimeout(_asyncCallerID);
			_asyncCallerID = -1;

			callRemoteMethod(vo);
		}

		/**
		 * Invoke register remote method
		 * @param vo
		 */
		protected function callRemoteMethod(vo:MethodVO, plugin:INetPlugin = null):void
		{
			_isPendingRequest = true;

			if (vo.args is INetPluginVO)
			{
				waitForPlugin(vo);
				return;
			}

			var rm:ResultMediatorVO = prepareResultMediator(vo);

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

			var fullName:String = _service ? _service + "." + vo.name : vo.name;
			var args:Array = [fullName, rm.result, rm.fault];

			rm.request.requestSend = true;
			_nc.call.apply(_nc, args.concat(vo.args));

			showCursor();
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
			{ plugin.init(pluginVO);}
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
		 */
		protected function onResult(result:Object, name:String, id:int, uid:int):void
		{
			removeCursor();

			var vo:ResultMediatorVO = _requests[id];

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
			vo.dispose();

			if (_concurrency == RequestConcurrency.QUEUE && _queue && _queue.length > 0 && !_isPaused)
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
			removeCursor();

			var vo:ResultMediatorVO = _requests[id];

			var res:Array = [fault];
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

			if (_concurrency == RequestConcurrency.QUEUE && _queue && _queue.length > 0 && !_isPaused && continueAfterFault)
				callRemoteMethod(_queue.item);
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
			if (_asyncCallerID != -1)
			{
				clearTimeout(_asyncCallerID);
				_asyncCallerID = -1;
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

		[ArrayElementType("com.rnlib.net.plugins.INetPluginFactory")]
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
			var str:String = "[RemoteAmfService]\n"
					+ "* endpoint:\t" + (_endpoint || "--not set--") + "\n"
					+ "* service:\t" + (_service || "--not set--") + "\n"
					+ "* concurrency:\t" + (_concurrency || "--not set--") + "\n"
					+ "* register plugins:\t" + (_pluginsFactories || "[]");

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

import com.rnlib.interfaces.IDisposable;
import com.rnlib.net.amf.AMFRequest;
import com.rnlib.net.plugins.INetMultipartPlugin;
import com.rnlib.net.plugins.INetPlugin;

class MethodHelperVO implements IDisposable
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
