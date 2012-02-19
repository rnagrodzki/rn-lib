/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.server
{
	import com.rnlib.net.amf.connections.AMFNetConnection;
	import com.rnlib.net.amf.connections.AMFULConnection;
	import com.rnlib.net.amf.connections.IAMFConnection;

	import flash.events.Event;

	import mx.rpc.IResponder;

	import mx.rpc.Responder;

	import mx.rpc.Responder;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;

	public class PHPServerFeatures
	{
		public static const GATEWAY:String = "http://unittests.rnlib/amf";

		public static const TIMEOUT:uint = 1000;

		public var conn:IAMFConnection;

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
			var responder : IResponder = Async.asyncResponder(this,new Responder(responseSession,responseSession),TIMEOUT);
			conn.call("SessionTestService.startSession", responder.result, responder.fault);
		}

		[Test(description="Get session", order="2", async)]
		public function getSession():void
		{
			var responder : IResponder = Async.asyncResponder(this,new Responder(responseSession,responseSession),TIMEOUT);
			conn.call("SessionTestService.getSessionId", responder.result, responder.fault);
		}

		[Test(description="Get session", order="3", async)]
		public function getSession2():void
		{
			var responder : IResponder = Async.asyncResponder(this,new Responder(responseSession,responseSession),TIMEOUT);
			conn.call("SessionTestService.getSessionId", responder.result, responder.fault);
		}

		protected var _values:Array = [];

		[Test(description="Set session values", order="4", async)]
		public function setSessionValues():void
		{
			var responder : IResponder = Async.asyncResponder(this,new Responder(responseSetValues,responseSetValues),TIMEOUT);

			_values["name"] = "My Name";
			_values["age"] = 33;

			conn.call("SessionTestService.setSessionValues", responder.result, responder.fault, _values);
		}

		[Test(description="Get session values", order="5", async)]
		public function getSessionValues():void
		{
			var responder : IResponder = Async.asyncResponder(this,new Responder(responseSessionValues,responseSessionValues),TIMEOUT);
			conn.call("SessionTestService.getSessionValues", responder.result, responder.fault);
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
