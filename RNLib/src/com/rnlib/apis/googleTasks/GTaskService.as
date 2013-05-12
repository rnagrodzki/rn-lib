/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.apis.googleTasks
{
	import com.rnlib.apis.AbstractApiService;
	import com.rnlib.utils.ED;

	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	[Event(name="allTasksFromListLoaded", type="com.rnlib.apis.googleTasks.GTaskEvent")]
	[Event(name="allTasksFromListLoadError", type="com.rnlib.apis.googleTasks.GTaskEvent")]
	[Event(name="taskLoaded", type="com.rnlib.apis.googleTasks.GTaskEvent")]
	[Event(name="taskLoadError", type="com.rnlib.apis.googleTasks.GTaskEvent")]

	public class GTaskService extends AbstractApiService
	{
		protected const BASE_URI:String = "https://www.googleapis.com/tasks/v1/lists/";

		//---------------------------------------------------------------
		//              <------ LOAD TASKS LIST ------>
		//---------------------------------------------------------------

		protected var _tasksListId:String;

		/**
		 * List all tasks connected with specified list
		 * @param listId If not specified <code>@default</code> is pass
		 *
		 * @url https://developers.google.com/google-apps/tasks/v1/reference/
		 */
		public function load(listId:String = null):void
		{
			_tasksListId = listId || "@default";

			var req:URLRequest = new URLRequest(BASE_URI + _tasksListId + "/tasks");
			req.method = URLRequestMethod.GET;
			loadData(req, onLoad, onErrorList);
		}

		protected function onLoad(ev:Event):void
		{
			unregisterLoader(ev);
			var result:Object = eventJsonDecode(ev);
			_currentList = writeIntoTasksVO(result);

			ED.sync(new GTaskEvent(GTaskEvent.ALL_TASKS_FROM_LIST_LOADED, _currentList), this);
		}

		protected var _currentList:GTasksListVO;
		public function get currentList():GTasksListVO
		{
			return _currentList;
		}

		protected function onErrorList(ev:Event):void
		{
			unregisterLoader(ev);
			ED.sync(new GTaskEvent(GTaskEvent.ALL_TASKS_FROM_LIST_LOAD_ERROR), this);
		}

		//---------------------------------------------------------------
		//              <------ LOAD TASK ------>
		//---------------------------------------------------------------

		public function loadTask(taskId:String):void
		{
			var req:URLRequest = new URLRequest(BASE_URI + _tasksListId + "/tasks/" + taskId);
			req.method = URLRequestMethod.GET;
			loadData(req, onLoadTask, onErrorTask);
		}

		protected function onLoadTask(ev:Event):void
		{
			unregisterLoader(ev);
			var result:Object = eventJsonDecode(ev);
			_currentTask = writeIntoTaskVO(result);

			ED.sync(new GTaskEvent(GTaskEvent.TASK_LOADED, _currentTask), this);
		}

		protected var _currentTask:GTaskVO;
		public function get currentTask():GTaskVO
		{
			return _currentTask;
		}

		protected function onErrorTask(ev:Event):void
		{
			unregisterLoader(ev);
			ED.sync(new GTaskEvent(GTaskEvent.TASK_LOAD_ERROR), this);
		}

		//---------------------------------------------------------------
		//              <------ HELPER FUNCTIONS ------>
		//---------------------------------------------------------------

		protected function writeIntoTasksVO(response:Object):GTasksListVO
		{
			var vo:GTasksListVO = GTasksListService.writeIntoTasksVO(response);
			vo.items = [];

			for each (var item:Object in response.items)
			{
				vo.items[vo.items.length] = writeIntoTaskVO(item);
			}

			return vo;
		}

		protected function writeIntoTaskVO(item:Object):GTaskVO
		{
			var vo:GTaskVO = new GTaskVO();
			for (var prop:String in item)
			{
				if (prop == "links")
				{
					var link:GTaskLinkVO;
					vo.links = [];
					for each (var l:Object in item[prop])
					{
						link = new GTaskLinkVO();
						link.type = l.type;
						link.description = l.description;
						link.link = l.link;
						vo.links[vo.links.length] = link;
					}
					continue;
				}

				vo[prop] = item[prop];
			}
			return vo;
		}
	}
}
