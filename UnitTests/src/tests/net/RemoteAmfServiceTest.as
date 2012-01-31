/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.amf.connections.AMFNetConnection;
	import com.rnlib.net.amf.RemoteAmfService;

	import flash.events.IEventDispatcher;

	import mockolate.mock;

	import mockolate.received;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.hamcrest.assertThat;
	import org.hamcrest.core.anything;
	import org.hamcrest.object.instanceOf;

	public class RemoteAmfServiceTest
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(type="strict")]
		public var exNC:AMFNetConnection;

		public var amf:RemoteAmfService;

		[Before]
		public function before():void
		{
			mock(exNC).method("close");
			mock(exNC).method("dispose");
			stub(exNC).method("addEventListener").anyArgs();
			stub(exNC).method("removeEventListener").anyArgs();
			mock(exNC).setter("reconnectRepeatCount").arg(uint);
			mock(exNC).setter("redispatcher").arg(instanceOf(IEventDispatcher));

			amf = new RemoteAmfService();
			amf.connection = exNC;
		}

		[After]
		public function after():void
		{
			amf.dispose();
			amf = null;
		}

		[Test(description="Test initialize component configuration", order="1")]
		public function configuration():void
		{
			assertThat(exNC, received().setter("reconnectRepeatCount").once());
			assertThat(exNC, received().setter("redispatcher").once());
		}

		[Test(description="Test disposing component", order="2")]
		public function testDisposeComponent():void
		{
			amf.dispose();

			assertThat(exNC, received().setter("reconnectRepeatCount").once());
			assertThat(exNC, received().setter("redispatcher").once());

			assertThat(exNC,received().method("close").once());
			assertThat(exNC,received().method("dispose").once());
		}
	}
}
