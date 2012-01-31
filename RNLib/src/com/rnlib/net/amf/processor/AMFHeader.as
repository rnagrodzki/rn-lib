/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.processor
{
	/**
	 * An AMF packet level header. Request and response headers have an identical
	 * structure.
	 *
	 * When making use of by-reference serialization, the reference tables are
	 * reset for each AMFHeader. Note that the header name String is never sent by
	 * reference and does not participate in by-reference serialization.
	 */
	public class AMFHeader
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
}
