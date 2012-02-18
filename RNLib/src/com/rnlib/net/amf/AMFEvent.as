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

		/**
		 * Service received header from response from server
		 */
		public static const HEADER:String = "header";

		/**
		 * Service received response from server
		 */
		public static const RESULT:String = "result";

		/**
		 * Service received response from server
		 */
		public static const FAULT:String = "fault";

		/**
		 * Unique identifier of remote call
		 */
		public var uid:int = -1;

		/**
		 * Data pass to event
		 */
		public var data:Object;

		public function AMFEvent(type:String, uid:int = -1, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.uid = uid;
			this.data = data;
		}

		override public function clone():Event
		{
			return new AMFEvent(type, uid, data, bubbles, cancelable);
		}
	}
}
