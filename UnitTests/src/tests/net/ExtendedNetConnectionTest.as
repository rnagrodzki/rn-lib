/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.amf.connections.AMFNetConnection;
	import com.rnlib.net.amf.AMFEvent;

	import flash.events.Event;
	import flash.net.NetConnection;

	import flexunit.framework.Assert;

	import mockolate.mock;
	import mockolate.received;
	import mockolate.runner.MockolateRule;

	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;

	public class ExtendedNetConnectionTest
	{
		public static const GATEWAY:String = "http://unittests.rnlib/amf";

		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(type="strict")]
		public var nc:NetConnection;

		public var exNC:AMFNetConnection;

		[Before]
		public function before():void
		{
			prepareBasicMethods();

			exNC = new AMFNetConnection(nc);
		}

		private function prepareBasicMethods():void
		{
			mock(nc).method("close").noArgs();
			mock(nc).method("addEventListener").anyArgs();
			mock(nc).method("removeEventListener").anyArgs();
		}

		[After]
		public function after():void
		{
			exNC.dispose();
			exNC = null;
		}

		[Test(description="Test initializing component", order="1")]
		public function initializeComponent():void
		{
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
