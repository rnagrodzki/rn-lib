/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.connections
{
	import com.rnlib.net.amf.*;
	import com.rnlib.net.amf.processor.AMFHeader;
	import com.rnlib.net.amf.processor.AMFMessage;
	import com.rnlib.net.amf.processor.AMFPacket;
	import com.rnlib.net.amf.processor.AMFProcessor;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.ObjectEncoding;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;

	public class AMFURLLoaderConnection extends EventDispatcher
	{
		private var _loader:URLLoader = new URLLoader();

		/**
		 * Sequentially incremented counter used to generate a unique responseURI
		 * to match response messages to responders.
		 */
		protected var responseCounter:uint;

		private var _amfHeaders:Array; // Array of AMFHeader
		private var _client:Object;
		private var _connected:Boolean;
		private var _objectEncoding:uint;
		private var objectEncodingSet:Boolean = false;

		private static var _defaultObjectEncoding:uint = ObjectEncoding.AMF3;

		private static const AMF_CONTENT_TYPE:String = "application/x-amf";

		public function AMFURLLoaderConnection()
		{
			register();
		}

		private function register():void
		{
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, onLoaded, false, 0, true);
		}

		public var url:String;

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

		/**
		 * Determines whether a connection exists.
		 */
		public function get connected():Boolean
		{
			return _connected;
		}

		public function call(command:String, result:Function, fault:Function, ...params):void
		{
			_result = result;
			_fault = fault;

			var responseURI:String = getResponseURI();
			var request:AMFPacket = new AMFPacket(_defaultObjectEncoding);

			var message:AMFMessage = new AMFMessage(command, responseURI, params);
			request.messages.push(message);

			var data:ByteArray = AMFProcessor.encodeRequest(request);
			send(data);
		}

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

			return exists;
		}

		protected function getResponseURI():String
		{
			var responseURI:String = "/" + responseCounter;
			responseCounter++;
			return responseURI;
		}

		protected function send(data:ByteArray):void
		{
			var urlRequest:URLRequest = new URLRequest(url);
			urlRequest.contentType = AMF_CONTENT_TYPE;
			urlRequest.method = URLRequestMethod.POST;
			urlRequest.data = data;
			_loader.load(urlRequest);
		}

		private var _fault:Function;

		private var _result:Function;

		private function onLoaded(ev:Event):void
		{
			var data:ByteArray = _loader.data as ByteArray;
			var response:AMFPacket = AMFProcessor.decodeResponse(data);
			_result(response.messages.shift());

			dispatchEvent(ev);
		}
	}
}
