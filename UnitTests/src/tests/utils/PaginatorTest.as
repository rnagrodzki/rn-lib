/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.utils
{
	import com.rnlib.utils.Paginator;

	import flexunit.framework.Assert;

	import mx.collections.ArrayCollection;

	import org.hamcrest.assertThat;

	public class PaginatorTest
	{
		public static const ITEMS : int = 2;

		[Before]
		public function before():void
		{
			_p = new Paginator();
			_p.itemsPerPage = ITEMS;
			_p.dataProvider = new ArrayCollection(_c);
		}

		[After]
		public function dispose():void
		{
			_p.dispose();
		}

		private var _p:Paginator;
		private var _c:Array = [1,2,3,4,5,6,7,8,9,10];

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
			Assert.assertEquals(_p.length,Math.ceil(_c.length/ITEMS));

			_p.next();
			Assert.assertEquals(_p.currentIndex,1);
			assertThat(_p.collection,[3,4]);

			_p.next();
			Assert.assertEquals(_p.currentIndex,2);
			assertThat(_p.collection,[5,6]);
		}

		[Test(description="Test changing index", order="3")]
		public function indexTest():void
		{
			_p.currentIndex = 3;
			Assert.assertEquals(_p.currentIndex,3);
			assertThat(_p.collection,[7,8]);

			_p.currentIndex = 1;
			Assert.assertEquals(_p.currentIndex,1);
			assertThat(_p.collection,[3,4]);

			_p.currentIndex = -1;
			Assert.assertEquals(_p.currentIndex,0);
			assertThat(_p.collection,[1,2]);

			_p.currentIndex = -6;
			Assert.assertEquals(_p.currentIndex,0);
			assertThat(_p.collection,[1,2]);

			_p.currentIndex = 5;
			Assert.assertEquals(_p.currentIndex,4);
			assertThat(_p.collection,[9,10]);

			_p.currentIndex = 12;
			Assert.assertEquals(_p.currentIndex,4);
			assertThat(_p.collection,[9,10]);
		}

		[Test(description="Test prev function", order="4")]
		public function prevTest():void
		{
			_p.currentIndex = 3;
			Assert.assertEquals(_p.currentIndex,3);
			assertThat(_p.collection,[7,8]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex,2);
			assertThat(_p.collection,[5,6]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex,1);
			assertThat(_p.collection,[3,4]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex,0);
			assertThat(_p.collection,[1,2]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex,0);
			assertThat(_p.collection,[1,2]);

			_p.prev();
			Assert.assertEquals(_p.currentIndex,0);
			assertThat(_p.collection,[1,2]);
		}

		[Test(description="Test first function", order="5")]
		public function firstTest():void
		{
			_p.currentIndex = 3;
			Assert.assertEquals(_p.currentIndex,3);
			assertThat(_p.collection,[7,8]);
			
			_p.first();
			Assert.assertEquals(_p.currentIndex,0);
			assertThat(_p.collection,[1,2]);
			
			_p.first();
			Assert.assertEquals(_p.currentIndex,0);
			assertThat(_p.collection,[1,2]);
		}

		[Test(description="Test last function", order="6")]
		public function lastTest():void
		{
			_p.currentIndex = 1;
			Assert.assertEquals(_p.currentIndex,1);
			assertThat(_p.collection,[3,4]);

			_p.last();
			Assert.assertEquals(_p.currentIndex,4);
			assertThat(_p.collection,[9,10]);

			_p.last();
			Assert.assertEquals(_p.currentIndex,4);
			assertThat(_p.collection,[9,10]);
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
	}
}
