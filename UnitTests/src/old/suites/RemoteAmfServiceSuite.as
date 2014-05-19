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
package old.suites
{
	import old.tests.net.remoteamfservice.AMFRequestTest;
	import old.tests.net.remoteamfservice.MockMethodsTest;
	import old.tests.net.remoteamfservice.PluginsTest;
	import old.tests.net.remoteamfservice.RemoteAmfServiceTest;
	import old.tests.net.remoteamfservice.ServiceProxyImplTest;
	import old.tests.net.remoteamfservice.UnpredictableUsageCases;
	import old.tests.net.remoteamfservice.PluginExceptionTest;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class RemoteAmfServiceSuite
	{
		public var base:RemoteAmfServiceTest;
		public var proxy:ServiceProxyImplTest;
		public var unpredictableUsages:UnpredictableUsageCases;
		public var plugins:PluginsTest;
//		public var pluginException:PluginExceptionTest;
		public var request:AMFRequestTest;
		public var mock:MockMethodsTest;
	}
}
