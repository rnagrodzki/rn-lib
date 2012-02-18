/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.processor
{
	import flash.net.ObjectEncoding;
	import flash.utils.ByteArray;

	public class AMFProcessor
	{
		private static const UNKNOWN_CONTENT_LENGTH:int = -1;
		private static const AVMPLUS_TYPE_MARKER:uint = 17;

		public static function decodeResponse(bytes:ByteArray):AMFPacket
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
				remainingBytes = new ByteArray();
				remainingBytes.objectEncoding = bytes.objectEncoding;
				bytes.readBytes(remainingBytes, 0, bytes.length - bytes.position);
				bytes = remainingBytes;
				remainingBytes = null;

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
				remainingBytes = new ByteArray();
				remainingBytes.objectEncoding = bytes.objectEncoding;
				bytes.readBytes(remainingBytes, 0, bytes.length - bytes.position);
				bytes = remainingBytes;
				remainingBytes = null;

				var message:AMFMessage = new AMFMessage(targetURI, responseURI, messageBody);
				response.messages.push(message);

				// Reset to AMF0 for next message
				bytes.objectEncoding = ObjectEncoding.AMF0;
			}

			return response;
		}

		public static function encodeRequest(request:AMFPacket):ByteArray
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
	}
}
