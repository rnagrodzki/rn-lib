/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.vo
{
	import flash.utils.ByteArray;

	[RemoteClass(alias="vo.ByteArray")]
	public class ByteArrayVO
	{
		public var name:String;
		public var bytes:ByteArray;
	}
}
