/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.RequestConcurrency;
	import com.rnlib.net.amf.AMFEvent;
	import com.rnlib.net.amf.RemoteAmfService;
	import com.rnlib.net.amf.connections.IAMFConnection;
	import com.rnlib.net.amf.plugins.FileReferencePlugin;
	import com.rnlib.net.amf.plugins.FileReferencePluginVO;
	import com.rnlib.net.amf.plugins.PluginFactory;

	import flash.events.IEventDispatcher;

	import flexunit.framework.Assert;

	import mockolate.ingredients.answers.MethodInvokingAnswer;
	import mockolate.mock;
	import mockolate.received;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
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
			_passOnFault = null;
			_passOnResult = null;
		}

		[Test(description="Check property after create", order="1")]
		public function checkPropertyAfterCreate():void
		{
			Assert.assertNotNull(service.connection);
			Assert.assertNull(service.service);
			Assert.assertNull(service.endpoint);
			Assert.assertNotNull(service.queue);
			Assert.assertEquals(service.concurrency, RequestConcurrency.QUEUE);
			Assert.assertTrue(service.showBusyCursor);
			Assert.assertNull(service.result);
			Assert.assertNull(service.fault);
			Assert.assertNull(service.pluginsFactories);
			Assert.assertFalse(service.continueAfterFault);
		}

		[Test(description="Test initialize component with base configuration", order="2")]
		public function configuration():void
		{
			assertThat(exConn, received().setter("reconnectRepeatCount").once());
			assertThat(exConn, received().setter("redispatcher").once());
			assertThat(exConn, received().method("connect").never());

			const url:String = "http://rnlib.rafal-nagrodzki.com/amf";
			service.endpoint = url;
			Assert.assertEquals(url, service.endpoint);

			const serviceName:String = "TestService";
			service.service = serviceName;
			Assert.assertEquals(serviceName, service.service);

			assertThat(exConn, received().getter("connected").once());
			assertThat(exConn, received().method("connect").once());

			service.fault = function (fault:Object):void { fail("fault called"); };
			Assert.assertNotNull(service.fault);
			service.result = function (result:Object):void { fail("result called"); };
			Assert.assertNotNull(service.result);

			service.continueAfterFault = true;
			Assert.assertTrue(service.continueAfterFault);

			service.concurrency = RequestConcurrency.LAST;
			Assert.assertEquals(RequestConcurrency.LAST, service.concurrency);

			service.showBusyCursor = false;
			Assert.assertFalse(service.showBusyCursor);

			var plugins:Array = [new PluginFactory(FileReferencePlugin, FileReferencePluginVO)];
			service.pluginsFactories = plugins;
			assertThat(plugins, service.pluginsFactories);
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

		[Test(description="Test call not added remote method", order="4", expects="Error")]
		public function testCallNotAddedMethod():void
		{
			service.myRemoteMethod(true);
		}

		[Test(description="Test adding remote methods nad colling without endpoint", order="5", expects="Error")]
		public function testAddingRemoteMethodsNoEndpoint():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.failOnEvent(this, service, AMFEvent.RESULT, 100);

			_passOnResult = "returnThisInResult";
			service.addMethod("test");
			service.test(); //this throw Error because endpoint is not set
		}

		[Test(description="Test adding remote methods and calling", order="6")]
		public function testAddingRemoteMethods():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.handleEvent(this, service, AMFEvent.RESULT, testAddingRemoteMethodsHandler, 100);

			service.endpoint = "http://example.com";
			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "myOtherRemoteMethod";
			service.addMethod("myOtherRemoteMethod"); // because service property is not set test will be called as global remote function not service method
			service.myOtherRemoteMethod();
		}

		protected function testAddingRemoteMethodsHandler(ev:AMFEvent, extra:* = null):void
		{
			Assert.assertEquals(_passOnResult, ev.data);
		}

		protected var _calledRemoteMethod:String;
		protected var _passOnResult:Object;

		public function callOnResult(method:String, result:Function, fault:Function):void
		{
			Assert.assertEquals(_calledRemoteMethod, method);
			result(_passOnResult);
		}

		protected var _passOnFault:Object;

		public function callOnFault(method:String, result:Function, fault:Function):void
		{
			Assert.assertEquals(_calledRemoteMethod, method);
			fault(_passOnFault);
		}

		[Test(description="Test adding remote methods and calling", order="7")]
		public function callingRemoteMethodOfService():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.handleEvent(this, service, AMFEvent.RESULT, testAddingRemoteMethodsHandler, 100);

			service.endpoint = "http://example.com";
			service.service = "ExampleService";
			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "ExampleService.myOtherRemoteMethod";
			service.addMethod("myOtherRemoteMethod"); // because service property is not set test will be called as global remote function not service method
			service.myOtherRemoteMethod();
		}
	}
}
