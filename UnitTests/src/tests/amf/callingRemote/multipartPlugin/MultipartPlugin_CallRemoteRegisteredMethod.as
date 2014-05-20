/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.amf.callingRemote.multipartPlugin
{
	import mx.core.ClassFactory;

	import org.morefluent.integrations.flexunit4.after;

	import rnlib.net.amf.AMFEvent;
	import rnlib.net.amf.AMFRequest;
	import rnlib.net.amf.RemoteAmfService;
	import rnlib.net.plugins.NetPluginEvent;
	import rnlib.net.plugins.NetPluginFactory;

	import tests.AbstractTest;
	import tests.amf.callingRemote.multipartPlugin.mocks.MultipartPluginMock;
	import tests.amf.callingRemote.multipartPlugin.mocks.MultipartPluginMockSequenceVO;
	import tests.amf.callingRemote.multipartPlugin.mocks.MultipartPluginMockVO;
	import tests.amf.mocks.ConnectionMock;

	[TestCase(order="1")]
	public class MultipartPlugin_CallRemoteRegisteredMethod extends AbstractTest
	{
		public const METHOD_NAME:String = "myMethod";

		protected var _service:RemoteAmfService;

		override public function setupClass():void
		{
			super.setupClass();

			var connection:ConnectionMock = new ConnectionMock();
			var factory:NetPluginFactory = new NetPluginFactory(MultipartPluginMock, MultipartPluginMockVO);
			factory.properties = {connection: connection};

			_service = new RemoteAmfService();
			_service.connection = connection;
			_service.endpoint = "x";
			_service.service = "MyService";
			_service.pluginsFactories = [factory];
		}

		[Before]
		override public function setup():void
		{
			super.setup();
			_service.addMethod(METHOD_NAME);
		}

		[After]
		override public function tearDown():void
		{
			_service.removeMethod(METHOD_NAME);
			super.tearDown();
		}

		//---------------------------------------------------------------
		//
		//      TEST
		//
		//---------------------------------------------------------------

		[Test(order="1", async)]
		public function raisesGlobalResultEventOnServerResult():void
		{
			after(AMFEvent.RESULT, 100).on(_service).pass();
			after(AMFEvent.FAULT, 100).on(_service).fail();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{event: new NetPluginEvent(NetPluginEvent.COMPLETE)}
			]);
		}

		[Test(order="2", async)]
		public function raisesGlobalFaultEventOnCancelEvent():void
		{
			after(AMFEvent.FAULT, 100).on(_service).pass();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{event: new NetPluginEvent(NetPluginEvent.CANCEL)},
				{event: new NetPluginEvent(NetPluginEvent.COMPLETE)}
			]);
		}

		[Test(order="3", async)]
		public function raisesGlobalFaultEventOnCancelRequest():void
		{
			after(AMFEvent.FAULT, 100).on(_service).pass();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{event: new NetPluginEvent(NetPluginEvent.COMPLETE)}
			]).cancel();
		}

		[Test(order="4", async)]
		public function allowPluginRaisesFaultEventOnServerFault():void
		{
			after(AMFEvent.FAULT, 100).on(_service).pass();
			after(AMFEvent.RESULT, 100).on(_service).fail();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{
					event: new NetPluginEvent(NetPluginEvent.READY),
					responseStatus: 0
				},
				{
					event: new NetPluginEvent(NetPluginEvent.COMPLETE),
					faultEvent: new NetPluginEvent(NetPluginEvent.CANCEL)
				}
			]);
		}

		[Test(order="4", async)]
		public function allowPluginRaisesResultEventOnServerFault():void
		{
			after(AMFEvent.RESULT, 100).on(_service).pass();
			after(AMFEvent.FAULT, 100).on(_service).fail();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{
					event: new NetPluginEvent(NetPluginEvent.READY),
					responseStatus: 0
				},
				{
					event: new NetPluginEvent(NetPluginEvent.CANCEL),
					faultEvent: new NetPluginEvent(NetPluginEvent.COMPLETE)
				}
			]);
		}

		protected function callInSequence(arr:Array):AMFRequest
		{
			var sequence:Array = [];
			var factory:ClassFactory = new ClassFactory(MultipartPluginMockSequenceVO);

			for each (var props:Object in arr)
			{
				factory.properties = props;
				sequence.push(factory.newInstance());
			}

			var vo:MultipartPluginMockVO = new MultipartPluginMockVO();
			vo.eventsSequence = sequence;
			return _service[METHOD_NAME](vo);
		}
	}
}
