/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.amf.connections.AMFULConnection;
	import com.rnlib.net.amf.connections.IAMFConnection;

	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	import mx.rpc.IResponder;
	import mx.rpc.Responder;

	import org.flexunit.async.Async;

	public class ByteArrayPlayground
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

		[Test(description="Loading ByteArray", order="1", async)]
		public function loadByteArray():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseByteArray, responseByteArrayFault), TIMEOUT);
			conn.call("ByteArrayService.loadBitmapArray", responder.result, responder.fault);
		}

		protected function responseByteArray(result:Object):void
		{
			Assert.assertTrue(result is ByteArray);
		}

		protected function responseByteArrayFault(result:Object):void
		{
			Assert.fail("Metos fault with message: " + result);
		}

		[Test(description="Sending and receiving this same ByteArray", order="2", async)]
		public function sendAndLoadByteArray():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseByteArray, responseByteArrayFault), TIMEOUT);
			var ba:ByteArray = new ByteArray();
			ba.writeUTF("Example text from flash");
			conn.call("ByteArrayService.sendAndLoadByteArray", responder.result, responder.fault, ba);
		}

		[Test(description="Loading var_dump from ByteArray", order="3", async)]
		public function loadByteArrayVarDump():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(varDumpResponse, responseByteArrayFault), TIMEOUT);
			var ba:ByteArray = new ByteArray();
			ba.writeUTF("Example text from flash");
			conn.call("ByteArrayService.loadAsDump", responder.result, responder.fault, ba);
		}

		protected function varDumpResponse(result:Object):void
		{
			trace(result);
		}
	}
}
