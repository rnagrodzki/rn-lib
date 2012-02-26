/***************************************************************************************************
 Copyright (c) 2012. Rafał Nagrodzki (rafal.nagrodzki.dev@gmail.com)
 http://rafal-nagrodzki.com/

 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/
package tests.net.remoteamfservice
{
	import com.rnlib.net.amf.AMFEvent;
	import com.rnlib.net.amf.AMFRequest;

	import mockolate.ingredients.answers.MethodInvokingAnswer;
	import mockolate.mock;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;

	public class AMFRequestTest extends RemoteAmfServiceBaseMockTest
	{
		protected var _request:AMFRequest;

		[Before]
		override public function beforeTest():void
		{
			_request = null;
			_extraArgs = null;

			super.beforeTest();
			service.endpoint = "http://example.com";
		}

		[After]
		override public function afterTest():void
		{
			_request = null;
			_extraArgs = null;

			super.afterTest();
		}

		override protected function finalAssertionOnResult(ev:AMFEvent, extra:* = null):void
		{
			_requestUID = _request.uid;
			super.finalAssertionOnResult(ev, extra);
		}

		override protected function finalAssertionOnFault(ev:AMFEvent, extra:* = null):void
		{
			_requestUID = _request.uid;
			super.finalAssertionOnFault(ev, extra);
		}

		[Test(description="Test returning object type on call", order="1", async)]
		public function testReturningTypeOnCall():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.handleEvent(this, service, AMFEvent.RESULT, finalAssertionOnResult, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "myOtherRemoteMethod";
			service.addMethod(_calledRemoteMethod);
			var req:Object = service.myOtherRemoteMethod();
			var request:AMFRequest = req as AMFRequest;

			Assert.assertNotNull(request);
			_request = request;
		}

		[Test(description="Pass extra arguments on result", order="2", async)]
		public function passExtraArgsOnResult():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.handleEvent(this, service, AMFEvent.RESULT, onExtraArgsResult, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "myOtherRemoteMethod";
			service.addMethod(_calledRemoteMethod);
			_request = service.myOtherRemoteMethod();
			_extraArgs = [3, 5];
			_request.setExtraResultParams.apply(_request, _extraArgs);
		}

		protected var _extraArgs:Array;

		protected function onExtraArgsResult(ev:AMFEvent, data:* = null):void
		{
			Assert.assertEquals(_passOnResult, ev.data.shift());
			assertThat(_extraArgs, ev.data);
		}

		protected function onExtraArgsFault(ev:AMFEvent, data:* = null):void
		{
			Assert.assertEquals(_passOnFault, ev.data.shift());
			assertThat(_extraArgs, ev.data);
		}

		[Test(description="Pass extra arguments on result", order="3", async)]
		public function passExtraArgsOnResultCallback():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.handleEvent(this, service, AMFEvent.RESULT, onExtraArgsResult, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "myOtherRemoteMethod";
			service.addMethod(_calledRemoteMethod,extraArgsResultCallback);
			_request = service.myOtherRemoteMethod();
			_extraArgs = [3, "test"];
			_request.setExtraResultParams.apply(_request, _extraArgs);
		}

		protected function extraArgsResultCallback(...rest):void
		{
			Assert.assertEquals(_passOnResult, rest.shift());
			assertThat(_extraArgs, rest);
		}

		protected function extraArgsFaultCallback(...rest):void
		{
			Assert.assertEquals(_passOnFault, rest.shift());
			assertThat(_extraArgs, rest);
		}

		[Test(description="Pass extra arguments on result", order="4", async)]
		public function passExtraArgsOnResultGlobalCallback():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.handleEvent(this, service, AMFEvent.RESULT, onExtraArgsResult, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			_passOnResult = "returnThisInResult";
			_calledRemoteMethod = "myOtherRemoteMethod";
			service.result = extraArgsResultCallback;
			service.addMethod(_calledRemoteMethod);
			_request = service.myOtherRemoteMethod();
			_extraArgs = [3, 1];
			_request.setExtraResultParams.apply(_request, _extraArgs);
		}

		[Test(description="Pass extra arguments on fault", order="5", async)]
		public function passExtraArgsOnFault():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnFault"));
			Async.handleEvent(this, service, AMFEvent.FAULT, onExtraArgsFault, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			_passOnFault = "returnThisInResult";
			_calledRemoteMethod = "myOtherRemoteMethod";
			service.addMethod(_calledRemoteMethod);
			_request = service.myOtherRemoteMethod();
			_extraArgs = [6, 5];
			_request.setExtraFaultParams.apply(_request, _extraArgs);
		}

		[Test(description="Pass extra arguments on fault", order="6", async)]
		public function passExtraArgsOnFaultCallback():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnFault"));
			Async.handleEvent(this, service, AMFEvent.FAULT, onExtraArgsFault, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			_passOnFault = "returnThisInResult";
			_calledRemoteMethod = "myOtherRemoteMethod";
			service.addMethod(_calledRemoteMethod,null,extraArgsFaultCallback);
			_request = service.myOtherRemoteMethod();
			_extraArgs = [6, 5];
			_request.setExtraFaultParams.apply(_request, _extraArgs);
		}

		[Test(description="Pass extra arguments on fault", order="7", async)]
		public function passExtraArgsOnFaultGlobalCallback():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnFault"));
			Async.handleEvent(this, service, AMFEvent.FAULT, onExtraArgsFault, TIMEOUT);
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			_passOnFault = "returnThisInResult";
			_calledRemoteMethod = "myOtherRemoteMethod";
			service.fault = extraArgsFaultCallback;
			service.addMethod(_calledRemoteMethod);
			_request = service.myOtherRemoteMethod();
			_extraArgs = [6, 5];
			_request.setExtraFaultParams.apply(_request, _extraArgs);
		}
	}
}
