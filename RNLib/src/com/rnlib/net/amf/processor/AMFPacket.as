/***************************************************************************************************
 * Copyright (c) 2012 Rafał Nagrodzki (http://nagrodzki.net)
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
package com.rnlib.net.amf.processor
{
	import com.rnlib.interfaces.IDisposable;

	/**
	 * An AMFPacket represents a single AMF request made over an HTTP or
	 * HTTPS connection. An AMFPacket can have multiple AMFHeaders followed by a
	 * batch of multiple AMFMessages.
	 */
	public class AMFPacket implements IDisposable
	{
		public function AMFPacket(version:uint = 0)
		{
			this.version = version;
		}

		public var version:uint;
		public var headers:Array = []; // Array of AMFHeader
		public var messages:Array = []; // Array of AMFMessage

		public function dispose():void
		{
			for each (var header:AMFHeader in headers)
			{
				header.dispose();
			}

			for each (var message:AMFMessage in messages)
			{
				message.dispose();
			}

			headers = null;
			messages = null;
		}
	}
}
