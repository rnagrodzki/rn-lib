/***************************************************************************************************
 Copyright (c) 2012. Rafał Nagrodzki (rafal.nagrodzki.dev@gmail.com)
 http://rafal-nagrodzki.com/

 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/
package com.rnlib.net.plugins
{
	import flash.events.IEventDispatcher;

	/**
	 * Developer of Plugin is responsible for dispatch
	 * <code>NetPluginEvent.READY</code> after executed by
	 * RemoteAmfService method init(). The event inform
	 * amf service that plugin is ready for return args
	 * which will pass to request on server by args getter.
	 *
	 *
	 * @see com.rnlib.net.plugins.NetPluginEvent
	 */
	public interface INetPlugin extends IEventDispatcher
	{
		/**
		 * Method called by RemoteAmfService o start
		 * plugin lifecycle.
		 * @param vo Param transfer from args remote method.
		 *
		 * @see com.rnlib.net.plugins.NetPluginEvent
		 */
		function init(vo:INetPluginVO):void;

		/**
		 * Method calling by RemoteAmfService on end of life
		 * plugin.
		 *
		 * @see com.rnlib.interfaces.IDisposable
		 */
		function dispose():void;

		/**
		 * Method calling by RemoteAmfService in purpose getting
		 * arguments to pass into request on server.
		 */
		function get args():Array;

		/**
		 * Dispatcher pass to give possibility dispatching events
		 * on RemoteAmfService.
		 */
		function get dispatcher():IEventDispatcher;
		function set dispatcher(value:IEventDispatcher):void;
	}
}
