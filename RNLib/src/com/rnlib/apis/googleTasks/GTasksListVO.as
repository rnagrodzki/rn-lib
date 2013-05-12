/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.apis.googleTasks
{
	public class GTasksListVO
	{
		public var id:String;
		public var etag:String;
		public var kind:String;
		public var title:String;

		[ArrayElementType("com.rnlib.apis.googleTasks.GTaskVO")]
		public var items:Array;
	}
}
