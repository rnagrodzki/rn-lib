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

	import rnlib.collections.PriorityQueue;

	public class QueueTest
	{
		[Test(description="Basic test collections without priority range", order="1")]
		public function inputSameAsOutput():void
		{
			var source:Array = [1, 2, 3, 4];

			var pq:PriorityQueue = new PriorityQueue(source);

			Assert.assertEquals(pq.length, 4);

			var result:Array = [];

			while (pq.length > 0)
			{
				result[result.length] = pq.getItem();
			}
			Assert.assertEquals(pq.length, 0);
			pq.dispose();
			Assert.assertEquals(pq.length, 0);
			assertThat(source, result);
		}

		[Test(description="Test dispose funcionality", order="2")]
		public function testDispose():void
		{
			var source:Array = [1, 2, 3, 4];

			var pq:PriorityQueue = new PriorityQueue(source);

			Assert.assertEquals(pq.length, 4);
			pq.dispose();
			Assert.assertEquals(pq.length, 0);
			Assert.assertStrictlyEquals(pq.getItem(), undefined);
		}

		[Test(description="Basic test collections with priority range", order="3")]
		public function testPriority():void
		{
			var pq:PriorityQueue = new PriorityQueue();
			pq.pushWithPriority("1_2", 2);
			pq.pushWithPriority("2_2", 2);
			pq.pushWithPriority("3_1", 1);
			pq.pushWithPriority("4_1", 1);
			pq.pushWithPriority("5_10", 10);
			pq.pushWithPriority("6_10", 10);
			pq.pushWithPriority("7_-1", -1);

			Assert.assertEquals("5_10", pq.getItem());
			Assert.assertEquals("6_10", pq.getItem());
			Assert.assertEquals("1_2", pq.getItem());
			Assert.assertEquals("2_2", pq.getItem());
			Assert.assertEquals("3_1", pq.getItem());
			Assert.assertEquals("4_1", pq.getItem());
			Assert.assertEquals("7_-1", pq.getItem());

			pq.dispose();
		}

		[Test(description="Test dynamic sorting while adding and remowing items from collections", order="4")]
		public function advancedTestDynamicPriority():void
		{
			var pq:PriorityQueue = new PriorityQueue();
			Assert.assertEquals(pq.length, 0);
			pq.pushWithPriority("first", 2);
			pq.pushWithPriority("toRemove", 6);
			Assert.assertEquals(pq.length, 2);

			Assert.assertEquals(pq.getItem(), "toRemove");
			Assert.assertEquals(pq.length, 1);

			pq.pushWithPriority("third", 1);
			pq.pushWithPriority("beforeAll", 4);
			Assert.assertEquals(pq.length, 3);

			Assert.assertEquals(pq.getItem(), "beforeAll");
			Assert.assertEquals(pq.length, 2);
			Assert.assertEquals(pq.getItem(), "first");
			Assert.assertEquals(pq.length, 1);
			Assert.assertEquals(pq.getItem(), "third");
			Assert.assertEquals(pq.length, 0);
		}
	}
}
