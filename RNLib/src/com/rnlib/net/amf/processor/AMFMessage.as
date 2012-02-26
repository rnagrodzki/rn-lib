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
package com.rnlib.net.amf.processor
{
	import avmplus.getQualifiedClassName;

	import com.rnlib.interfaces.IDisposable;

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
	public class AMFMessage implements IDisposable
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

		public function dispose():void
		{
			targetURI = null;
			responseURI = null;
			body = null;
		}
	}
}
