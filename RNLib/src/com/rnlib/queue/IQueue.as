/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.queue
{
	public interface IQueue
	{
		/**
		 * Dispose queue
		 *
		 * @see com.rnlib.interfaces.IDisposable
		 */
		function dispose():void;

		function push(...rest):void;

		function pushWithPriority(item:*, priority:int = 1):void;

		function get item():*;

		function get length():uint;
	}
}
