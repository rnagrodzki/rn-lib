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

	[TestCase(order="2")]
	public class ReturningFault extends AbstractTest
	{
		public const METHOD_NAME:String = "myMethod";

		public var calledFault:Boolean;

		protected var _service:RemoteAmfService;

		//---------------------------------------------------------------
		//
		//      SETUP
		//
		//---------------------------------------------------------------


		override public function setupClass():void
		{
			super.setupClass();

			var conn:ConnectionMock = new ConnectionMock(false);
			conn.dataToPass = {level: "error"};

			_service = new RemoteAmfService();
			_service.connection = conn;
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
			calledFault = false;
		}

		//---------------------------------------------------------------
		//
		//      TESTS
		//
		//---------------------------------------------------------------

		[Test(order="1", async)]
		public function raisesGlobalFaultEvent():void
		{
			_service.addMethod(METHOD_NAME);
			after(AMFEvent.FAULT, 100).on(_service).pass();

			_service[METHOD_NAME]();
		}

		[Test(order="2", async)]
		public function callFaultHandler():void
		{
			_service.addMethod(METHOD_NAME, null, callFaultHandler_faultHandler);
			poll(100).assert(this, "calledFault").equals(true);

			_service[METHOD_NAME]();
		}

		protected function callFaultHandler_faultHandler(result:Object = null):void
		{
			calledFault = true;
		}

		[Test(order="3", async)]
		public function raisesFaultEventOnlyOnce():void
		{
			_service.addMethod(METHOD_NAME);
			observing(AMFEvent.FAULT).on(_service);
			poll(200).assert(_service).observed(AMFEvent.FAULT, times(1));

			_service[METHOD_NAME]();
		}

		[Test(order="4", async)]
		public function returnRequestObject():void
		{
			_service.addMethod(METHOD_NAME);
			var req:AMFRequest = _service[METHOD_NAME]();
			after(AMFEvent.FAULT).on(_service).assert(req).notNullValue();
		}

		[Test(order="5", async)]
		public function returnRequestObjectAndSetupCalledOnTrue():void
		{
			_service.addMethod(METHOD_NAME);
			var req:AMFRequest = _service[METHOD_NAME]();
			after(AMFEvent.FAULT).on(_service).assert(req, "called").equals(true);
		}
	}
}
