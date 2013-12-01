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
package tests.net.remoteamfservice
{
	import rnlib.net.RequestConcurrency;
	import rnlib.net.amf.AMFEvent;
	import rnlib.net.plugins.FileReferencePlugin;
	import rnlib.net.plugins.FileReferencePluginVO;
	import rnlib.net.plugins.NetPluginFactory;

	import flexunit.framework.Assert;

	import mockolate.ingredients.answers.MethodInvokingAnswer;
	import mockolate.mock;
	import mockolate.received;

	import org.flexunit.asserts.fail;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;

	public class RemoteAmfServiceTest extends RemoteAmfServiceBaseMockTest
	{
		[Test(description="Check property after create", order="1")]
		public function checkPropertyAfterCreate():void
		{
			Assert.assertNotNull(service.connection);
			Assert.assertNull(service.service);
			Assert.assertNull(service.endpoint);
			Assert.assertNotNull(service.dataCollection);
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

			var plugins:Array = [new NetPluginFactory(FileReferencePlugin, FileReferencePluginVO)];
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
			_requestUID = service.myOtherRemoteMethod().uid;
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
			_requestUID = service.myOtherRemoteMethod().uid;
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
			_requestUID = service.myFaultRemoteMethod().uid;
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
			_requestUID = service.myFaultRemoteMethod().uid;
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
			_requestUID = service.myOtherRemoteMethod().uid;
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
			_requestUID = service.myFaultRemoteMethod().uid;
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
			_requestUID = service.myOtherRemoteMethod().uid;
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
			_requestUID = service.myFaultRemoteMethod().uid;
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
			_requestUID = service.myOtherRemoteMethod().uid;
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
			_requestUID = service.myFaultRemoteMethod().uid;
		}
	}
}
