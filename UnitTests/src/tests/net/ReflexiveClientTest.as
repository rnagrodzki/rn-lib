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
package tests.net
{
	import rnlib.net.amf.AMFEvent;
	import rnlib.net.amf.ClientVO;
	import rnlib.net.amf.ReflexiveClient;

	import flash.events.EventDispatcher;

	import flexunit.framework.Assert;

	import org.flexunit.async.Async;

	public class ReflexiveClientTest
	{
		[Before]
		public function before():void
		{
			_client = new ReflexiveClient();
		}

		[After]
		public function after():void
		{
			_client.dispose();
			_client = null;
		}

		protected var _client:ReflexiveClient;

		[Test(description="Creation test", order="1")]
		public function create():void
		{
			Assert.assertNotNull(_client);
		}

		[Test(description="Disposing object", order="2")]
		public function dispose():void
		{
			_client.callback = function (vo:ClientVO):void {};
			_client.dispatcher = new EventDispatcher();
			Assert.assertNotNull(_client.callback);
			Assert.assertNotNull(_client.dispatcher);

			_client.dispose();
			Assert.assertNull(_client.callback);
			Assert.assertNull(_client.dispatcher);
		}

		[Test(description="Test fire events", order="3", async)]
		public function testEvent():void
		{
			_client.dispatcher = new EventDispatcher();
			Async.handleEvent(this, _client.dispatcher, AMFEvent.HEADER, onHeaderEventReceive);

			_client.myTest("test param");
		}

		protected static function onHeaderEventReceive(ev:AMFEvent, extra:* = null):void
		{
			var vo:ClientVO = ev.data as ClientVO;
			Assert.assertNotNull(vo);
			Assert.assertNotNull(vo.name);
			Assert.assertNotNull(vo.arguments);

			Assert.assertEquals("myTest", vo.name);
			Assert.assertEquals("test param", vo.arguments[0]);
		}

		[Test(description="Test callback function", order="4")]
		public function testCallback():void
		{
			_client.callback = callbackFunction;

			_client.myTest("test param");
		}

		protected function callbackFunction(vo:ClientVO):void
		{
			Assert.assertNotNull(vo);
			Assert.assertNotNull(vo.name);
			Assert.assertNotNull(vo.arguments);

			Assert.assertEquals("myTest", vo.name);
			Assert.assertEquals("test param", vo.arguments[0]);
		}
	}
}
