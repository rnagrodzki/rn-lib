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
package tests.queue
{
	import com.rnlib.queue.PriorityQueue;

	import org.flexunit.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;

	public class QueueTest
	{
		[Test(description="Basic test queue without priority range", order="1")]
		public function inputSameAsOutput():void
		{
			var source:Array = [1, 2, 3, 4];

			var pq:PriorityQueue = new PriorityQueue(source);

			Assert.assertEquals(pq.length, 4);

			var result:Array = [];

			while (pq.length > 0)
			{
				result[result.length] = pq.item;
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
			Assert.assertStrictlyEquals(pq.item,undefined);
		}

		[Test(description="Basic test queue with priority range", order="3")]
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

			var result:Array = [];
			while (pq.length > 0)
			{
				result[result.length] = pq.item;
			}
			pq.dispose();
			assertThat(array("7_-1", "3_1", "4_1", "1_2", "2_2", "5_10", "6_10"), result);
		}

		[Test(description="Test dynamic sorting while adding and remowing items from queue", order="4")]
		public function advancedTestDynamicPriority():void
		{
			var pq:PriorityQueue = new PriorityQueue();
			Assert.assertEquals(pq.length, 0);
			pq.pushWithPriority("first", 2);
			pq.pushWithPriority("second", -2);
			Assert.assertEquals(pq.length, 2);

			Assert.assertEquals(pq.item, "second");
			Assert.assertEquals(pq.length, 1);

			pq.pushWithPriority("third", 3);
			pq.pushWithPriority("beforAll", 0);
			Assert.assertEquals(pq.length, 3);

			Assert.assertEquals(pq.item, "beforAll");
			Assert.assertEquals(pq.length, 2);
			Assert.assertEquals(pq.item, "first");
			Assert.assertEquals(pq.length, 1);
			Assert.assertEquals(pq.item, "third");
			Assert.assertEquals(pq.length, 0);
		}
	}
}
