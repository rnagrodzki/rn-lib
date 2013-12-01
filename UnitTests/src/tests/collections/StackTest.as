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
package tests.collections
{
	import org.flexunit.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;

	import rnlib.collections.PriorityStack;

	public class StackTest
	{
		[Test(description="Basic test collections without priority range", order="1")]
		public function inputSameAsOutput():void
		{
			var source:Array = [1, 2, 3, 4];

			var ps:PriorityStack = new PriorityStack(source);

			Assert.assertEquals(ps.length, 4);

			var result:Array = [];

			while (ps.length > 0)
			{
				result[result.length] = ps.getItem();
			}
			Assert.assertEquals(ps.length, 0);
			ps.dispose();
			Assert.assertEquals(ps.length, 0);
			assertThat(array(4,3,2,1), result);
		}

		[Test(description="Test dispose funcionality", order="2")]
		public function testDispose():void
		{
			var source:Array = [1, 2, 3, 4];

			var ps:PriorityStack = new PriorityStack(source);

			Assert.assertEquals(ps.length, 4);
			ps.dispose();
			Assert.assertEquals(ps.length, 0);
			Assert.assertStrictlyEquals(ps.getItem(), undefined);
		}

		[Test(description="Basic test collections with priority range", order="3")]
		public function testPriority():void
		{
			var ps:PriorityStack = new PriorityStack();
			ps.pushWithPriority("1_2", 2);
			ps.pushWithPriority("2_2", 2);
			ps.pushWithPriority("3_1", 1);
			ps.pushWithPriority("4_1", 1);
			ps.pushWithPriority("5_10", 10);
			ps.pushWithPriority("6_10", 10);
			ps.pushWithPriority("7_10", 10);
			ps.pushWithPriority("8_10", 10);
			ps.pushWithPriority("9_-1", -1);

			Assert.assertEquals("8_10", ps.getItem());
			Assert.assertEquals("7_10", ps.getItem());
			Assert.assertEquals("6_10", ps.getItem());
			Assert.assertEquals("5_10", ps.getItem());
			Assert.assertEquals("2_2", ps.getItem());
			Assert.assertEquals("1_2", ps.getItem());
			Assert.assertEquals("4_1", ps.getItem());
			Assert.assertEquals("3_1", ps.getItem());
			Assert.assertEquals("9_-1", ps.getItem());

			ps.dispose();
		}

		[Test(description="Test dynamic sorting while adding and remowing items from collections", order="4")]
		public function advancedTestDynamicPriority():void
		{
			var ps:PriorityStack = new PriorityStack();
			Assert.assertEquals(ps.length, 0);
			ps.pushWithPriority("first", 2);
			ps.pushWithPriority("toRemove", 6);
			Assert.assertEquals(ps.length, 2);

			Assert.assertEquals(ps.getItem(), "toRemove");
			Assert.assertEquals(ps.length, 1);

			ps.pushWithPriority("third", 1);
			ps.pushWithPriority("beforeAll", 4);
			Assert.assertEquals(ps.length, 3);

			Assert.assertEquals(ps.getItem(), "beforeAll");
			Assert.assertEquals(ps.length, 2);
			Assert.assertEquals(ps.getItem(), "first");
			Assert.assertEquals(ps.length, 1);
			Assert.assertEquals(ps.getItem(), "third");
			Assert.assertEquals(ps.length, 0);

			ps.dispose();
		}
	}
}
