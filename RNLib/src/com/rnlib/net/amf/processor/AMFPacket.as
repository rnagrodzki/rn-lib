/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.processor
{
	/**
	 * An AMFPacket represents a single AMF request made over an HTTP or
	 * HTTPS connection. An AMFPacket can have multiple AMFHeaders followed by a
	 * batch of multiple AMFMessages.
	 */
	public class AMFPacket
	{
		public function AMFPacket(version:uint = 0)
		{
			this.version = version;
		}

		public var version:uint;
		public var headers:Array = []; // Array of AMFHeader
		public var messages:Array = []; // Array of AMFMessage
	}
}
