/**
 * @author Rafał Nagrodzki (http://nagrodzki.net)
 */
package tests.net.remoteamfservice
{
	import rnlib.net.amf.AMFEvent;
	import rnlib.net.plugins.INetPlugin;
	import rnlib.net.plugins.INetPluginVO;
	import rnlib.net.plugins.NetPluginEvent;
	import rnlib.net.plugins.NetPluginFactory;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import flexunit.framework.Assert;

	import mockolate.ingredients.answers.MethodInvokingAnswer;
	import mockolate.mock;
	import mockolate.stub;

	import mx.core.ClassFactory;

	import org.flexunit.async.Async;
	import org.hamcrest.object.instanceOf;
	import org.morefluent.integrations.flexunit4.after;

	import tests.net.remoteamfservice.plugins.*;
	import tests.net.remoteamfservice.plugins.vo.MultipartBrokenPlugin;
	import tests.net.remoteamfservice.plugins.vo.TestPluginVO;

	public class PluginExceptionTest extends RemoteAmfServiceBaseMockTest
	{
		[Before]
		override public function beforeTest():void
		{
			super.beforeTest();

			service.pluginsFactories = [new NetPluginFactory(MultipartBrokenPlugin)];

			service.endpoint = "http://example.com";
		}

		[After]
		override public function afterTest():void
		{
			super.afterTest();
		}

		protected function onResultCallback(result:Object):void
		{
			Assert.assertEquals(_passOnResult, result);
		}

		protected function onFaultCallback(fault:Object):void
		{
			Assert.assertEquals(_passOnFault, fault);
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

		[Test(description="Throwing exception by Plugin on getter args", order="5", async)]
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
