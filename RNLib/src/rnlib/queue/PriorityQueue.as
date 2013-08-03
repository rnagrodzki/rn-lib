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
package rnlib.queue
{
	import rnlib.interfaces.IDisposable;

	public class PriorityQueue implements IQueue, IDisposable
	{
		[ArrayElementType("rnlib.queue.QueueItemVO")]
		protected var _source:Array = [];

		protected var _requireSort:Boolean = false;

		protected var _count:int = 0;

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
			_count = 0;
		}

		/**
		 * Push items into queue.
		 * All items will be pushed with default priority
		 * @param rest    All items
		 */
		public function push(...rest):void
		{
			for each (var item:* in rest)
			{
				pushWithPriority(item);
			}
		}

		/**
		 * Push item into queue with priority.
		 * @param item    Item to pushed
		 * @param priority    The priority level of the item in queue. The priority is designated by a signed
		 *         32-bit integer. The higher the number, the higher the priority. All items with priority n are
		 *         returned before item of priority n-1. If two or more items share the same priority,
		 *         they are returned in the order in which they were added. The default priority is 0.
		 */
		public function pushWithPriority(item:*, priority:int = 1):QueueItemVO
		{
			var vo:QueueItemVO;
			if (item is QueueItemVO)
				vo = item;
			else
			{
				vo = new QueueItemVO();
				vo.item = item;
				vo.priority = priority;
			}

			vo.count = _count++;
			var len:uint = _source.length;
			if (!_requireSort)
			{
				_requireSort = (len && _source[len - 1].priority < priority);
			}

			_source[len] = vo;
			return vo;
		}

		/**
		 * Update item priority
		 * @param item Searched item
		 * @param priority New priority for item
		 * @return <code>true</code> if item found and priority was updated, otherwise return <code>false</code>
		 */
		public function updateItemPriority(item:*, priority:int):Boolean
		{
			for each (var itemVO:QueueItemVO in _source)
			{
				if (itemVO.item === item)
				{
					if (itemVO.priority == priority) return false;

					itemVO.priority = priority;
					_requireSort = true;
					return true;
				}
			}
			return false;
		}

		/**
		 * Sort elements in queue.
		 * <p>Sort method is executed only if is needed.</p>
		 */
		public function sort():void
		{
			if (_requireSort)
			{
				_source.sortOn(["priority", 'count'], [Array.DESCENDING | Array.NUMERIC, Array.NUMERIC]);
				_requireSort = false;
			}
		}

		/**
		 * Return item and remove from queue
		 */
		public function getItem():*
		{
			if (_source.length == 0)
				return undefined;

			sort();
			var vo:QueueItemVO = QueueItemVO(_source.shift());

			return vo.item;
		}

		/**
		 * @inheritDoc
		 */
		public function removeItem(item:*):void
		{
			for (var i:int = 0; i < _source.length; i++)
			{
				var vo:QueueItemVO = _source[i] as QueueItemVO;
				if (vo.item == item)
				{
					_source.splice(i, 1);
					_requireSort = true;
					sort();
					return;
				}
			}
		}

		/**
		 * Return count all items into queue
		 */
		public function get length():uint
		{
			return _source.length;
		}

		public function clone():IQueue
		{
			if (_requireSort)
			{
				_source.sortOn(["priority", "count"]);
				_requireSort = false;
			}

			return new PriorityQueue(_source.concat(null));
		}

		public function get source():Array
		{
			return _source;
		}
	}
}
