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
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

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

		public static const TIMEOUT:int = 100;

		[Before]
		public function before():void
		{
			_requestUID = -1;
			_intervalID = -1;

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
			_calledRemoteMethod = null;
			_passOnFault = null;
			_passOnResult = null;
			_requestUID = -1;
			if (_intervalID > -1)
				clearTimeout(_intervalID);
			_intervalID = -1;
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
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			_passOnResult = "returnThisInResult";
			service.addMethod("test");
			service.test(); //this throw Error because endpoint is not set
		}

		[Test(description="Test adding remote methods and calling", order="6", async)]
		public function testAddingRemoteMethods():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.handleEvent(this, service, AMFEvent.RESULT, finalAssertionOnResult, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			service.endpoint = "http://example.com";
			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "myOtherRemoteMethod";
			service.addMethod("myOtherRemoteMethod"); // because service property is not set test will be called as global remote function not service method
			_requestUID = service.myOtherRemoteMethod();
		}

		protected function finalAssertionOnResult(ev:AMFEvent, extra:* = null):void
		{
			Assert.assertEquals(_requestUID, ev.uid);
			Assert.assertEquals(_passOnResult, ev.data);
		}

		protected function finalAssertionOnFault(ev:AMFEvent, extra:* = null):void
		{
			Assert.assertEquals(_requestUID, ev.uid);
			Assert.assertEquals(_passOnFault, ev.data);
		}

		protected var _calledRemoteMethod:String;
		protected var _passOnResult:Object;
		protected var _requestUID:int;
		protected var _intervalID:int = -1;

		public function callOnResult(method:String, result:Function, fault:Function):void
		{
			Assert.assertEquals(_calledRemoteMethod, method);
			_intervalID = setTimeout(delayFunction, 1, result, _passOnResult);
		}

		protected var _passOnFault:Object;

		public function callOnFault(method:String, result:Function, fault:Function):void
		{
			Assert.assertEquals(_calledRemoteMethod, method);
			_intervalID = setTimeout(delayFunction, 1, fault, _passOnFault);
		}

		/**
		 * Imitate response from server
		 * @param rest
		 */
		protected function delayFunction(...rest):void
		{
			clearTimeout(_intervalID);
			_intervalID = -1;
			var f:Function = rest.shift();
			f.apply(service, rest);
		}

		[Test(description="Test adding remote methods and calling", order="7", async)]
		public function callingRemoteMethodOfService():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.handleEvent(this, service, AMFEvent.RESULT, finalAssertionOnResult, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			service.endpoint = "http://example.com";
			service.service = "ExampleService";
			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "ExampleService.myOtherRemoteMethod";
			service.addMethod("myOtherRemoteMethod");
			_requestUID = service.myOtherRemoteMethod();
		}

		[Test(description="Test calling remote method with fault", order="8", async)]
		public function callingRemoteMethodFault():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnFault"));
			Async.handleEvent(this, service, AMFEvent.FAULT, finalAssertionOnFault, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			service.endpoint = "http://example.com";
			_passOnFault = "returnThisInFault";
			_calledRemoteMethod = "myFaultRemoteMethod";
			service.addMethod("myFaultRemoteMethod");
			_requestUID = service.myFaultRemoteMethod();
		}

		[Test(description="Test calling remote method with fault", order="9", async)]
		public function callingRemoteMethodOfServiceFault():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnFault"));
			Async.handleEvent(this, service, AMFEvent.FAULT, finalAssertionOnFault, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			service.endpoint = "http://example.com";
			service.service = "ExampleService";
			_passOnFault = "returnThisInFault";
			_calledRemoteMethod = "ExampleService.myFaultRemoteMethod";
			service.addMethod("myFaultRemoteMethod");
			_requestUID = service.myFaultRemoteMethod();
		}

		[Test(description="Test capture repsonse by method callback", order="10", async)]
		public function callingRemoteMethodOfService_Callback():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			service.endpoint = "http://example.com";
			service.service = "ExampleService";
			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "ExampleService.myOtherRemoteMethod";
			service.addMethod("myOtherRemoteMethod", onResultCallback, onFaultCallback);
			_requestUID = service.myOtherRemoteMethod();
		}

		protected function onResultCallback(result:Object):void
		{
			Assert.assertEquals(_passOnResult, result);
		}

		protected function onFaultCallback(fault:Object):void
		{
			Assert.assertEquals(_passOnFault, fault);
		}

		[Test(description="Test capture repsonse by method callback", order="11", async)]
		public function callingRemoteMethodOfServiceFault_Callback():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnFault"));
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			service.endpoint = "http://example.com";
			service.service = "ExampleService";
			_passOnFault = "returnThisInFault";
			_calledRemoteMethod = "ExampleService.myFaultRemoteMethod";
			service.addMethod("myFaultRemoteMethod", onResultCallback, onFaultCallback);
			_requestUID = service.myFaultRemoteMethod();
		}

		[Test(description="Test capture repsonse by service callback", order="12", async)]
		public function callingRemoteMethodOfService_GlobalCallback():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			service.endpoint = "http://example.com";
			service.service = "ExampleService";
			service.result = onResultCallback;
			service.fault = onFaultCallback;
			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "ExampleService.myOtherRemoteMethod";
			service.addMethod("myOtherRemoteMethod");
			_requestUID = service.myOtherRemoteMethod();
		}

		[Test(description="Test capture repsonse by service callback", order="13", async)]
		public function callingRemoteMethodOfServiceFault_GlobalCallback():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnFault"));
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			service.endpoint = "http://example.com";
			service.service = "ExampleService";
			service.result = onResultCallback;
			service.fault = onFaultCallback;
			_passOnFault = "returnThisInFault";
			_calledRemoteMethod = "ExampleService.myFaultRemoteMethod";
			service.addMethod("myFaultRemoteMethod");
			_requestUID = service.myFaultRemoteMethod();
		}

		[Test(description="Test callbacks priority", order="14", async)]
		public function callingRemoteMethodOfService_PriorityCallbacks():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			service.endpoint = "http://example.com";
			service.service = "ExampleService";
			service.result = faultOnServiceCallback;
			service.fault = faultOnServiceCallback;
			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "ExampleService.myOtherRemoteMethod";
			service.addMethod("myOtherRemoteMethod", onResultCallback, onFaultCallback);
			_requestUID = service.myOtherRemoteMethod();
		}

		protected function faultOnServiceCallback(data:Object):void
		{
			fail("Bad callback priority");
		}

		[Test(description="Test callbacks priority", order="15", async)]
		public function callingRemoteMethodOfServiceFault_PriorityCallbacks():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnFault"));
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			service.endpoint = "http://example.com";
			service.service = "ExampleService";
			service.result = faultOnServiceCallback;
			service.fault = faultOnServiceCallback;
			_passOnFault = "returnThisInFault";
			_calledRemoteMethod = "ExampleService.myFaultRemoteMethod";
			service.addMethod("myFaultRemoteMethod", onResultCallback, onFaultCallback);
			_requestUID = service.myFaultRemoteMethod();
		}
	}
}
