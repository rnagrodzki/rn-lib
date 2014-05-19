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
package old.tests.net.server
{
	import rnlib.net.amf.connections.AMFULConnection;
	import rnlib.net.amf.connections.IAMFConnection;

	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	import flexunit.framework.Assert;

	import mx.rpc.IResponder;
	import mx.rpc.Responder;

	import org.flexunit.async.Async;

	import old.tests.net.vo.TestVO;

	public class AMFBaseServerTest
	{
		public static const GATEWAY:String = "http://unittests.rnlib/amf";

		public static const TIMEOUT:uint = 1000;

		public var conn:IAMFConnection;

		public var dumpToCompare:String;

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

		protected function faultRespons(fault:Object):void{

		}

		[Test(description="Load string", order="1", async)]
		public function loadString():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, faultRespons), TIMEOUT);
			conn.call("BaseAMFService.loadString", responder.result, responder.fault);
		}

		[Test(description="Load array", order="2", async)]
		public function loadArray():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, faultRespons), TIMEOUT);
			conn.call("BaseAMFService.loadArray", responder.result, responder.fault);
		}

		[Test(description="Load TestVO", order="3", async)]
		public function loadVO():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseVO, faultRespons), TIMEOUT);
			conn.call("BaseAMFService.loadVO", responder.result, responder.fault);
		}

		[Test(description="Load string", order="4", async)]
		public function sendString():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, faultRespons), TIMEOUT);
			conn.call("BaseAMFService.loadAsDump", responder.result, responder.fault, "wysłany string");
		}

		[Test(description="Load array", order="5", async)]
		public function sendArray():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, faultRespons), TIMEOUT);

			dumpToCompare = "array(3) {\n" +
					"  [0]=>\n" +
					"  int(12)\n" +
					"  [1]=>\n" +
					"  int(45)\n" +
					"  [2]=>\n" +
					'  string(3) "str"\n' +
					"}";

			conn.call("BaseAMFService.loadAsDump", responder.result, responder.fault, [12, 45, "str"]);
		}

		[Test(description="Send TestVO and load txt dump", order="6", async)]
		public function sendVO():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, faultRespons), TIMEOUT);

			var vo:TestVO = new TestVO();
			vo.count = 15;
			vo.name = "Try it!";
			vo.array = ["first", "second"];
			conn.call("BaseAMFService.loadAsDump", responder.result, responder.fault, vo);
		}

		[Test(description="Send ByteArray", order="7", async)]
		public function sendBA():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseNotNull, faultRespons), TIMEOUT);

			var ba:ByteArray = new ByteArray();
			ba.writeObject({name:"String w ByteArray"});

			conn.call("BaseAMFService.loadAsDump", responder.result, responder.fault, ba);
		}

		protected function responseNotNull(ob:Object = null):void
		{
			trace(getQualifiedClassName(this) + "::responseNotNull");
			trace("conn -> " + getQualifiedClassName(conn));
			trace(ob);

			Assert.assertNotNull(ob);
			//todo: compare var_dump with expected string
//			Assert.assertEquals(ob, dumpToCompare);

			dumpToCompare = null;
		}

		protected function responseVO(ob:Object):void
		{
			Assert.assertNotNull(ob as TestVO);
		}

		[Test(description="Load date from serwer", order="8", async)]
		public function loadCurrentDate():void
		{
			var responder:IResponder = Async.asyncResponder(
					this, new Responder(responseDate, faultRespons), TIMEOUT);

			var ba:ByteArray = new ByteArray();
			ba.writeObject({name:"String w ByteArray"});

			conn.call("BaseAMFService.loadCurrentDate", responder.result, responder.fault, ba);
		}

		protected function responseDate(response:Object):void
		{
			trace(response);
			var date:Date = new Date();
			var now:Date = new Date();
			date.time = Number(response);
			Assert.assertNotNull(date);
			Assert.assertTrue(date.time > 0);
			Assert.assertEquals(now.fullYear,date.fullYear);
			Assert.assertEquals(now.month,date.month);
			Assert.assertEquals(now.day,date.day);
			Assert.assertEquals(now.hours,date.hours);
			
			date = null;
			now = null;
		}
	}
}
