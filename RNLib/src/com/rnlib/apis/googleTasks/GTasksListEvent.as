/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.apis.googleTasks
{
	import flash.events.Event;

	public class GTasksListEvent extends Event
	{
		public static const TASKS_LISTS_LOADED:String = "tasksListLoaded";
		public static const TASKS_LISTS_LOAD_ERROR:String = "tasksListLoadError";

		public var data:Object;

		public function GTasksListEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}

		override public function clone():Event
		{
			return new GTasksListEvent(type, data, bubbles, cancelable);
		}
	}
}
