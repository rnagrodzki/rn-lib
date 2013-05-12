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
