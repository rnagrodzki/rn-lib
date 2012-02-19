/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package suites
{
	import tests.net.AMFNetConnectionTest;
	import tests.net.ReflexiveClientTest;
	import tests.queue.QueueTest;
	import tests.utils.ArrayUtilTest;
	import tests.utils.PaginatorTest;
	import tests.utils.XMLUtilTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class MainSuite
	{
//		public var queue:QueueTest;
//		public var arrayUtil:ArrayUtilTest;
//		public var paginator:PaginatorTest;
//		public var xmlUtil:XMLUtilTest;
//		public var extendedNetConnection:AMFNetConnectionTest;
		public var remoteAmfService:RemoteAmfServiceSuite;
//		public var reflexiveClient:ReflexiveClientTest;
//		public var amfServer:AmfServerSuite;
	}
}
