/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
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
		 * Plugin was destroyed
		 * Data property of event contains instance of new plugin.
		 *
		 * @see #data
		 */
		public static const PLUGIN_DISPOSED:String = "pluginDisposed";

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
