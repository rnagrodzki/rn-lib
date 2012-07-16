/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.apis.googleTasks
{
	public class GTaskVO
	{
		public var kind:String;
		public var id:String;
		public var etag:String;
		public var title:String;
		public var updated:String;
		public var selfLink:String;
		public var parent:String;
		public var position:String;
		public var notes:String;
		public var status:String;
		public var due:String;
		public var completed:String;

		public var deleted:Boolean;
		public var hidden:Boolean;

		[ArrayElementType("com.rnlib.apis.googleTasks.GTaskLinkVO")]
		public var links:Array;
	}
}
