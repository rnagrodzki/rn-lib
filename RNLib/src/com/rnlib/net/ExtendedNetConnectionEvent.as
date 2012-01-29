/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net
{
	import flash.events.Event;

	public class ExtendedNetConnectionEvent extends Event
	{
		public static const RECONNECT : String = "reconnect";
		public static const CONNECTED : String = "connected";
		public static const DISCONNECTED : String = "disconnected";

		public var data:Object;

		public function ExtendedNetConnectionEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}

		override public function clone():Event
		{
			return new ExtendedNetConnectionEvent(type, data, bubbles, cancelable);
		}
	}
}
