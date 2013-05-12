/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.apis.googleTasks
{
	import com.rnlib.apis.AbstractApiService;

	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	[Event(name="tasksListLoaded", type="com.rnlib.apis.googleTasks.GTasksListEvent")]
	[Event(name="tasksListLoadError", type="com.rnlib.apis.googleTasks.GTasksListEvent")]

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
