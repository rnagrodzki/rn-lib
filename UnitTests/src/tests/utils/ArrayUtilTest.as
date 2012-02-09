/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.utils
{
	import com.rnlib.utils.ArrayUtil;

	import org.flexunit.Assert;

	public class ArrayUtilTest
	{
		[Test(description="Test looking for item when exist in array", order="1")]
		public function testFindItem():void
		{
			var a:Array = ["as", "mxml", "this"];
			Assert.assertEquals(ArrayUtil.getItemIndex("this", a), 2);

			var o:Object = {name:"this"};
			var b:Array = [
				{name:"this"},
				{name:"other"},
				o,
				{position:2}
			];
			Assert.assertEquals(ArrayUtil.getItemIndex(o, b), 2);
		}

		[Test(description="Test looking for item when doesn't exist in array", order="2")]
		public function testFindItem2():void
		{
			var a:Array = ["as", "mxml", "this"];
			Assert.assertEquals(ArrayUtil.getItemIndex("other", a), -1);

			var o:Object = {name:"this"};
			var b:Array = [
				{name:"this"},
				{name:"other"},
				{name:"as"},
				{position:2}
			];
			Assert.assertEquals(ArrayUtil.getItemIndex(o, b), -1);
		}

		[Test(description="Test removing duplicates with prmitives", order="3")]
		public function removeDuplicatesTest():void
		{
			var a:Array = ["duplicate3", "duplicate3", "duplicate3", "duplicate2", "duplicate1", "duplicate1", "duplicate2", "duplicate1"];

			var b:Array = ArrayUtil.sortAndRemoveDuplicates(a);
			Assert.assertEquals(3, b.length);
			Assert.assertEquals("duplicate1", b[0]);
			Assert.assertEquals("duplicate2", b[1]);
			Assert.assertEquals("duplicate3", b[2]);
		}

		[Test(description="Test removing duplicates with complex objects", order="4")]
		public function removeDuplicatesComplexTest():void
		{
			var a:Array = [
				{name:"duplicate3",order:1},
				{name:"duplicate3",order:1},
				{name:"duplicate3",order:1},
				{name:"duplicate2",order:1},
				{name:"duplicate1",order:1},
				{name:"duplicate1",order:1},
				{name:"duplicate2",order:1},
				{name:"duplicate1",order:1}];

			var b:Array = ArrayUtil.sortAndRemoveDuplicates(a,["name"]);
			Assert.assertEquals(3, b.length);
			Assert.assertEquals("duplicate1", b[0].name);
			Assert.assertEquals("duplicate2", b[1].name);
			Assert.assertEquals("duplicate3", b[2].name);
		}

		[Test(description="Test removing duplicates with complex objects", order="4")]
		public function removeDuplicatesMultipleFieldsTest():void
		{
			var a:Array = [
				{name:"duplicate3",order:1},
				{name:"duplicate3",order:2},
				{name:"duplicate3",order:2},
				{name:"duplicate2",order:1},
				{name:"duplicate1",order:1},
				{name:"duplicate1",order:1},
				{name:"duplicate2",order:1},
				{name:"duplicate1",order:1}];

			var b:Array = ArrayUtil.sortAndRemoveDuplicates(a,["name","order"]);
			Assert.assertEquals(4, b.length);
			Assert.assertEquals("duplicate1", b[0].name);
			Assert.assertEquals("duplicate2", b[1].name);
			Assert.assertEquals("duplicate3", b[2].name);
			Assert.assertEquals(1, b[2].order);
			Assert.assertEquals("duplicate3", b[3].name);
			Assert.assertEquals(2, b[3].order);
		}
	}
}
