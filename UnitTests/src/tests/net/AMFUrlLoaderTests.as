/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.AMFConnection;

	import flash.events.Event;

	import org.flexunit.async.Async;

	import tests.net.vo.TestVO;

	public class AMFUrlLoaderTests
	{
		public static const GATEWAY:String = "http://unittests.rnlib/amf";

		public var conn:AMFConnection;

		[Before]
		public function before():void
		{
			conn = new AMFConnection();
			conn.url = GATEWAY;
		}

		[After]
		public function after():void
		{
			conn = null;
		}

		[Test(description="Load string", order="1", async)]
		public function loadString():void
		{
			var handler:Function = Async.asyncHandler(this, onComplete, 300);
			conn.addEventListener(Event.COMPLETE, handler);
			conn.call("ExternalNetConnection.simple", response, null);
		}

		[Test(description="Load array", order="2", async)]
		public function loadArray():void
		{
			var handler:Function = Async.asyncHandler(this, onComplete, 300);
			conn.addEventListener(Event.COMPLETE, handler);
			conn.call("ExternalNetConnection.arrayFunction", response, null);
		}

		[Test(description="Load TestVO", order="3", async)]
		public function loadVO():void
		{
			var handler:Function = Async.asyncHandler(this, onComplete, 300);
			conn.addEventListener(Event.COMPLETE, handler);
			conn.call("ExternalNetConnection.testVO", responseVO, null);
		}

		private function onComplete(ev:Event, data:* = null):void
		{
			trace(ev.type);
		}

		private function response(ob:Object):void
		{
			trace(ob);
		}

		private function responseVO(ob:Object):void
		{
			TestVO(ob);
		}
	}
}
