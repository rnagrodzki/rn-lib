/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package rnlib.collections
{
	import mx.core.ClassFactory;
	import mx.core.IFactory;

	import rnlib.interfaces.IDisposable;

	public class AbstractDataCollection implements IDataCollection, IDisposable
	{
		public var sortFields:Array;
		public var sortOptions:Array;
		public var dataVOFactory:IFactory;

		[ArrayElementType("rnlib.collections.SortableItemVO")]
		protected var _source:Array = [];

		protected var _requireSort:Boolean = false;

		protected var _count:int = 0;

		public function AbstractDataCollection(source:Array = null, priority:int = 1)
		{
			if (source)
			{
				for each (var item:* in source)
				{
					pushWithPriority(item, priority);
				}
			}
			dataVOFactory = new ClassFactory(SortableItemVO);
		}

		public function dispose():void
		{
			_source = [];
			_count = 0;
		}

		/**
		 * Push items into collections.
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
		 * Push item into collections with priority.
		 * @param item    Item to pushed
		 * @param priority    The priority level of the item in collections. The priority is designated by a signed
		 *         32-bit integer. The higher the number, the higher the priority. All items with priority n are
		 *         returned before item of priority n-1. If two or more items share the same priority,
		 *         they are returned in the order in which they were added. The default priority is 0.
		 */
		public function pushWithPriority(item:*, priority:int = 1):SortableItemVO
		{
			var vo:SortableItemVO;
			if (item is SortableItemVO)
				vo = item;
			else
			{
				vo = dataVOFactory.newInstance();
				vo.item = item;
				vo.priority = priority;
			}

			vo.count = _count++;
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
			for each (var itemVO:SortableItemVO in _source)
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
		 * Sort elements in collections.
		 * <p>Sort method is executed only if is needed.</p>
		 */
		public function sort():void
		{
			if (_requireSort)
			{
				_source.sortOn(sortFields, sortOptions);
				_requireSort = false;
			}
		}

		/**
		 * Return item and remove from collections
		 */
		public function getItem():*
		{
			if (_source.length == 0)
				return undefined;

			sort();
			var vo:SortableItemVO = SortableItemVO(_source.shift());
			return vo.item;
		}

		/**
		 * @inheritDoc
		 */
		public function removeItem(item:*):void
		{
			for (var i:int = 0; i < _source.length; i++)
			{
				var vo:SortableItemVO = _source[i] as SortableItemVO;
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
		 * Return count all items into collections
		 */
		public function get length():uint
		{
			return _source.length;
		}

		public function clone():IDataCollection
		{
			if (_requireSort)
				sort();

			return null;
		}

		public function get source():Array
		{
			if(_requireSort)
				sort();

			return _source;
		}
	}
}
