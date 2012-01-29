/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.ExtendedNetConnection;

	import flash.net.NetConnection;

	import mockolate.mock;
	import mockolate.received;
	import mockolate.runner.MockolateRule;

	import org.hamcrest.assertThat;

	public class ExtendedNetConnectionTest
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(type="strict")]
		public var nc:NetConnection;

		public var exNC:ExtendedNetConnection;

		[Before]
		public function before():void
		{
			prepareBasicMethods();

			exNC = new ExtendedNetConnection(nc);
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
	}
}
