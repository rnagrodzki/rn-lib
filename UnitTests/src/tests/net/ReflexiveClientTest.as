/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.amf.AMFEvent;
	import com.rnlib.net.amf.ClientVO;
	import com.rnlib.net.amf.ReflexiveClient;

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
