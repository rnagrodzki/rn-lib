/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.connections
{
	import com.rnlib.interfaces.IDisposable;
	import com.rnlib.net.amf.AMFEvent;
	import com.rnlib.net.amf.processor.AMFHeader;
	import com.rnlib.net.amf.processor.AMFMessage;
	import com.rnlib.net.amf.processor.AMFPacket;
	import com.rnlib.net.amf.processor.AMFProcessor;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.ObjectEncoding;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;

	internal class AMFURLLoader extends EventDispatcher implements IDisposable
	{
		private var _loader:URLLoader = new URLLoader();

		/**
		 * Sequentially incremented counter used to generate a unique responseURI
		 * to match response messages to responders.
		 */
		protected var responseCounter:uint;

		public var amfHeaders:Array; // Array of AMFHeader

		public var id:uint;

		public function AMFURLLoader()
		{
			register();
		}

		private function register():void
		{
			_redispatcher = this;

			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
//			_loader.addEventListener("complete", onComplete, false, 0, true);
			_loader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
//			_loader.addEventListener("progress", onProgress, false, 0, true);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
//			_loader.addEventListener("ioError", onIOError, false, 0, true);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurity, false, 0, true);
//			_loader.addEventListener("securityError", onSecurity, false, 0, true);
		}

		//---------------------------------------------------------------
		//              <------ CONNECTION ------>
		//---------------------------------------------------------------

		/**
		 * URI of gateway
		 */
		public var url:String;

		private var _connected:Boolean;

		/**
		 * Determines whether a connection exists.
		 */
		public function get connected():Boolean
		{
			return _connected;
		}

		public function close():void
		{
			if (_loader)
				_loader.close();
		}

		public function dispose():void
		{
			_redispatcher = null;
			_result = null;
			_fault = null;
			_loader.removeEventListener(Event.COMPLETE, onComplete);
			_loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurity);
			_loader = null;
			_client = null;
			amfHeaders = null;
		}

		//---------------------------------------------------------------
		//              <------ REDISPATCHER ------>
		//---------------------------------------------------------------

		protected var _redispatcher:IEventDispatcher;

		/**
		 * If set class will dispatch native events of NetConnection.
		 * To prevent dispatching native events of NetConnection set <code>null</code>.
		 *
		 * @default this
		 */
		public function get redispatcher():IEventDispatcher
		{
			return _redispatcher;
		}

		public function set redispatcher(value:IEventDispatcher):void
		{
			_redispatcher = value;
		}

		//---------------------------------------------------------------
		//              <------ OBJECT ENCODING ------>
		//---------------------------------------------------------------

		private static var _defaultObjectEncoding:uint = ObjectEncoding.AMF3;

		/**
		 * The default object encoding for all AMFConnection instances. This
		 * controls which version of AMF is used during serialization. The default
		 * is AMF 3.
		 *
		 * @see #objectEncoding
		 * @see flash.net.ObjectEncoding
		 */
		public static function get defaultObjectEncoding():uint
		{
			return _defaultObjectEncoding;
		}

		public static function set defaultObjectEncoding(value:uint):void
		{
			_defaultObjectEncoding = value;
		}

		private var _objectEncoding:uint;
		private var objectEncodingSet:Boolean = false;

		/**
		 * The object encoding for this AMFConnection sets which AMF version to
		 * use during serialization. If set, this version overrides the
		 * defaultObjectEncoding.
		 *
		 * @see #defaultObjectEncoding
		 * @see flash.net.ObjectEncoding
		 */
		public function get objectEncoding():uint
		{
			if (!objectEncodingSet)
				return defaultObjectEncoding;

			return _objectEncoding;
		}

		public function set objectEncoding(value:uint):void
		{
			_objectEncoding = value;
			objectEncodingSet = true;
		}

		//---------------------------------------------------------------
		//              <------ CLIENT ------>
		//---------------------------------------------------------------

		private var _client:Object;

		/**
		 * A client can be configured to receive notification of AMF response
		 * headers. If the client instance defines a suitable function of the same
		 * name as an AMF response header it will be invoked. The value of the
		 * header will be passed as the only argument.
		 */
		public function get client():Object
		{
			return _client;
		}

		public function set client(value:Object):void
		{
			_client = value;
		}

		//---------------------------------------------------------------
		//              <------ CALLING REMOTE METHOD ------>
		//---------------------------------------------------------------

		private var _fault:Function;

		private var _result:Function;

		/**
		 *
		 * @param command
		 * @param result
		 * @param fault
		 * @param params
		 *
		 * @see AMFULConnection
		 */
		public function call(command:String, result:Function, fault:Function, ...params):void
		{
			_result = result;
			_fault = fault;

			var responseURI:String = getResponseURI();
			var request:AMFPacket = new AMFPacket(_defaultObjectEncoding);
			request.headers = amfHeaders;

			var message:AMFMessage = new AMFMessage(command, responseURI, params);
			request.messages.push(message);

			var data:ByteArray = AMFProcessor.encodeRequest(request);
			send(data);
		}

		protected function getResponseURI():String
		{
			var responseURI:String = "/" + responseCounter;
			responseCounter++;
			return responseURI;
		}

		private static const AMF_CONTENT_TYPE:String = "application/x-amf";

		protected function send(data:ByteArray):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			urlRequest.contentType = AMF_CONTENT_TYPE;
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = data;
			_loader.load(urlRequest);
		}

		//---------------------------------------------------------------
		//              <------ URL LOADER HANDLERS ------>
		//---------------------------------------------------------------

		private function onComplete(ev:Event):void
		{
			var data:ByteArray = _loader.data as ByteArray;
			var response:AMFPacket = AMFProcessor.decodeResponse(data);

			for each (var header:AMFHeader in response.headers)
			{
				try
				{
					var headerHandler:Function;
					if (client)
					{
						headerHandler = client[header.name];
						if (headerHandler != null)
						{
							headerHandler.apply(null, [header.data]);
						}
					}

					if (headerHandler == null && header.mustUnderstand)
					{
						// TODO: Report fault event?
					}
				}
				catch (e:Error)
				{
				}

				dispatchEvent(new AMFEvent(AMFEvent.HEADER, -1, header));
			}

			for each (var message:AMFMessage in response.messages)
			{
				var targetURI:String = message.targetURI;
				var separator:int = targetURI.indexOf("/", 1);
				var responseType:String = targetURI.substring(separator + 1);

				if (responseType == "onResult" && _result != null)
					_result(message.body);
				else if (responseType == "onStatus" && _fault != null)
					_fault(message.body);
			}

			dispatchEvent(ev);

			if (_redispatcher)
			{
				_redispatcher.dispatchEvent(ev);
			}

			dispose();
		}

		private function onProgress(event:ProgressEvent):void
		{
			if (_redispatcher)
			{ _redispatcher.dispatchEvent(event);}
		}

		private function onSecurity(event:SecurityErrorEvent):void
		{
			if (_redispatcher)
			{ _redispatcher.dispatchEvent(event);}

			dispose();
		}

		private function onIOError(event:IOErrorEvent):void
		{
			if (_redispatcher)
			{ _redispatcher.dispatchEvent(event);}

			dispose();
		}
	}
}
