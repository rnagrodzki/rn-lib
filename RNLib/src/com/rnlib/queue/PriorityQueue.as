/***************************************************************************************************
 Copyright (c) 2012. Rafał Nagrodzki (rafal[dot]nagrodzki[dot]dev[at]gmail[dot]com)
 http://rafal-nagrodzki.com/

 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/
package com.rnlib.queue
{
	import com.rnlib.interfaces.IDisposable;

	public class PriorityQueue implements IQueue, IDisposable
	{
		[ArrayElementType("ItemVO")]
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
		 * @param rest	All items
		 */
		public function push(...rest):void
		{
			for each (var item:* in rest)
			{
//				trace("push into queue");
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
			vo.count = _count++;
			var len:uint = _source.length;

			if (!_requireSort)
			{
				var sort:Boolean = len > 0;

				_requireSort = (sort && _source[len - 1].priority > priority);
			}

			_source[len] = vo;
		}

		/**
		 * Return item from queue
		 */
		public function get item():*
		{
			if (_source.length == 0)
				return undefined;

			// sort method is called only then when it's needed
			if (_requireSort)
			{
				_source.sortOn(["priority", "count"]);
				_requireSort = false;
			}

			var vo:ItemVO = ItemVO(_source.shift());

			return vo.item;
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
	}
}

class ItemVO
{
	public var item:*;
	public var priority:int = 1;
	public var count:int = 0;
}
