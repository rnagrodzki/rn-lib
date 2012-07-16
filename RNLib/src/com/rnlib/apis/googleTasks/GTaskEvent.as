/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.apis.googleTasks
{
	import flash.events.Event;

	public class GTaskEvent extends Event
	{
		/**
		 * All tasks from list loaded
		 */
		public static const ALL_TASKS_FROM_LIST_LOADED:String = "allTasksFromListLoaded";

		/**
		 * Error loading all tasks from list
		 */
		public static const ALL_TASKS_FROM_LIST_LOAD_ERROR:String = "allTasksFromListLoadError";

		/**
		 * Task loaded successfully
		 */
		public static const TASK_LOADED:String = "taskLoaded";

		/**
		 * Error loading task
		 */
		public static const TASK_LOAD_ERROR:String = "taskLoadError";

		public var data:Object;

		public function GTaskEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}

		override public function clone():Event
		{
			return new GTaskEvent(type, data, bubbles, cancelable);
		}
	}
}
