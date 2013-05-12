/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.oauth
{
	import flash.events.Event;

	public class OAuth2Event extends Event
	{
		public static const AUTH_SUCCESS:String = "authSuccess";
		public static const AUTH_ERROR:String = "authError";
		public static const GET_ACCESS_TOKEN_SUCCESS:String = "getAccessTokenSuccess";
		public static const GET_ACCESS_TOKEN_ERROR:String = "getAccessTokenError";

		public var data:Object;

		public function OAuth2Event(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}

		override public function clone():Event
		{
			return new OAuth2Event(type, data, bubbles, cancelable);
		}
	}
}
