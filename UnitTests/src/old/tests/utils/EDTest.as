/**
 * @author Rafał Nagrodzki (http://nagrodzki.net)
 */
package old.tests.utils
{
	import rnlib.utils.ED;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import flexunit.framework.Assert;

	import org.flexunit.async.Async;

	public class EDTest extends Sprite
	{
		public var disp:EventDispatcher;
		public var frameID:int;

		[Before]
		public function doBefore():void
		{
			disp = new EventDispatcher();
			frameID = 0;
		}

		[After]
		public function doAfter():void
		{
			disp = null;
			stopFramesCounting();
		}

		//-------------------------------
		//	HELPERS
		//-------------------------------

		protected function startFramesCounting():void
		{
			frameID = 0;
			addEventListener(Event.ENTER_FRAME, onCountFrames, false, int.MAX_VALUE);
		}

		protected function stopFramesCounting():void
		{
			removeEventListener(Event.ENTER_FRAME, onCountFrames);
			frameID = 0;
		}

		private function onCountFrames(ev:Event):void
		{
			frameID++;
		}

		//-------------------------------
		//  TEST SYNC
		//-------------------------------

		[Test(description="Test sync dispatching events", timeout="200", order="1", async)]
		public function testSync():void
		{
			disp.addEventListener(Event.COMPLETE, Async.asyncHandler(this, onCompleteSync, 100));
			startFramesCounting();
			ED.sync(new Event(Event.COMPLETE), disp);
		}

		protected function onCompleteSync(ev:Event, passThroughData:Object):void
		{
			Assert.assertEquals(frameID, 0);
		}

		//-------------------------------
		//  TEST ASYNC
		//-------------------------------

		[Test(description="Test async", order="2", async)]
		public function testAsync():void
		{
			disp.addEventListener(Event.COMPLETE, Async.asyncHandler(this, onCompleteAsync, 100));
			startFramesCounting();
			ED.async(new Event(Event.COMPLETE), disp);
		}

		protected function onCompleteAsync(ev:Event, passThroughData:Object):void
		{
			Assert.assertEquals(frameID, 1);
			disp.removeEventListener(Event.COMPLETE, onCompleteAsync);
		}

		//-------------------------------
		//  TEST MULTI ASYNC
		//-------------------------------

		[Test(description="Test async", order="3", async)]
		public function testMultiAsync():void
		{
			disp.addEventListener("three", Async.asyncHandler(this, onCompleteAsyncThree, 3000));
			disp.addEventListener("one", onCompleteAsyncOne);
			disp.addEventListener("two", onCompleteAsyncTwo);
			startFramesCounting();
			ED.async(new Event("one"), disp);
		}

		protected function onCompleteAsyncOne(ev:Event):void
		{
			Assert.assertEquals(1, frameID);
			disp.removeEventListener("one", onCompleteAsyncOne);
			ED.async(new Event("two"), disp);
		}

		protected function onCompleteAsyncTwo(ev:Event):void
		{
			Assert.assertEquals(2, frameID);
			disp.removeEventListener("two", onCompleteAsyncOne);
			ED.async(new Event("three"), disp);
		}

		protected function onCompleteAsyncThree(ev:Event, passThroughData:Object):void
		{
			Assert.assertEquals(3, frameID);
			disp.removeEventListener("three", onCompleteAsyncTwo);
		}
	}
}
