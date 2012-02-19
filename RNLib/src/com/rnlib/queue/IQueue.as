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

		/**
		 * Add items into queue with default priority
		 * @param rest
		 */
		function push(...rest):void;

		/**
		 * Add item to queue with specified priority
		 * @param item
		 * @param priority
		 */
		function pushWithPriority(item:*, priority:int = 1):void;

		/**
		 * Get next item in queue
		 */
		function get item():*;

		/**
		 * Get length of queue
		 */
		function get length():uint;

		/**
		 * Clone queue object
		 * @return Cloned queue
		 */
		function clone() : IQueue
	}
}
