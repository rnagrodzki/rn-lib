/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package suites
{
	import tests.net.AMFBaseServerNCTest;
	import tests.net.AMFBaseServerTest;
	import tests.net.ByteArrayPlayground;
	import tests.net.ByteArrayPlaygroundNC;
	import tests.net.PHPServerFeatures;
	import tests.net.PHPServerFeaturesNC;

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
