/*
 * Copyright (c) 2012. Rafał Nagrodzki (rafal[dot]nagrodzki[dot]dev[at]gmail[dot]com)
 *  http://rafal-nagrodzki.com/
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tests.net.server
{
	import rnlib.net.amf.connections.AMFNetConnection;
	import rnlib.net.amf.connections.AMFULConnection;
	import rnlib.net.amf.connections.IAMFConnection;

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
