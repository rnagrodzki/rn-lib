/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.utils
{
	import com.rnlib.utils.ArrayUtil;

	import org.flexunit.Assert;

	public class ArrayUtilTest
	{
		[Test(description="Test looking for item when exist in array", order="1", async="false", timeout="0")]
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

		[Test(description="Test looking for item when doesn't exist in array", order="2", async="false", timeout="0")]
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
	}
}
