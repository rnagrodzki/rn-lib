/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import flash.net.URLLoader;

	public class AMFUrlLoaderTests
	{
		public var loader : URLLoader;

		[Before]
		public function before():void
		{
			loader = new URLLoader();
		}

		[After]
		public function after():void
		{
			loader = null;
		}
		
		[Test(description="Load string", order="1", async)]
		public function loadString():void
		{
			
		}
	}
}
