/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
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
package rnlib.apis.googleTasks
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
