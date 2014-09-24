/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
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
package rnlib.collections
{
	import rnlib.interfaces.IDisposable;

	public class PriorityQueue extends AbstractDataCollection implements IQueue, IDataCollection, IDisposable
	{
		/**
		 * Constructor
		 * @param source Array witch will be added to collections
		 * @param priority Priority to all added items from source
		 */
		public function PriorityQueue(source:Array = null, priority:int = 1)
		{
			super(source, priority);
			sortFields = ["priority", "count"];
			sortOptions = [Array.DESCENDING | Array.NUMERIC, Array.NUMERIC];
		}

		override public function pushWithPriority(item:*, priority:int = 1):DataCollectionItemVO
		{
			var vo:DataCollectionItemVO = super.pushWithPriority(item, priority);

			var len:uint = _source.length;
			if (!_requireSort)
				_requireSort = (len && _source[len - 1].priority < priority);

			_source[len] = vo;
			return vo;
		}

		override public function clone():IDataCollection
		{
			super.clone();
			return new PriorityQueue(_source.concat(null));
		}
	}
}
