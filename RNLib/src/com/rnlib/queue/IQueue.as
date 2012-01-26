/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.queue
{
	public interface IQueue
	{
		function dispose():void;

		function push(...rest):void;

		function pushWithPriority(item:*, priority:int = 1):void;

		function get item():*;

		function get length():uint;
	}
}
