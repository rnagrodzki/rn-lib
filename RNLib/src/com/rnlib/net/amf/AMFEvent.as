/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf
{
	import flash.events.Event;

	public class AMFEvent extends Event
	{
		public static const RECONNECT:String = "reconnect";
		public static const CONNECTED:String = "connected";
		public static const DISCONNECTED:String = "disconnected";
		public static const PARSE_ERROR:String = "parseError";

		public static const HEADER:String = "header";

		public static const RESULT:String = "result";
		public static const FAULT:String = "fault";

		public var data:Object;

		public function AMFEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}

		override public function clone():Event
		{
			return new AMFEvent(type, data, bubbles, cancelable);
		}
	}
}
