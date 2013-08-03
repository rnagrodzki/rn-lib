/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
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
	import rnlib.apis.AbstractApiService;

	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	[Event(name="tasksListLoaded", type="rnlib.apis.googleTasks.GTasksListEvent")]
	[Event(name="tasksListLoadError", type="rnlib.apis.googleTasks.GTasksListEvent")]

	public class GTasksListService extends AbstractApiService
	{
		protected const BASE_URI:String = "https://www.googleapis.com/tasks/v1";

		protected const LIST_ALL_TASKS:String = "/users/@me/lists";

		public function load():void
		{
			var req:URLRequest = new URLRequest(BASE_URI + LIST_ALL_TASKS);
			req.method = URLRequestMethod.GET;
			loadData(req, onLoad);
		}

		protected function onLoad(ev:Event):void
		{
			unregisterLoader(ev);

			var result:Object = eventJsonDecode(ev);
			var vo:GTasksListVO = new GTasksListVO();

			dispatchEvent(new GTasksListEvent(GTasksListEvent.TASKS_LISTS_LOADED));
		}

		public static function writeIntoTasksVO(response:Object):GTasksListVO
		{
			var vo:GTasksListVO = new GTasksListVO();
			vo.kind = response.kind;
			vo.etag = response.etag;
			vo.id = response.id;
			vo.title = response.title;

			return vo;
		}
	}
}
