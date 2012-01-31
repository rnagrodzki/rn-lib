/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package suites
{
	import tests.net.ByteArrayPlayground;
	import tests.net.ByteArrayPlaygroundNC;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class ByteArraySuite
	{
		public var baPlayground:ByteArrayPlayground;
		public var baPlaygroundNC:ByteArrayPlaygroundNC;
	}
}
