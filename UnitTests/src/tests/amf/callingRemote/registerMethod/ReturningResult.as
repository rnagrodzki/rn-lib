/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.amf.callingRemote.registerMethod
{
	import tests.amf.*;
	import org.morefluent.integrations.flexunit4.after;
	import org.morefluent.integrations.flexunit4.observing;
	import org.morefluent.integrations.flexunit4.poll;
	import org.morefluent.integrations.flexunit4.times;

	import rnlib.net.amf.AMFEvent;
	import rnlib.net.amf.AMFRequest;
	import rnlib.net.amf.RemoteAmfService;

	import tests.AbstractTest;

	[TestCase(order="1")]
	public class ReturningResult extends AbstractTest
	{
		public const METHOD_NAME:String = "myMethod";

		public var calledSuccess:Boolean;

		protected var _service:RemoteAmfService;

		//---------------------------------------------------------------
		//
		//      SETUP
		//
		//---------------------------------------------------------------


		override public function setupClass():void
		{
			super.setupClass();

			_service = new RemoteAmfService();
			_service.connection = new ConnectionMock();
			_service.endpoint = "x";
			_service.service = "MyService";
		}

		override public function setup():void
		{
			super.setup();
		}

		override public function tearDown():void
		{
			super.tearDown();

			_service.removeMethod(METHOD_NAME);
			calledSuccess = false;
		}

		//---------------------------------------------------------------
		//
		//      TESTS
		//
		//---------------------------------------------------------------

		[Test(order="1", async)]
		public function raisesGlobalResultEvent():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.RESULT, 100).on(_service).pass();

			_service[METHOD_NAME]();
		}

		[Test(order="2", async)]
		public function callResultHandler():void
		{
			_service.addMethod(METHOD_NAME, callSuccessHandler_resultHandler);
			poll(100).assert(this, "calledSuccess").equals(true);

			_service[METHOD_NAME]();
		}

		protected function callSuccessHandler_resultHandler(result:Object = null):void
		{
			calledSuccess = true;
		}

		[Test(order="3", async)]
		public function raisesResultEventOnlyOnce():void
		{
			_service.addMethod(METHOD_NAME);
			observing(AMFEvent.RESULT).on(_service);
			poll(200).assert(_service).observed(AMFEvent.RESULT, times(1));

			_service[METHOD_NAME]();
		}

		[Test(order="4", async)]
		public function returnRequestObject():void
		{
			_service.addMethod(METHOD_NAME);
			var req:AMFRequest = _service[METHOD_NAME]();
			after(AMFEvent.RESULT).on(_service).assert(req).notNullValue();
		}

		[Test(order="5", async)]
		public function returnRequestObjectAndSetupCalledOnTrue():void
		{
			_service.addMethod(METHOD_NAME);
			var req:AMFRequest = _service[METHOD_NAME]();
			after(AMFEvent.RESULT).on(_service).assert(req, "called").equals(true);
		}
	}
}
