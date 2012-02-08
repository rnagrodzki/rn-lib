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
		public function before():void
		{
			_p = new Paginator();
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
			const ITEMS : int = 2;

			_p.itemsPerPage = ITEMS;
			Assert.assertEquals(_p.length,Math.ceil(_c.length/ITEMS));
			_p.next();

			Assert.assertEquals(_p.currentIndex,1);
			assertThat(_p.collection,[3,4]);
		}
	}
}
