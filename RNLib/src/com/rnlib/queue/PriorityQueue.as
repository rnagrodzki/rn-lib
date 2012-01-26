/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.queue
{
	public class PriorityQueue implements IQueue
	{
		[ArrayElementType("ItemVO")]
		protected var _source:Array = [];

		protected var _requireSort:Boolean = false;

		/**
		 * Constructor
		 * @param source Array witch will be added to queue
		 * @param priority Priority to all added items from source
		 */
		public function PriorityQueue(source:Array = null, priority:int = 1)
		{
			if (source)
			{
				for each (var item:* in source)
				{
					pushWithPriority(item, priority);
				}
			}
		}

		public function dispose():void
		{
			_source = [];
		}

		/**
		 * Push items into queue.
		 * All items will be pushed with default priority
		 * @param rest	All items
		 */
		public function push(...rest):void
		{
			for each (var item:* in rest)
			{
				pushWithPriority(item);
			}
		}

		/**
		 * Push item into queue with priority
		 * @param item	Item to pushed
		 * @param priority	Priority for item into queue
		 */
		public function pushWithPriority(item:*, priority:int = 1):void
		{
			var vo:ItemVO = new ItemVO();
			vo.item = item;
			vo.priority = priority;

			if (!_requireSort)
			{
				var len:uint = _source.length;
				var sort:Boolean = len > 0;

				_requireSort = (sort && _source[len - 1].priority > priority);
			}

			_source.push(item);
		}

		/**
		 * Return item from queue
		 */
		public function get item():*
		{
			// sort method is called only then when it's needed
			if (_requireSort)
				_source.sortOn("priority", Array.NUMERIC);

			return _source.shift().item;
		}

		/**
		 * Return count all items into queue
		 */
		public function get length():uint
		{
			return _source.length;
		}
	}
}

class ItemVO
{
	public var item:*;
	public var priority:int = 1;
}
