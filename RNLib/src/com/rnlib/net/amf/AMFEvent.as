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
