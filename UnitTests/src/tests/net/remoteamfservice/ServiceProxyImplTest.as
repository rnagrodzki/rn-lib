/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
 * A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/

/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.net.remoteamfservice
{
	import org.flexunit.Assert;

	import rnlib.net.amf.RemoteAmfService;

	public class ServiceProxyImplTest
	{

		public var service:RemoteAmfService;

		public static const TIMEOUT:int = 100;

		[Before]
		public function beforeTest():void
		{
			service = new RemoteAmfService();
		}

		[After]
		public function afterTest():void
		{
			service.dispose();
			service = null;
		}

		[Test]
		public function addPropertyTest():void
		{
			service.myTestProp = "test";
			Assert.assertEquals("test", service.myTestProp);
			Assert.assertEquals("test", service["myTest"+"Prop"]);
		}

		[Test]
		public function deletePropertyTest():void
		{
			service.propToDelete = "test";
			Assert.assertEquals("test", service.propToDelete);
			Assert.assertTrue(delete service.propToDelete);
			Assert.assertFalse(service.hasOwnProperty("propToDelete"));
			Assert.assertNull(service.propToDelete);
		}

		[Test]
		public function testForEach():void
		{
			service.myTestProp = "test";
			service.myTestProp2 = "test";
			service.myTest = "test";
			var i:int = 0;

			for each (var data:Object in service)
			{
				Assert.assertEquals("test",data);
				i++;
			}
			Assert.assertEquals(3,i);
		}
	}
}
