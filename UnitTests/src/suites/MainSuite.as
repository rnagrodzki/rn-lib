/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package suites
{
	import tests.queue.QueueTest;
	import tests.utils.ArrayUtilTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class MainSuite
	{
		public var queue : QueueTest;
		public var arrayUtil : ArrayUtilTest;
	}
}
