/***************************************************************************************************
 * Copyright (c) 2014. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
 * A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/

/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.amf.callingRemote.multipartPlugin
{
	import org.morefluent.integrations.flexunit4.after;

	import rnlib.net.amf.AMFEvent;
	import rnlib.net.plugins.NetPluginEvent;

	[TestCase(order="2")]
	public class MultipartPlugin_CallRemoteRegisteredMethodThrowingExceptions extends AbstractMultiPluginTest
	{
		[Test(order="1", async)]
		public function onInitRaisesFault():void
		{
			after(AMFEvent.FAULT, 100).on(_service).pass();

			callInSequence([
				{
					event: new NetPluginEvent(NetPluginEvent.READY),
					exceptionBeforeEvent: new Error("Init exception")
				},
				{event: new NetPluginEvent(NetPluginEvent.COMPLETE)}
			]);
		}

		[Test(order="2", async)]
		public function onResultRisesFault():void
		{
			after(AMFEvent.FAULT, 100).on(_service).pass();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{
					event: new NetPluginEvent(NetPluginEvent.COMPLETE),
					exceptionBeforeEvent: new Error("Init exception")
				}
			]);
		}

		[Test(order="3", async)]
		public function onInitOccuredAfterEventRaisesFault():void
		{
			after(AMFEvent.FAULT, 50).on(_service).pass();
			after(AMFEvent.RESULT, 50).on(_service).fail();

			callInSequence([
				{
					event: new NetPluginEvent(NetPluginEvent.READY),
					exceptionAfterEvent: new Error("Init exception")
				},
				{event: new NetPluginEvent(NetPluginEvent.COMPLETE)}
			]);
		}

		[Test(order="4", async)]
		public function onResultOccuredAfterEventRaisesFault():void
		{
			after(AMFEvent.RESULT, 50).on(_service).pass();
			after(AMFEvent.FAULT, 50).on(_service).fail();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{
					event: new NetPluginEvent(NetPluginEvent.COMPLETE),
					exceptionAfterEvent: new Error("Init exception")
				}
			]);
		}

		[Test(order="5", async)]
		public function onResultOccuredMiddleRequestsAfterEventRaisesFault():void
		{
			after(AMFEvent.FAULT, 100).on(_service).pass();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{
					event: new NetPluginEvent(NetPluginEvent.READY),
					exceptionAfterEvent: new Error("Init exception")
				},
				{event: new NetPluginEvent(NetPluginEvent.COMPLETE)}
			]);
		}
	}
}
