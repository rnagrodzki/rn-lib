/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.loaders
{
	import flash.events.Event;
	import flash.net.URLRequest;

	public class SequentialLoaderEvent extends Event
	{
		public static const COMPLETE:String = "complete";

		public var data:Object;

		public var request:URLRequest;

		public function SequentialLoaderEvent(type:String, data:Object = null, req:URLRequest=null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
			request = req;
		}

		override public function clone():Event
		{
			return new SequentialLoaderEvent(type, data, request, bubbles, cancelable);
		}
	}
}
