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
	public interface INetPlugin
	{
		/**
		 * Method called by RemoteAmfService o start
		 * plugin lifecycle.
		 * @param owner
		 * @param vo Param transfer from args remote method.
		 *
		 * @see rnlib.net.plugins.NetPluginEvent
		 */
		function init(owner:INetPluginOwner, vo:INetPluginVO):void;

		/**
		 * Method calling by RemoteAmfService on end of life
		 * plugin.
		 *
		 * @see rnlib.interfaces.IDisposable
		 */
		function dispose():void;

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
