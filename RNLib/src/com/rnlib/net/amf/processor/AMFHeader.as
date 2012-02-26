/***************************************************************************************************
 Copyright (c) 2012. Rafał Nagrodzki (rafal.nagrodzki.dev@gmail.com)
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
	import com.rnlib.interfaces.IDisposable;

	/**
	 * An AMF packet level header. Request and response headers have an identical
	 * structure.
	 *
	 * When making use of by-reference serialization, the reference tables are
	 * reset for each AMFHeader. Note that the header name String is never sent by
	 * reference and does not participate in by-reference serialization.
	 */
	public class AMFHeader implements IDisposable
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

		public function dispose():void
		{
			name = null;
			data = null;
		}
	}
}
