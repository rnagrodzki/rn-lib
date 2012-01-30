/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.ObjectEncoding;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;

	public class AMFConnection extends EventDispatcher
	{
		private var _loader:URLLoader = new URLLoader();

		/**
		 * Sequentially incremented counter used to generate a unique responseURI
		 * to match response messages to responders.
		 */
		protected var responseCounter:uint;

		public function AMFConnection()
		{
			register();

			registerClassAlias("vo.ByteArray",ByteArray);
		}

		private function register():void
		{
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, onLoaded, false, 0, true);
		}

		public var url:String;

		public function call(command:String, result:Function, fault:Function, ...params):void
		{
			_result = result;
			_fault = fault;

			var responseURI:String = getResponseURI();
			var request:AMFPacket = new AMFPacket(_defaultObjectEncoding);

			var message:AMFMessage = new AMFMessage(command, responseURI, params);
			request.messages.push(message);

			var data:ByteArray = encodeRequest(request);
			send(data);
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
			var response:AMFPacket = decodeResponse(data);
			_result(response.messages.shift());

			dispatchEvent(ev);
		}

		//--------------------------------------------------------------------------
		//
		// Private Methods
		//
		//--------------------------------------------------------------------------

		private static function decodeResponse(bytes:ByteArray):AMFPacket
		{
			// AMF Version
			var version:int = bytes.readUnsignedShort();

			// The response must always start in AMF0
			bytes.objectEncoding = ObjectEncoding.AMF0;
			var response:AMFPacket = new AMFPacket();

			var remainingBytes:ByteArray;

			// Headers
			var headerCount:uint = bytes.readUnsignedShort();
			for (var h:uint = 0; h < headerCount; h++)
			{
				var headerName:String = bytes.readUTF();
				var mustUnderstand:Boolean = bytes.readBoolean();
				bytes.readInt(); // Consume header length...

				// Handle AVM+ type marker
				if (version == ObjectEncoding.AMF3)
				{
					var typeMarker:int = bytes.readByte();
					if (typeMarker == AVMPLUS_TYPE_MARKER)
						bytes.objectEncoding = ObjectEncoding.AMF3;
					else
						bytes.position = bytes.position - 1;
				}

				var headerValue:* = bytes.readObject();

				// Read off the remaining bytes to account for the reset of
				// the by-reference index on each header value
//				remainingBytes = new ByteArray();
//				remainingBytes.objectEncoding = bytes.objectEncoding;
//				bytes.readBytes(remainingBytes, 0, bytes.length - bytes.position);
//				bytes = remainingBytes;
//				remainingBytes = null;

				var header:AMFHeader = new AMFHeader(headerName, mustUnderstand, headerValue);
				response.headers.push(header);

				// Reset to AMF0 for next header
				bytes.objectEncoding = ObjectEncoding.AMF0;
			}

			// Message Bodies
			var messageCount:uint = bytes.readUnsignedShort();
			for (var m:uint = 0; m < messageCount; m++)
			{
				var targetURI:String = bytes.readUTF();
				var responseURI:String = bytes.readUTF();
				bytes.readInt(); // Consume message body length...

				// Handle AVM+ type marker
				if (version == ObjectEncoding.AMF3)
				{
					if (bytes.readByte() == AVMPLUS_TYPE_MARKER)
						bytes.objectEncoding = ObjectEncoding.AMF3;
					else
						bytes.position = bytes.position - 1;
				}

				var messageBody:* = bytes.readObject();

				// Read off the remaining bytes to account for the reset of
				// the by-reference index on each message body
//				remainingBytes = new ByteArray();
//				remainingBytes.objectEncoding = bytes.objectEncoding;
//				bytes.readBytes(remainingBytes, 0, bytes.length - bytes.position);
//				bytes = remainingBytes;
//				remainingBytes = null;

				var message:AMFMessage = new AMFMessage(targetURI, responseURI, messageBody);
				response.messages.push(message);

				// Reset to AMF0 for next message
				bytes.objectEncoding = ObjectEncoding.AMF0;
			}

			return response;
		}

		private static function encodeRequest(request:AMFPacket):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.objectEncoding = ObjectEncoding.AMF0;

			// AMF Version
			bytes.writeShort(request.version);

			var bytesBuffer:ByteArray;

			// AMF Headers
			var headerCount:uint = request.headers == null ? 0 : request.headers.length;
			bytes.writeShort(headerCount);

			for each (var header:AMFHeader in request.headers)
			{
				bytes.writeUTF(header.name);
				bytes.writeBoolean(header.mustUnderstand);
				bytes.writeInt(UNKNOWN_CONTENT_LENGTH);

				// AMF 3 requires AMF 0 switch type marker
				if (request.version == ObjectEncoding.AMF3)
					bytes.writeByte(AVMPLUS_TYPE_MARKER);
				bytes.objectEncoding = request.version;

				// Write the header value into a temporary buffer to ensure the
				// the by-reference index is reset between values
				bytesBuffer = new ByteArray();
				bytesBuffer.objectEncoding = bytes.objectEncoding;
				bytesBuffer.writeObject(header.data);
				bytesBuffer.position = 0;
				bytes.writeBytes(bytesBuffer, 0, bytesBuffer.length);
				bytesBuffer = null;

				// Reset back to AMF 0 for next header
				bytes.objectEncoding = ObjectEncoding.AMF0;
			}

			// AMF Message Bodies
			var messageCount:uint = request.messages == null ? 0 : request.messages.length;
			bytes.writeShort(messageCount);

			for each (var message:AMFMessage in request.messages)
			{
				if (message.targetURI == null)
					bytes.writeUTF("null");
				else
					bytes.writeUTF(message.targetURI);

				if (message.responseURI == null)
					bytes.writeUTF("null");
				else
					bytes.writeUTF(message.responseURI);

				bytes.writeInt(UNKNOWN_CONTENT_LENGTH);

				// AMF 3 requires AMF 0 switch type marker
				if (request.version == ObjectEncoding.AMF3)
					bytes.writeByte(AVMPLUS_TYPE_MARKER);

				bytes.objectEncoding = request.version;

				// Write the header value into a temporary buffer to ensure the
				// the by-reference index is reset between values
				bytesBuffer = new ByteArray();
				bytesBuffer.objectEncoding = bytes.objectEncoding;
				bytesBuffer.writeObject(message.body);
				bytesBuffer.position = 0;
				bytes.writeBytes(bytesBuffer, 0, bytesBuffer.length);
				bytesBuffer = null;

				// Reset back to AMF 0 for next message
				bytes.objectEncoding = ObjectEncoding.AMF0;
			}

			bytes.position = 0;
			return bytes;
		}

		/**
		 * A value is considered complex if it is not null, undefined, a String,
		 * a Boolean, a Number, an int, or a uint.
		 *
		 * TODO: Use this to determine whether the switch to AMF 3 should occur
		 * before writing out the AVMPLUS_TYPE_MARKER for header and message
		 * bodies.
		 */
		private static function isComplexType(value:*):Boolean
		{
			return (value == null || value is String || value is Boolean
					|| value is Number || value is int || value is uint);
		}

		//--------------------------------------------------------------------------
		//
		// Private Variables
		//
		//--------------------------------------------------------------------------

		private var _amfHeaders:Array; // Array of AMFHeader
		private var _client:Object;
		private var _connected:Boolean;
		private var _objectEncoding:uint;
		private var objectEncodingSet:Boolean = false;
		private var _url:String;

		private static var _defaultObjectEncoding:uint = ObjectEncoding.AMF3;

		//--------------------------------------------------------------------------
		//
		// Constants
		//
		//--------------------------------------------------------------------------

		private static const AMF_CONTENT_TYPE:String = "application/x-amf";
		private static const UNKNOWN_CONTENT_LENGTH:int = -1;
		private static const AVMPLUS_TYPE_MARKER:uint = 17;
	}
}

