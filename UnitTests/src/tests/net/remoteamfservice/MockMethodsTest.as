/**
 * @author Rafał Nagrodzki (http://nagrodzki.net)
 */
package tests.net.remoteamfservice
{
	import rnlib.net.amf.AMFEvent;
	import rnlib.net.amf.RemoteAmfService;

	import flash.utils.getTimer;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	public class MockMethodsTest
	{
		public var service:RemoteAmfService;
		public static const TIMEOUT:uint = 2000;

		[Before]
		public function beforeTest():void
		{
			trace("beforeTest", getTimer());
			service = new RemoteAmfService();
			service.endpoint = "http://go.fuck.yourself/"
		}

		[After]
		public function afterTest():void
		{
			trace("afterTest", getTimer());
//			service.dispose();
//			service = null;
		}

		/*[Test(async)]
		public function basicTest():void
		{
			trace("basicTest", getTimer());
			service.addMockMethod("test_mock", prepareBasicMockData);
			service.addMethod("test_mock", basicTestResult);

			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);
			Async.handleEvent(this, service, AMFEvent.RESULT, finalAssertionOnResult, TIMEOUT);

			service.test_mock();
		}*/

		[Test(async)]
		public function basicTest2():void
		{
			trace("basicTest2", getTimer());
			service.addMethod("test_mock", basicTestResult);
			service.addMockMethod("test_mock", prepareBasicMockData);

			Async.failOnEvent(this, service, AMFEvent.FAULT, TIMEOUT);
			Async.handleEvent(this, service, AMFEvent.RESULT, finalAssertionOnResult, TIMEOUT);

			service.test_mock("test");
		}

		protected function finalAssertionOnResult(ev:AMFEvent, extra:* = null):void
		{
			trace("finalAssertionOnResult", getTimer());
		}

		protected function prepareBasicMockData(data:String):Array
		{
			trace("prepareBasicMockData", getTimer());
			return [true, 500, "passed txt"];
		}

		protected function basicTestResult(data:Object):void
		{
			trace("basicTestResult", getTimer());
			Assert.assertTrue(data is String);
			Assert.assertEquals("passed txt", data);
		}
	}
}
