/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.amf.connections.AMFNetConnection;
	import com.rnlib.net.amf.connections.IAMFConnection;

	import flash.utils.ByteArray;

	import flexunit.framework.Assert;

	import mx.rpc.IResponder;
	import mx.rpc.Responder;

	import org.flexunit.async.Async;

	import tests.net.vo.ByteArrayVO;

	public class ByteArrayPlayground
	{
		public static const GATEWAY:String = "http://unittests.rnlib/amf";

		public static const TIMEOUT:uint = 1000;

		public var conn:IAMFConnection;

		protected var sendBA:ByteArray;

		[Before]
		public function before():void
		{
//			conn = new AMFULConnection();
			conn = new AMFNetConnection();
			conn.connect(GATEWAY);
		}

		[After]
		public function after():void
		{
			conn.dispose();
			conn = null;
		}

		[Test(description="Loading ByteArray", order="1", async)]
		public function loadByteArray():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseByteArray, responseByteArrayFault), TIMEOUT);
			conn.call("ByteArrayService.loadByteArray", responder.result, responder.fault);
		}

		protected function responseByteArray(result:Object):void
		{
			Assert.assertTrue(result is ByteArray);
		}

		protected function compareByteArray(result:Object):void
		{
			Assert.assertTrue(result is ByteArray);
			var ba:ByteArray = result as ByteArray;
			Assert.assertEquals(ba.length, sendBA.length);
			
			if(ba.length == sendBA.length)
			{
				ba.position = 0;
				sendBA.position = 0;
				
				while(ba.bytesAvailable > 0)
				{
					Assert.assertEquals(ba.readByte(),sendBA.readByte());
				}
			}
			
			sendBA = null;
		}

		protected function responseByteArrayFault(result:Object):void
		{
			Assert.fail("Metos fault with message: " + result);
		}

		[Test(description="Sending and receiving this same ByteArray", order="2", async)]
		public function sendAndLoadByteArray():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(compareByteArray, responseByteArrayFault), TIMEOUT);
			var ba:ByteArray = new ByteArray();
			ba.writeUTF("Example text from flash");
			sendBA = ba;
			conn.call("ByteArrayService.sendAndLoadByteArray", responder.result, responder.fault, ba);
		}

		[Test(description="Loading var_dump from ByteArray", order="3", async)]
		public function loadByteArrayVarDump():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(varDumpResponse, responseByteArrayFault), TIMEOUT);
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes("Example text from flash");
			conn.call("ByteArrayService.loadAsDump", responder.result, responder.fault, ba);
		}

		protected function varDumpResponse(result:Object):void
		{
			trace(result);
		}

		[Test(description="Loading ByteArray from VO", order="4", async)]
		public function loadByteArrayFromVO():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(compareByteArray, responseByteArrayFault), TIMEOUT);
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes("Example text from flash");

			var vo:ByteArrayVO = new ByteArrayVO();
			vo.name = "Example name";
			vo.bytes = ba;
			sendBA = ba;

			conn.call("ByteArrayService.byteArrayFromVO", responder.result, responder.fault, vo);
		}

		[Test(description="Loading dump ByteArray from VO", order="5", async)]
		public function loadVOVarDump():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(varDumpResponse, responseByteArrayFault), TIMEOUT);
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes("Example text from flash");

			var vo:ByteArrayVO = new ByteArrayVO();
			vo.name = "Example name";
			vo.bytes = ba;

			conn.call("ByteArrayService.loadAsDumpVO", responder.result, responder.fault, vo);
		}
	}
}
