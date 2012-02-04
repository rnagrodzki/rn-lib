/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import avmplus.getQualifiedClassName;

	import com.rnlib.net.amf.connections.AMFULConnection;
	import com.rnlib.net.amf.connections.IAMFConnection;

	import flash.net.ObjectEncoding;

	import flash.system.System;

	import flash.utils.ByteArray;
	import flash.utils.unescapeMultiByte;

	import flexunit.framework.Assert;

	import mx.core.ByteArrayAsset;
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
			conn = new AMFULConnection();
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

			if (ba.length == sendBA.length)
			{
				ba.position = 0;
				sendBA.position = 0;

				while (ba.bytesAvailable > 0)
				{
					Assert.assertEquals(ba.readByte(), sendBA.readByte());
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
			trace(getQualifiedClassName(this) + "::varDumpResponse");
			trace("conn -> " + getQualifiedClassName(conn));
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

		[Ignore]
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

		//---------------------------------------------------------------
		//              <------ SENDING BINARY FILE ------>
		//---------------------------------------------------------------

		[Embed(source="/assets/abstract_image.png", mimeType="application/octet-stream")]
		public static const ImageFile:Class;

		public static const FILE_SEPARATOR:uint = 100;

		[Test(description="Send first part of file", order="6", async)]
		public function sendFirstPartFile():void
		{
			var baa:ByteArrayAsset = new ImageFile();
			var baToSend:ByteArray = new ByteArray();
			baToSend.writeBytes(baa, 0, FILE_SEPARATOR);

			var responder:IResponder = Async.asyncResponder(
					this, new Responder(respondToSaveFile, errorFile), TIMEOUT);
			conn.call("ByteArrayService.startSavingFile", responder.result, responder.fault, baToSend);
		}

		protected function errorFile(fault:Object):void
		{
			trace(fault);
		}

		protected function respondToSaveFile(result:Object):void
		{
			trace(result);
		}

		[Test(description="Send part of file", order="7", async)]
		public function sendPartFile():void
		{
			var baa:ByteArrayAsset = new ImageFile();
			var baToSend:ByteArray = new ByteArray();
			baToSend.writeBytes(baa, FILE_SEPARATOR, baa.length - FILE_SEPARATOR);

			var responder:IResponder = Async.asyncResponder(
					this, new Responder(respondToSaveFile, errorFile), TIMEOUT);
			conn.call("ByteArrayService.continueSavingFile", responder.result, responder.fault, baToSend);
		}

		[Test(description="Loading complete file received by merging sended parts of file", order="8", async)]
		public function loadCompleteFile():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(compareMergedFile, errorFile), TIMEOUT);
			conn.call("ByteArrayService.loadFile", responder.result, responder.fault);
		}

		protected function compareMergedFile(source:Object):void
		{
			var file:ByteArray = source as ByteArray;
			Assert.assertNotNull(file);

			if (!file) return;

			var baa:ByteArrayAsset = new ImageFile();
			Assert.assertEquals(baa.length, file.length);

			if (baa.length == file.length)
			{
				baa.position = 0;
				file.position = 0;

				while (baa.bytesAvailable > 0)
				{
					Assert.assertEquals(baa.readByte(), file.readByte());
				}
			}
		}

		[Test(description="Loading complete file received by merging sended parts of file", order="9", async)]
		public function alternativeLoadFile():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseRawFile, errorFile), TIMEOUT);
			conn.call("ByteArrayService.alternativeLoadFile", responder.result, responder.fault);
		}

		protected function fix():String {

			return String.fromCharCode( Number(String(arguments[0]).substr(1,4)) );
		}

		protected function responseRawFile(source:String):void
		{
			var file:ByteArray = new ByteArray();
			file.objectEncoding=ObjectEncoding.AMF3;
			file.writeUTFBytes(source);
			
			var baa:ByteArrayAsset = new ImageFile();
			Assert.assertEquals(baa.length, file.length);
		}

		[Ignore]
		[Test(description="Test read and write object", order="10")]
		/**
		 * http://www.flexdeveloper.eu/forums/actionscript-3-0/compress-and-uncompress-strings-using-bytearray
		 */
		public function readWriteObject():void
		{

		}
	}
}
