/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	import flash.events.Event;

	/**
	 * Life of plugin inside amf service can be control
	 * only by dispatching events.
	 */
	public class PluginEvent extends Event
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
		 *
		 */
		public static const COMPLETE:String = "pluginComplete";

		public var data:Object;

		public function PluginEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}

		override public function clone():Event
		{
			return new PluginEvent(type, data, bubbles, cancelable);
		}
	}
}
