/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package suites
{
	import tests.net.server.AMFBaseServerNCTest;
	import tests.net.server.AMFBaseServerTest;
	import tests.net.server.ByteArrayPlayground;
	import tests.net.server.ByteArrayPlaygroundNC;
	import tests.net.server.PHPServerFeatures;
	import tests.net.server.PHPServerFeaturesNC;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class AmfServerSuite
	{
		public var amfServer:AMFBaseServerTest;
		public var amfServer2:AMFBaseServerNCTest;
		public var phpServerFeatures:PHPServerFeatures;
		public var phpServerFeatures2:PHPServerFeaturesNC;
		public var baPlayground:ByteArrayPlayground;
		public var baPlaygroundNC:ByteArrayPlaygroundNC;
	}
}