import avmplus.getQualifiedClassName;

//--------------------------------------------------------------------------
//
// Private Inner Classes
//
//--------------------------------------------------------------------------

/**
 * An AMFPacket represents a single AMF request made over an HTTP or
 * HTTPS connection. An AMFPacket can have multiple AMFHeaders followed by a
 * batch of multiple AMFMessages.
 */
class AMFPacket
{
	public function AMFPacket(version:uint = 0)
	{
		this.version = version;
	}

	public var version:uint;
	public var headers:Array = []; // Array of AMFHeader
	public var messages:Array = []; // Array of AMFMessage
}

/**
 * An AMF packet level header. Request and response headers have an identical
 * structure.
 *
 * When making use of by-reference serialization, the reference tables are
 * reset for each AMFHeader. Note that the header name String is never sent by
 * reference and does not participate in by-reference serialization.
 */
class AMFHeader
{
	public function AMFHeader(name:String, mustUnderstand:Boolean = false, data:* = undefined)
	{
		this.name = name;
		this.mustUnderstand = mustUnderstand;
		this.data = data;
	}

	public var name:String;
	public var mustUnderstand:Boolean;
	public var data:*;
}

/**
 * An AMF packet level message. Request messages and response messages have the
 * same general structure.
 *
 * For requests, the targetURI specifies the location of the resource and the
 * operation being invoked. The responseURI specifies the URI that the server
 * must use in its response targetURI as this helps the client match it to the
 * associated request message (and thus the correct message responder can be
 * invoked).
 *
 * For responses, the server uses the targetURI to identify to the client
 * which message this response is intended. The responseURI is ignored.
 *
 * When making use of by-reference serialization, the reference tables are
 * reset for each AMFMessage. Note that targetURI and responseURI Strings are
 * never sent by reference and do not participate in by-reference serialization.
 */
class AMFMessage
{
	public function AMFMessage(targetURI:String = null, responseURI:String = null, body:* = undefined)
	{
		this.targetURI = targetURI;
		this.responseURI = responseURI;
		this.body = body;
	}

	public var targetURI:String;
	public var responseURI:String;
	public var body:*;

	public function toString():String
	{
		return getQualifiedClassName(this)
				+ "\n"
				+ targetURI
				+ "\n"
				+ body;
	}
}
