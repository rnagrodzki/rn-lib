/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package rnlib.collections
{
	import rnlib.interfaces.IDisposable;

	public class PriorityStack extends AbstractDataCollection implements IStack, IDataCollection, IDisposable
	{
		public function PriorityStack(source:Array = null, priority:int = 1)
		{
			super(source, priority);
		}

		override public function pushWithPriority(item:*, priority:int = 1):DataCollectionItemVO
		{
			var vo:DataCollectionItemVO = super.pushWithPriority(item, priority);

			var len:uint = _source.length;
			if (!_requireSort)
			{
				_requireSort = (len && _source[0].priority > vo.priority);
			}

			_source.unshift(vo);
			return vo;
		}

		override public function getItem():*
		{
			if (_source.length == 0)
				return undefined;

			sort();
			var vo:DataCollectionItemVO = DataCollectionItemVO(_source.shift());

			return vo.item;
		}

		override public function sort():void
		{
			if (_requireSort)
			{
				_source.sortOn(["priority", 'count'], [Array.DESCENDING | Array.NUMERIC, Array.DESCENDING | Array.NUMERIC]);
				_requireSort = false;
			}
		}


		override public function clone():IDataCollection
		{
			super.clone();
			return new PriorityStack(_source.concat(null));
		}
	}
}
