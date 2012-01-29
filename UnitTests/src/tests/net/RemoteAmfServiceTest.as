/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.ExtendedNetConnection;
	import com.rnlib.net.RemoteAmfService;

	import flash.events.IEventDispatcher;

	import mockolate.mock;

	import mockolate.received;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.hamcrest.assertThat;
	import org.hamcrest.core.anything;

	public class RemoteAmfServiceTest
	{
		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(type="strict")]
		public var exNC:ExtendedNetConnection;

		public var amf:RemoteAmfService;

		[Before]
		public function before():void
		{
			stub(exNC).method("close");
			stub(exNC).method("addEventListener").anyArgs();
			stub(exNC).method("removeEventListener").anyArgs();
			mock(exNC).setter("reconnectRepeatCount").arg(uint);
			mock(exNC).setter("redispatcher").arg(anything());

			amf = new RemoteAmfService(exNC);
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
			//todo: fix this test
			assertThat(exNC, received().setter("reconnectRepeatCount").once());
			assertThat(exNC, received().setter("redispatcher").once());
		}
	}
}
