/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package suites
{
	import tests.net.AMFNetConnectionTest;
	import tests.net.RemoteAmfServiceTest;
	import tests.queue.QueueTest;
	import tests.utils.ArrayUtilTest;
	import tests.utils.PaginatorTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class MainSuite
	{
		public var queue:QueueTest;
		public var arrayUtil:ArrayUtilTest;
		public var paginator:PaginatorTest;
		public var extendedNetConnection:AMFNetConnectionTest;
		public var remoteAmfService:RemoteAmfServiceTest;
		public var amfServer:AmfServerSuite;
	}
}
