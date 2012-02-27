/*
 * Copyright (c) 2012. Rafał Nagrodzki (rafal[dot]nagrodzki[dot]dev[at]gmail[dot]com)
 *  http://rafal-nagrodzki.com/
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
