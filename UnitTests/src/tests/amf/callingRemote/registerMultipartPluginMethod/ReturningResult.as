/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.amf.callingRemote.registerMultipartPluginMethod
{
	import mx.core.ClassFactory;

	import org.morefluent.integrations.flexunit4.after;

	import rnlib.net.amf.AMFEvent;
	import rnlib.net.amf.AMFRequest;
	import rnlib.net.amf.RemoteAmfService;
	import rnlib.net.plugins.NetPluginEvent;

	import tests.AbstractTest;
	import tests.amf.mocks.ConnectionMock;
	import tests.amf.mocks.TestPluginFactory;

	[TestCase(order="1")]
	public class ReturningResult extends AbstractTest
	{
		public const METHOD_NAME:String = "myMethod";

		public var calledSuccess:Boolean;

		protected var _service:RemoteAmfService;

		override public function setupClass():void
		{
			super.setupClass();

			_service = new RemoteAmfService();
			_service.connection = new ConnectionMock();
			_service.endpoint = "x";
			_service.service = "MyService";
			_service.pluginsFactories = [
				new TestPluginFactory(new ClassFactory(MultipartPluginMock),MultipartPluginMockVO)];
		}

		[Before]
		override public function setup():void
		{
			super.setup();
		}

		[After]
		override public function tearDown():void
		{
			super.tearDown();
			_service.removeMethod(METHOD_NAME);
			calledSuccess = false;
		}

		//---------------------------------------------------------------
		//
		//      TEST
		//
		//---------------------------------------------------------------

		[Test(order="1", async)]
		public function raisesGlobalResultEvent():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.RESULT, 100).on(_service).pass();

			var vo:MultipartPluginMockVO = new MultipartPluginMockVO();
			vo.eventsSequence = [
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.READY)),
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.READY)),
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.COMPLETE))
			];
			_service[METHOD_NAME](vo);
		}

		[Test(order="2", async)]
		public function raisesGlobalFaultEventOnCancelEvent():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.FAULT, 100).on(_service).pass();

			var vo:MultipartPluginMockVO = new MultipartPluginMockVO();
			vo.eventsSequence = [
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.READY)),
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.CANCEL)),
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.COMPLETE))
			];
			_service[METHOD_NAME](vo);
		}

		[Test(order="3", async)]
		public function raisesGlobalFaultEventOnCancelRequest():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.FAULT, 100).on(_service).pass();

			var vo:MultipartPluginMockVO = new MultipartPluginMockVO();
			vo.eventsSequence = [
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.READY)),
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.READY)),
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.COMPLETE))
			];
			var req:AMFRequest = _service[METHOD_NAME](vo);
			req.cancel();
		}

		[Test(order="4", async)]
		public function raisesGlobalFaultEventOnErrorOnInit():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.FAULT, 100).on(_service).pass();

			var vo:MultipartPluginMockVO = new MultipartPluginMockVO();
			vo.eventsSequence = [
				new MultipartPluginMockSequenceVO(
						new NetPluginEvent(NetPluginEvent.READY), new Error("Init exception")),
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.COMPLETE))
			];
			_service[METHOD_NAME](vo);
		}

		[Test(order="5", async)]
		public function raisesGlobalFaultEventOnErrorOnResult():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.FAULT, 100).on(_service).pass();

			var vo:MultipartPluginMockVO = new MultipartPluginMockVO();
			vo.eventsSequence = [
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.READY)),
				new MultipartPluginMockSequenceVO(
						new NetPluginEvent(NetPluginEvent.COMPLETE), new Error("Init exception"))
			];
			_service[METHOD_NAME](vo);
		}

		[Test(order="6", async)]
		public function raisesGlobalFaultEventOnErrorOnInitOccureAfterEvent():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.FAULT, 100).on(_service).pass();

			var vo:MultipartPluginMockVO = new MultipartPluginMockVO();
			vo.eventsSequence = [
				new MultipartPluginMockSequenceVO(
						new NetPluginEvent(NetPluginEvent.READY), new Error("Init exception"), false),
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.COMPLETE))
			];
			_service[METHOD_NAME](vo);
		}

		[Test(order="7", async)]
		public function raisesGlobalResultEventOnResultBeforeErrorOccure():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.RESULT, 100).on(_service).pass();

			var vo:MultipartPluginMockVO = new MultipartPluginMockVO();
			vo.eventsSequence = [
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.READY)),
				new MultipartPluginMockSequenceVO(
						new NetPluginEvent(NetPluginEvent.COMPLETE), new Error("Init exception"), false)
			];
			_service[METHOD_NAME](vo);
		}

		[Test(order="8", async)]
		public function raisesGlobalFaultEventOnErrorOnReadyOccureAfterEvent():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.FAULT, 100).on(_service).pass();

			var vo:MultipartPluginMockVO = new MultipartPluginMockVO();
			vo.eventsSequence = [
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.READY)),
				new MultipartPluginMockSequenceVO(
						new NetPluginEvent(NetPluginEvent.READY), new Error("Init exception"), false),
				new MultipartPluginMockSequenceVO(new NetPluginEvent(NetPluginEvent.COMPLETE))
			];
			_service[METHOD_NAME](vo);
		}
	}
}
