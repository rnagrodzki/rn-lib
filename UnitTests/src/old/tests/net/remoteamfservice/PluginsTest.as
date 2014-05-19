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
package old.tests.net.remoteamfservice
{
	import tests.net.remoteamfservice.*;
	import rnlib.net.amf.AMFErrorVO;
	import rnlib.net.amf.AMFEvent;
	import rnlib.net.plugins.INetPlugin;
	import rnlib.net.plugins.INetPluginVO;
	import rnlib.net.plugins.NetPluginEvent;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import flexunit.framework.Assert;

	import mockolate.ingredients.answers.MethodInvokingAnswer;
	import mockolate.mock;
	import mockolate.stub;

	import org.flexunit.async.Async;
	import org.hamcrest.object.instanceOf;
	import org.morefluent.integrations.flexunit4.after;

	import old.tests.net.remoteamfservice.plugins.TestPluginFactory;
	import old.tests.net.remoteamfservice.plugins.vo.BrokenPluginVO;
	import old.tests.net.remoteamfservice.plugins.vo.TestPluginVO;

	public class PluginsTest extends RemoteAmfServiceBaseMockTest
	{
		[Mock(type="strict")]
		public var plugin:INetPlugin;

		[Before]
		override public function beforeTest():void
		{
			stub(plugin).method("dispose");
			mock(plugin).setter("dispatcher").arg(instanceOf(IEventDispatcher));
			mock(plugin).getter("dispatcher").returns(new EventDispatcher());
			stub(plugin).method("addEventListener").anyArgs();
			stub(plugin).method("removeEventListener").anyArgs();

			super.beforeTest();

			service.endpoint = "http://example.com";
		}

		[Test(description="Test adding plugin and calling request", order="1", async)]
		public function addPluginAndCall():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));
			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);
			Async.proceedOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			_passOnResult = "testValue";
			mock(plugin).method("init")
					.args(instanceOf(INetPluginVO))
					.dispatches(new NetPluginEvent(NetPluginEvent.COMPLETE), 10);
			mock(plugin).getter("args").returns([_passOnResult]);

			service.endpoint = "http://example.com";
			_calledRemoteMethod = service.service + ".testPlugin";
			service.pluginsFactories = [new TestPluginFactory(plugin, TestPluginVO)];
			service.addMethod("testPlugin", onResultCallback, onFaultCallback);
			_requestUID = service.testPlugin(new TestPluginVO()).uid;
		}

		protected function onResultCallback(result:Object):void
		{
			Assert.assertEquals(_passOnResult, result);
		}

		protected function onFaultCallback(fault:Object):void
		{
			Assert.assertEquals(_passOnFault, fault);
		}

		[Test(description="Test sending cancel by plugin on init", order="2", async)]
		public function pluginCancelEvent():void
		{
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);
			Async.proceedOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			_passOnFault = "Ignore by user";
			mock(plugin).method("init")
					.args(instanceOf(INetPluginVO))
					.dispatches(new NetPluginEvent(NetPluginEvent.CANCEL, _passOnFault), 10);
			mock(plugin).getter("args").returns([_passOnFault]);

			_calledRemoteMethod = service.service + ".testPlugin";
			service.pluginsFactories = [new TestPluginFactory(plugin, TestPluginVO)];
			service.addMethod("testPlugin", onResultCallback, onFaultCallback);
			_requestUID = service.testPlugin(new TestPluginVO()).uid;
		}

		[Test(description="Try pass into remote method unregisters PluginVO", order="3", expects="Error")]
		public function tryPassUnregisteredPluginVO():void
		{
			service.pluginsFactories = [new TestPluginFactory(plugin, TestPluginVO)];
			service.addMethod("testPlugin", onResultCallback, onFaultCallback);
			_requestUID = service.testPlugin(new BrokenPluginVO()).uid;
		}

		[Test(description="Throwing exception by Plugin on init", order="4", async)]
		public function throwExceptionByPluginOnInit():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));

			after(AMFEvent.FAULT).on(service).pass();
			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);

			_passOnFault = new Error("Error by plugin vo init method");
			mock(plugin).method("init")
					.args(instanceOf(INetPluginVO))
					.throws(_passOnFault as Error);

			_calledRemoteMethod = service.service + ".testPlugin";
			service.pluginsFactories = [new TestPluginFactory(plugin, TestPluginVO)];
			service.addMethod("testPlugin", onResultCallback, onFaultCallback);
			_requestUID = service.testPlugin(new TestPluginVO()).uid;
		}

		[Test(description="Throwing exception by Plugin on geter args", order="5", async)]
		public function throwExceptionByPluginOnArgs():void
		{
			mock(exConn).method("call").answers(new MethodInvokingAnswer(this, "callOnResult"));

			Async.failOnEvent(this, service, AMFEvent.RESULT, TIMEOUT);
			Async.proceedOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);

			_passOnFault = new Error("Error by plugin vo args method");
			mock(plugin).method("init")
					.args(instanceOf(INetPluginVO))
					.dispatches(new NetPluginEvent(NetPluginEvent.COMPLETE), 10);
			mock(plugin).getter("args").throws(_passOnFault as Error);

			_calledRemoteMethod = service.service + ".testPlugin";
			service.pluginsFactories = [new TestPluginFactory(plugin, TestPluginVO)];
			service.addMethod("testPlugin", onResultCallback, onFaultCallback);
			_requestUID = service.testPlugin(new TestPluginVO()).uid;
		}
	}
}
