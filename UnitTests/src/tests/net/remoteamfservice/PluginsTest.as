/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.remoteamfservice
{
	import com.rnlib.net.amf.AMFEvent;
	import com.rnlib.net.amf.RemoteAmfService;
	import com.rnlib.net.amf.connections.IAMFConnection;
	import com.rnlib.net.amf.plugins.IPlugin;
	import com.rnlib.net.amf.plugins.IPluginVO;
	import com.rnlib.net.amf.plugins.PluginEvent;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import flexunit.framework.Assert;

	import mockolate.ingredients.answers.MethodInvokingAnswer;
	import mockolate.mock;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import org.flexunit.async.Async;
	import org.hamcrest.object.instanceOf;

	import tests.net.remoteamfservice.plugins.BrokenPluginVO;

	import tests.net.remoteamfservice.plugins.TestPluginFactory;
	import tests.net.remoteamfservice.plugins.TestPluginVO;

	public class PluginsTest
	{

		[Rule]
		public var mocks:MockolateRule = new MockolateRule();

		[Mock(type="strict")]
		public var exConn:IAMFConnection;

		[Mock(type="strict")]
		public var plugin:IPlugin;

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
			mock(exConn).getter("connected").returns(true);
			stub(exConn).method("addEventListener").anyArgs();
			stub(exConn).method("removeEventListener").anyArgs();
			mock(exConn).setter("reconnectRepeatCount").arg(uint);
			mock(exConn).setter("redispatcher").arg(instanceOf(IEventDispatcher));

			stub(plugin).method("dispose");
			mock(plugin).setter("dispatcher").arg(instanceOf(IEventDispatcher));
			mock(plugin).getter("dispatcher").returns(new EventDispatcher());

			service = new RemoteAmfService();
			service.connection = exConn;
			service.endpoint = "http://dummy.com";
			service.service = "ExampleService";
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

		[Test(description="Test adding plugin and calling request", order="1", async)]
		public function addPluginAndCall():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			_passOnResult = "testValue";
			mock(plugin).method("init")
					.args(instanceOf(IPluginVO))
					.dispatches(new PluginEvent(PluginEvent.COMPLETE), 10);
			mock(plugin).getter("args").returns([_passOnResult]);

			_calledRemoteMethod = service.service + ".testPlugin";
			service.pluginsFactories = [new TestPluginFactory(plugin, TestPluginVO)];
			service.addMethod("testPlugin", onResultCallback, onFaultCallback);
			_requestUID = service.testPlugin(new TestPluginVO());
		}

		protected function onResultCallback(result:Object):void
		{
			Assert.assertEquals(_passOnResult, result);
		}

		protected function onFaultCallback(fault:Object):void
		{
			Assert.assertEquals(_passOnFault, fault);
		}

		protected var _calledRemoteMethod:String;
		protected var _passOnResult:Object;
		protected var _requestUID:int;
		protected var _intervalID:int = -1;

		public function callOnResult(method:String, result:Function, fault:Function, ...rest):void
		{
			Assert.assertEquals(_calledRemoteMethod, method);
			_intervalID = setTimeout.apply(null, [delayFunction, 1, result].concat(rest));
		}

		protected var _passOnFault:Object;

		public function callOnFault(method:String, result:Function, fault:Function, ...rest):void
		{
			Assert.assertEquals(_calledRemoteMethod, method);
			_intervalID = setTimeout.apply(null, [delayFunction, 1, fault].concat(rest));
		}

		/**
		 * Imitate response from server by making truly async response
		 * @param rest
		 */
		protected function delayFunction(...rest):void
		{
			clearTimeout(_intervalID);
			_intervalID = -1;
			var f:Function = rest.shift();
			f.apply(service, rest);
		}

		[Test(description="Test sending cancel by plugin on init", order="2", async)]
		public function pluginCancelEvent():void
		{
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			_passOnFault = "testValue";
			mock(plugin).method("init")
					.args(instanceOf(IPluginVO))
					.dispatches(new PluginEvent(PluginEvent.CANCEL,_passOnFault), 10);
			mock(plugin).getter("args").returns([_passOnResult]);

			_calledRemoteMethod = service.service + ".testPlugin";
			service.pluginsFactories = [new TestPluginFactory(plugin, TestPluginVO)];
			service.addMethod("testPlugin", onResultCallback, onFaultCallback);
			_requestUID = service.testPlugin(new TestPluginVO());
		}

		[Test(description="Try pass into remote method unregisters PluginVO", order="3",expects="Error")]
		public function tryPassUnregisteredPluginVO():void
		{
			service.pluginsFactories = [new TestPluginFactory(plugin, TestPluginVO)];
			service.addMethod("testPlugin", onResultCallback, onFaultCallback);
			_requestUID = service.testPlugin(new BrokenPluginVO());
		}
	}
}
