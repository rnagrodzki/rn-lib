/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.processor
{
	import avmplus.getQualifiedClassName;

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
	public class AMFMessage
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
}
