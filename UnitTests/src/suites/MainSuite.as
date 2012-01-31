/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package suites
{
	import tests.net.AMFBaseServerNCTest;
	import tests.net.AMFNetConnectionTest;
	import tests.net.AMFBaseServerTest;
	import tests.net.PHPServerFeatures;
	import tests.net.PHPServerFeatures2;
	import tests.net.RemoteAmfServiceTest;
	import tests.queue.QueueTest;
	import tests.utils.ArrayUtilTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class MainSuite
	{
		public var queue:QueueTest;
		public var arrayUtil:ArrayUtilTest;
		public var extendedNetConnection:AMFNetConnectionTest;
		public var remoteAmfService:RemoteAmfServiceTest;
		public var amfServer:AMFBaseServerTest;
		public var amfServer2:AMFBaseServerNCTest;
		public var phpServerFeatures:PHPServerFeatures;
		public var phpServerFeatures2:PHPServerFeatures2;
		public var baSuite:ByteArraySuite;
	}
}
