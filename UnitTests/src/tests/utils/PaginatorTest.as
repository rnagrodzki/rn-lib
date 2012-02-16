/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.utils
{
	import com.rnlib.utils.Paginator;

	import flash.events.Event;

	import flexunit.framework.Assert;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;

	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;

	public class PaginatorTest
	{
		public static const ITEMS:int = 2;

		[Before]
		public function before():void
		{
			_bindingValue = -1;

			_p = new Paginator();
			_p.itemsPerPage = ITEMS;
			_p.dataProvider = new ArrayCollection(_c);
		}

		[After]
		public function dispose():void
		{
			_p.dispose();
			_p = null;

			_bindingValue = -1;
		}

		private var _p:Paginator;
		private var _c:Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

		[Test(description="Test class initialization", order="1")]
		public function initTest():void
		{
			Assert.assertNotNull(_p.dataProvider);
			Assert.assertNotNull(_p.collection);

			_p.dispose();

			Assert.assertNull(_p.collection);
			Assert.assertNull(_p.dataProvider);
		}

		[Test(description="Test next function", order="2")]
		public function nextTest():void
		{
			Assert.assertEquals(_p.length, Math.ceil(_c.length / ITEMS));

			_p.next();
			Assert.assertEquals(_p.currentIndex, 1);
			assertThat(_p.collection, [3, 4]);

			_p.next();
			Assert.assertEquals(_p.currentIndex, 2);
			assertThat(_p.collection, [5, 6]);
		}

		[Test(description="Test changing index", order="3")]
		public function indexTest():void
		{
			_p.currentIndex = 3;
			Assert.assertEquals(_p.currentIndex, 3);
			assertThat(_p.collection, [7, 8]);

			_p.currentIndex = 1;
			Assert.assertEquals(_p.currentIndex, 1);
			assertThat(_p.collection, [3, 4]);

			_p.currentIndex = -1;
			Assert.assertEquals(_p.currentIndex, 0);
			assertThat(_p.collection, [1, 2]);

			_p.currentIndex = -6;
			Assert.assertEquals(_p.currentIndex, 0);
			assertThat(_p.collection, [1, 2]);

			_p.currentIndex = 5;
			Assert.assertEquals(_p.currentIndex, 4);
			assertThat(_p.collection, [9, 10]);

			_p.currentIndex = 12;
			Assert.assertEquals(_p.currentIndex, 4);
			assertThat(_p.collection, [9, 10]);
		}

		[Test(description="Test prev function", order="4")]
		public function prevTest():void
		{
			_p.currentIndex = 3;
			Assert.assertEquals(_p.currentIndex, 3);
			assertThat(_p.collection, [7, 8]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex, 2);
			assertThat(_p.collection, [5, 6]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex, 1);
			assertThat(_p.collection, [3, 4]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex, 0);
			assertThat(_p.collection, [1, 2]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex, 0);
			assertThat(_p.collection, [1, 2]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex, 0);
			assertThat(_p.collection, [1, 2]);
		}

		[Test(description="Test first function", order="5")]
		public function firstTest():void
		{
			_p.currentIndex = 3;
			Assert.assertEquals(_p.currentIndex, 3);
			assertThat(_p.collection, [7, 8]);

			_p.first();
			Assert.assertEquals(_p.currentIndex, 0);
			assertThat(_p.collection, [1, 2]);

			_p.first();
			Assert.assertEquals(_p.currentIndex, 0);
			assertThat(_p.collection, [1, 2]);
		}

		[Test(description="Test last function", order="6")]
		public function lastTest():void
		{
			_p.currentIndex = 1;
			Assert.assertEquals(_p.currentIndex, 1);
			assertThat(_p.collection, [3, 4]);

			_p.last();
			Assert.assertEquals(_p.currentIndex, 4);
			assertThat(_p.collection, [9, 10]);

			_p.last();
			Assert.assertEquals(_p.currentIndex, 4);
			assertThat(_p.collection, [9, 10]);
		}

		[Test(description="Test dispose paginator", order="7")]
		public function disposeTest():void
		{
			_p.dispose();
			Assert.assertNull(_p.dataProvider);
			Assert.assertNull(_p.collection);

			_p.dispose();
			Assert.assertNull(_p.dataProvider);
			Assert.assertNull(_p.collection);
		}

		[Test(description="Test fire event on last()", order="8", async)]
		public function eventTestLast():void
		{
			Async.handleEvent(this, _p, Paginator.INDEX_CHANGED, passTest);
			_p.last();
			Assert.assertEquals(_p.currentIndex, 4);
			assertThat(_p.collection, [9, 10]);
		}

		protected function passTest(ev:Event, extra:*):void
		{
			Assert.assertEquals(Paginator.INDEX_CHANGED, ev.type);
		}

		[Test(description="Test fire event on first()", order="9", async)]
		public function eventTestFirst():void
		{
			_p.currentIndex = 3;
			Assert.assertEquals(_p.currentIndex, 3);
			assertThat(_p.collection, [7, 8]);

			Async.handleEvent(this, _p, Paginator.INDEX_CHANGED, passTest);

			_p.first();
			Assert.assertEquals(_p.currentIndex, 0);
			assertThat(_p.collection, [1, 2]);
		}

		[Test(description="Test fire event on set currentIndex()", order="10", async)]
		public function eventTestCurrentIndex():void
		{
			Async.handleEvent(this, _p, Paginator.INDEX_CHANGED, passTest);
			_p.currentIndex = 3;
			Assert.assertEquals(_p.currentIndex, 3);
			assertThat(_p.collection, [7, 8]);
		}

		[Test(description="Test fire event on next()", order="11", async)]
		public function eventTestNext():void
		{
			Async.handleEvent(this, _p, Paginator.INDEX_CHANGED, passTest);
			_p.next();
			Assert.assertEquals(_p.currentIndex, 1);
			assertThat(_p.collection, [3, 4]);
		}

		[Test(description="Test fire event on prev()", order="12", async)]
		public function eventTestPrev():void
		{
			_p.currentIndex = 3;
			Assert.assertEquals(_p.currentIndex, 3);
			assertThat(_p.collection, [7, 8]);

			Async.handleEvent(this, _p, Paginator.INDEX_CHANGED, passTest);

			_p.prev();
			Assert.assertEquals(_p.currentIndex, 2);
			assertThat(_p.collection, [5, 6]);
		}

		private var _watcher:ChangeWatcher;
		private var _bindingValue:int = -1;

		[Test(description="Binding test", order="13")]
		public function bindingTestIndexChanged():void
		{
			_watcher = BindingUtils.bindSetter(passBindingTest, _p, "currentIndex");
			Assert.assertNotNull(_watcher);
			_watcher.useWeakReference = true;

			_p.currentIndex = 3;
			Assert.assertEquals(3,_p.currentIndex);
			assertThat(_p.collection, [7, 8]);

			Assert.assertEquals(3,_bindingValue);
			Assert.assertNull(_watcher);
		}

		protected function passBindingTest(extra:int):void
		{
			if (!extra) return; // test bindings is really hard because setter is invoke directly during preparing watcher with current property value

			_bindingValue = extra;
			
			if (_watcher) _watcher.unwatch();
			_watcher = null;
		}
	}
}
