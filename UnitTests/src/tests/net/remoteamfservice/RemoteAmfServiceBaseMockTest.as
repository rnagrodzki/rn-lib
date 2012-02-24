/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.remoteamfservice
{
	import com.rnlib.net.amf.AMFEvent;
	import com.rnlib.net.amf.RemoteAmfService;
	import com.rnlib.net.amf.connections.IAMFConnection;

	import flash.events.IEventDispatcher;

	import mockolate.mock;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.flexunit.Assert;
	import org.flexunit.rules.IMethodRule;
	import org.hamcrest.object.instanceOf;
	import org.morefluent.integrations.flexunit4.MorefluentRule;

	public class RemoteAmfServiceBaseMockTest
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
		public function beforeTest():void
		{
			_requestUID = -1;

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
		public function afterTest():void
		{
			service.dispose();
			service = null;
			_calledRemoteMethod = null;
			_passOnFault = null;
			_passOnResult = null;
			_requestUID = -1;
		}

		protected var _calledRemoteMethod:String;
		protected var _passOnResult:Object;
		protected var _requestUID:int;
		protected var _passOnFault:Object;

		public function RemoteAmfServiceBaseMockTest()
		{
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

		public function callOnResult(method:String, result:Function, fault:Function):void
		{
			Assert.assertEquals(_calledRemoteMethod, method);
			result(_passOnResult);
		}

		public function callOnFault(method:String, result:Function, fault:Function):void
		{
			Assert.assertEquals(_calledRemoteMethod, method);
			fault(_passOnFault);
		}
	}
}
