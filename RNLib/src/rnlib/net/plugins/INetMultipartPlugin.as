/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
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
package rnlib.net.plugins
{
	/**
	 * Developer of MultipartPlugin is responsible to dispatch event
	 * <code>Event.READY</code> always after execute by RemoteAmfService
	 * init() or next() method. Please notice that init() method is calling
	 * only once at start "lifecycle" of plugin. Method next() is calling
	 * as many times as needed to complete work by plugin. After that
	 * plugin dispatch event <code>NetPluginEvent.COMPLETE</code>
	 *
	 * @see rnlib.net.plugins.NetPluginEvent
	 */
	public interface INetMultipartPlugin extends INetPlugin
	{
		/**
		 * Callback to pass result from server
		 * @param result
		 */
		function onResult(result:Object):void;

		/**
		 * Callback to pass fault from server
		 * @param fault
		 */
		function onFault(fault:Object):void;
	}
}
