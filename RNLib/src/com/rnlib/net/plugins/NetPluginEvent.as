/***************************************************************************************************
 * Copyright (c) 2012 Rafał Nagrodzki (http://nagrodzki.net)
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
package com.rnlib.net.plugins
{
	import flash.events.Event;

	/**
	 * Life of plugin inside amf service can be control
	 * only by dispatching events.
	 */
	public class NetPluginEvent extends Event
	{
		/**
		 * Plugin is ready to return arguments for remote method
		 */
		public static const READY:String = "pluginReady";

		/**
		 * Plugin cancel operation. Fault handler will be execute.
		 */
		public static const CANCEL:String = "pluginCancel";

		/**
		 * MultipartPlugin complete all tasks
		 */
		public static const COMPLETE:String = "pluginComplete";

		/**
		 * Plugin was bring to life.
		 * Data property of event contains instance of new plugin.
		 *
		 * @see #data
		 */
		public static const PLUGIN_CREATED:String = "pluginCreated";

		/**
		 * Plugin was initialize with vo.
		 * Data property of event contains instance of plugin.
		 *
		 * @see #data
		 */
		public static const PLUGIN_INITIALIZED:String = "pluginInitialized";


		/**
		 * Plugin was destroyed
		 * Data property of event contains instance of plugin.
		 *
		 * @see #data
		 */
		public static const PLUGIN_DISPOSED:String = "pluginDisposed";

		/**
		 * Plugin finish his job and will be disposed
		 * Data property of event contains instance of plugin.
		 *
		 * @see #data
		 */
		public static const PREPARE_TO_DISPOSE:String = "prepareToDispose";

		public var data:Object;

		public function NetPluginEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}

		override public function clone():Event
		{
			return new NetPluginEvent(type, data, bubbles, cancelable);
		}
	}
}
