/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.amf.connections.AMFULConnection;

	import flash.events.Event;
	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	import mx.rpc.IResponder;
	import mx.rpc.Responder;

	import org.flexunit.async.Async;

	import tests.net.vo.TestVO;

	public class AMFULConnectionTest
	{
		public static const GATEWAY:String = "http://unittests.rnlib/amf";

		public static const TIMEOUT:uint = 1000;

		public var conn:AMFULConnection;

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

		[Test(description="Load string", order="1", async)]
		public function loadString():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, responseNotNull), TIMEOUT);
			conn.call("ExternalNetConnection.loadString", responder.result,responder.fault);
		}

		[Test(description="Load array", order="2", async)]
		public function loadArray():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, responseNotNull), TIMEOUT);
			conn.call("ExternalNetConnection.loadArray", responder.result,responder.fault);
		}

		[Test(description="Load TestVO", order="3", async)]
		public function loadVO():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseVO, responseVO), TIMEOUT);
			conn.call("ExternalNetConnection.loadVO", responder.result,responder.fault);
		}

		[Test(description="Load string", order="4", async)]
		public function sendString():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, responseNotNull), TIMEOUT);
			conn.call("ExternalNetConnection.loadAsDump", responder.result,responder.fault, "wysłany string");
		}

		[Test(description="Load array", order="5", async)]
		public function sendArray():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, responseNotNull), TIMEOUT);
			conn.call("ExternalNetConnection.loadAsDump", responder.result,responder.fault, [12, 45, "str"]);
		}

		[Test(description="Load TestVO", order="6", async)]
		public function sendVO():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, responseNotNull), TIMEOUT);

			var vo:TestVO = new TestVO();
			vo.count = 15;
			vo.name = "Try it!";
			vo.array = ["first", "second"];
			conn.call("ExternalNetConnection.loadAsDump", responder.result,responder.fault, vo);
		}

		[Test(description="Send ByteArray", order="7", async)]
		public function sendBA():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, responseNotNull), TIMEOUT);

			var ba:ByteArray = new ByteArray();
			ba.writeObject({name:"String w byte arrrayu"});

			conn.call("ExternalNetConnection.loadAsDump", responder.result,responder.fault, ba);
		}

		private function responseNull(ob:Object=null):void
		{
			Assert.assertNull(ob);
		}

		private function responseNotNull(ob:Object=null):void
		{
//			trace(ob);

			Assert.assertNotNull(ob);
		}

		private function responseVO(ob:Object):void
		{
			Assert.assertNotNull(ob as TestVO);
		}
	}
}
