/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
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

		[Test(description="", order="4")]
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
