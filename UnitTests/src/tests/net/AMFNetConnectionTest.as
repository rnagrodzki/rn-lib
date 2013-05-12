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
package tests.net
{
	import com.rnlib.net.amf.ReflexiveClient;
	import com.rnlib.net.amf.connections.AMFNetConnection;
	import com.rnlib.net.amf.AMFEvent;

	import flash.events.Event;
	import flash.net.NetConnection;

	import flexunit.framework.Assert;

	import mockolate.mock;
	import mockolate.received;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.instanceOf;

	public class AMFNetConnectionTest
	{
		public static const GATEWAY:String = "http://unittests.rnlib/amf";

		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(type="strict")]
		public var nc:NetConnection;

		public var exNC:AMFNetConnection;

		[Before]
		public function callBefore():void
		{
			prepareBasicMethods();

			exNC = new AMFNetConnection(nc);
		}

		private function prepareBasicMethods():void
		{
			mock(nc).method("addEventListener").anyArgs();
			mock(nc).setter("client").arg(instanceOf(ReflexiveClient));
			stub(nc).method("close").noArgs();
			stub(nc).method("removeEventListener").anyArgs();
		}

		[After]
		public function callAfter():void
		{
			exNC.dispose();
			exNC = null;
		}

		[Test(description="Test initializing component", order="1")]
		public function initializeComponent():void
		{
			prepareBasicMethods();

			assertThat(nc, received().method("addEventListener").times(3));
		}

		[Test(description="Test dispose component", order="2")]
		public function disposeComponent():void
		{
			exNC.dispose();

			assertThat(nc, received().method("removeEventListener").times(3));
			assertThat(nc, received().method("close").times(1));
		}

		[Test(description="Test multiple dispose component", order="3")]
		public function multipleDisposeComponent():void
		{
			exNC.dispose();

			assertThat(nc, received().method("removeEventListener").times(3));
			assertThat(nc, received().method("close").times(1));

			exNC.dispose();

			assertThat(nc, received().method("removeEventListener").times(3));
			assertThat(nc, received().method("close").times(1));

		}

		[Test(description="Connect with server and automatic disconnect", order="4", async)]
		public function serverConnection():void
		{
			var handlerConnected:Function = Async.asyncHandler(this, onConnected, 100, null, onTimeOut);
			var handlerDisconnected:Function = Async.asyncHandler(this, onDisconnected, 200, null, onTimeOut);
			exNC = new AMFNetConnection();
			exNC.addEventListener(AMFEvent.CONNECTED, handlerConnected, false, 0, true);
			exNC.addEventListener(AMFEvent.DISCONNECTED, handlerDisconnected, false, 0, true);
			exNC.keepAliveTime = 50;
			exNC.connect(GATEWAY);
			Assert.assertTrue(exNC.connected);
		}

		private function onDisconnected(e:Event, extra:*):void
		{
			Assert.assertFalse(exNC.connected);
		}

		private function onTimeOut():void
		{

		}

		public function onConnected(e:Event, extra:*):void
		{
			Assert.assertTrue(exNC.connected);
		}
	}
}
