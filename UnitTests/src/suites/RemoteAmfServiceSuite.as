/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package suites
{
	import tests.net.remoteamfservice.AMFRequestTest;
	import tests.net.remoteamfservice.PluginsTest;
	import tests.net.remoteamfservice.RemoteAmfServiceTest;
	import tests.net.remoteamfservice.UnpredictableUsageCases;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class RemoteAmfServiceSuite
	{
		public var base:RemoteAmfServiceTest;
		public var unpredictableUsages:UnpredictableUsageCases;
		public var plugins:PluginsTest;
		public var request:AMFRequestTest;
	}
}
