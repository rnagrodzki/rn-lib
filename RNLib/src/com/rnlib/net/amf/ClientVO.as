/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf
{
	public class ClientVO
	{
		public function ClientVO(name:String = null, arguments:* = null)
		{
			this.name = name;
			this.arguments = arguments;
		}

		public var name:String;
		public var arguments:*;
	}
}
