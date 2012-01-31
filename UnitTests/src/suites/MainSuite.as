/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package suites
{
	import tests.net.AMFULConnectionTest;
	import tests.net.ExtendedNetConnectionTest;
	import tests.net.PHPServerFeatures;
	import tests.net.RemoteAmfServiceTest;
	import tests.queue.QueueTest;
	import tests.utils.ArrayUtilTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class MainSuite
	{
		public var queue : QueueTest;
		public var arrayUtil : ArrayUtilTest;
		public var extendedNetConnection:ExtendedNetConnectionTest;
		public var remoteAmfService:RemoteAmfServiceTest;
		public var amfULConection:AMFULConnectionTest;
		public var phpServerFeatures:PHPServerFeatures;
	}
}
