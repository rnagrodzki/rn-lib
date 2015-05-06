/***************************************************************************************************
 * Copyright (c) 2015. Rafa� Nagrodzki (e-mail: rafal[at]nagrodzki.net)
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

package tests.net
{
	import org.morefluent.integrations.flexunit4.after;

	import rnlib.net.service.ServiceEvent;

	public class PluginFinishedWithResult extends AbstractPluginTest
	{
		public function PluginFinishedWithResult()
		{
		}

		[Test(order="1", async)]
		public function simpleRequest():void
		{
			after(ServiceEvent.RESULT, 200).on(_service).pass();
			callInSequence(
					[
						{sendData: 1},
						{sendData: 2},
						{sendData: 3, receiveData: "complete"}
					]);
		}
	}
}
