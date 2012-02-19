/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.RequestConcurrency;
	import com.rnlib.net.amf.RemoteAmfService;
	import com.rnlib.net.amf.connections.IAMFConnection;

	import flash.events.IEventDispatcher;

	import flexunit.framework.Assert;

	import mockolate.mock;
	import mockolate.received;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.flexunit.rules.IMethodRule;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.instanceOf;
	import org.morefluent.integrations.flexunit4.MorefluentRule;

	public class RemoteAmfServiceTest
	{

		[Rule]
		// make sure you have MorefluentRule defined in your test
		// https://bitbucket.org/loomis/morefluent/overview
		// https://bitbucket.org/loomis/morefluent/wiki/Home
		public var morefluentRule:IMethodRule = new MorefluentRule();

		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(type="strict")]
		public var exConn:IAMFConnection;

		public var service:RemoteAmfService;

		[Before]
		public function before():void
		{
			mock(exConn).method("close");
			mock(exConn).method("dispose");
			mock(exConn).method("connect");
			mock(exConn).getter("connected");
			stub(exConn).method("addEventListener").anyArgs();
			stub(exConn).method("removeEventListener").anyArgs();
			mock(exConn).setter("reconnectRepeatCount").arg(uint);
			mock(exConn).setter("redispatcher").arg(instanceOf(IEventDispatcher));

			service = new RemoteAmfService();
			service.connection = exConn;
		}

		[After]
		public function after():void
		{
			service.dispose();
			service = null;
		}

		[Test(description="Check property after create", order="1")]
		public function checkPropertyAfterCreate():void
		{
			Assert.assertNotNull(service.connection);
			Assert.assertNull(service.service);
			Assert.assertNull(service.endpoint);
			Assert.assertNotNull(service.queue);
			Assert.assertEquals(service.concurrency,RequestConcurrency.QUEUE);
			Assert.assertTrue(service.showBusyCursor);
			Assert.assertNull(service.result);
			Assert.assertNull(service.fault);
			Assert.assertNull(service.pluginsFactories);
			Assert.assertFalse(service.continueAfterFault);
		}

		[Test(description="Test initialize component without configuration", order="2")]
		public function configuration():void
		{
			assertThat(exConn, received().setter("reconnectRepeatCount").once());
			assertThat(exConn, received().setter("redispatcher").once());
			assertThat(exConn, received().method("connect").never());

			service.endpoint = "http://rnlib.rafal-nagrodzki.com/amf";

			assertThat(exConn, received().getter("connected").once());
			assertThat(exConn, received().method("connect").once());
		}

		[Test(description="Test disposing component", order="3")]
		public function testDisposeComponent():void
		{
			service.dispose();

			assertThat(exConn, received().setter("reconnectRepeatCount").once());
			assertThat(exConn, received().setter("redispatcher").once());

			assertThat(exConn, received().method("close").once());
			assertThat(exConn, received().method("dispose").once());
		}
	}
}
