/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.amf.connections.AMFULConnection;

	import flash.events.Event;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;

	public class PHPServerFeatures
	{
		public static const GATEWAY:String = "http://unittests.rnlib/amf";

		public static const TIMEOUT:uint = 1000;

		public var conn:AMFULConnection;

		protected var session:String;

		[Before]
		public function before():void
		{
			conn = new AMFULConnection();
			conn.connect(GATEWAY);
		}

		[After]
		public function after():void
		{
			conn = null;
		}

		[Test(description="Start session", order="1", async)]
		public function startSession():void
		{
			var handler:Function = Async.asyncHandler(this, onComplete, TIMEOUT);
			conn.addEventListener(Event.COMPLETE, handler);
			conn.call("SessionTestService.startSession", responseSession, null);
		}

		[Test(description="Get session", order="2", async)]
		public function getSession():void
		{
			var handler:Function = Async.asyncHandler(this, onComplete, TIMEOUT);
			conn.addEventListener(Event.COMPLETE, handler);
			conn.call("SessionTestService.getSessionId", responseSession, null);
		}

		[Test(description="Get session", order="3", async)]
		public function getSession2():void
		{
			var handler:Function = Async.asyncHandler(this, onComplete, TIMEOUT);
			conn.addEventListener(Event.COMPLETE, handler);
			conn.call("SessionTestService.getSessionId", responseSession, null);
		}

		protected var _values:Array = [];

		[Test(description="Set session values", order="4", async)]
		public function setSessionValues():void
		{
			var handler:Function = Async.asyncHandler(this, onComplete, TIMEOUT);
			conn.addEventListener(Event.COMPLETE, handler);

			_values["name"] = "My Name";
			_values["age"] = 33;

			conn.call("SessionTestService.setSessionValues", responseSetValues, null, _values);
		}

		[Test(description="Get session values", order="5", async)]
		public function getSessionValues():void
		{
			var handler:Function = Async.asyncHandler(this, onComplete, TIMEOUT);
			conn.addEventListener(Event.COMPLETE, handler);
			conn.call("SessionTestService.getSessionValues", responseSessionValues, null);
		}

		private function onComplete(ev:Event, data:* = null):void
		{
		}

		private function responseSession(ob:Object):void
		{
			trace("Server session: " + ob);

			Assert.assertNotNull(ob);

			if (!session) session = ob as String;

			Assert.assertEquals(session, ob);
		}

		private function responseSetValues(response:Object):void
		{
			Assert.assertNotNull(response);

			assertThat(_values, response);
		}

		private function responseSessionValues(response:Object):void
		{
			Assert.assertNotNull(response);

			assertThat(_values, response);
		}
	}
}
