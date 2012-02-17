/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	import flash.events.Event;

	public class PluginEvent extends Event
	{
		public static const READY:String = "pluginReady";

		public static const CANCEL:String = "pluginCancel";

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
