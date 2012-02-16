/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import mx.collections.IList;
	import mx.events.CollectionEvent;

	public class Paginator extends EventDispatcher
	{
		public static const INDEX_CHANGED:String = "indexChanged";

		public function Paginator()
		{
		}

		//---------------------------------------------------------------
		//              <------ SETTINGS ------>
		//---------------------------------------------------------------

		protected var _itemsPerPage:int = 10;

		/**
		 * Items given by page. Correct range is from 1 to 0xFFFFFF.
		 * @default 10
		 */
		public function get itemsPerPage():int
		{
			return _itemsPerPage;
		}

		public function set itemsPerPage(value:int):void
		{
			value = value < 1 ? 1 : value;
			_itemsPerPage = value;
			compute();
		}

		/**
		 * Dispose all resources
		 */
		public function dispose():void
		{
			dataProvider = null;
			_collection = null;
		}

		//---------------------------------------------------------------
		//              <------ NAVIGATION ------>
		//---------------------------------------------------------------

		/**
		 * Get next set of data
		 */
		public function next():void
		{
			currentIndex += 1;
		}

		/**
		 * Get last set of data
		 */
		public function prev():void
		{
			currentIndex -= 1;
		}

		/**
		 * Get first set of data
		 */
		public function first():void
		{
			currentIndex = 0;
		}

		/**
		 * Get last set of data
		 */
		public function last():void
		{
			currentIndex = _length - 1;
		}

		protected var _currentIndex:int;

		[Bindable("indexChanged")]
		/**
		 * Current index set of data
		 */
		public function get currentIndex():int
		{
			return _currentIndex;
		}

		public function set currentIndex(value:int):void
		{
			if (!_dataProvider)
			{
				_currentIndex = value;
				return;
			}

			value = value < 0 ? 0 : value;
			value = value >= _length ? _length - 1 : value;

			if (value == _currentIndex) return;
			_currentIndex = value;
			_dirtyCollection = true;

			dispatchEvent(new Event(INDEX_CHANGED));
		}

		private var _length:int;

		/**
		 * Get available length of pages
		 */
		public function get length():int
		{
			return _length;
		}

		private var _dirtyCollection:Boolean = false;
		private var _collection:Array;

		[Bindable("indexChanged")]
		/**
		 * Get collection of items per page
		 */
		public function get collection():Array
		{
			if (_dirtyCollection)
			{
				_dirtyCollection = false;
				if (_dataProvider)
				{
					var end:int = (_currentIndex + 1) * _itemsPerPage;
					end = end > _dataProvider.length ? _dataProvider.length : end;
					_collection = _dataProvider.toArray().slice(_currentIndex * _itemsPerPage, end);
				}
				else _collection = null;
			}

			return _collection;
		}

		//---------------------------------------------------------------
		//              <------ DATA PROVIDER ------>
		//---------------------------------------------------------------

		protected var _dataProvider:IList;

		public function get dataProvider():IList
		{
			return _dataProvider;
		}

		public function set dataProvider(value:IList):void
		{
			if (value != dataProvider)
			{
				if (_dataProvider)
					_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onExternalChange);
				if (value)
					value.addEventListener(CollectionEvent.COLLECTION_CHANGE, onExternalChange);
				_dataProvider = value;
				compute();

				_dirtyCollection = true;
			}
		}

		protected function onExternalChange(e:CollectionEvent):void
		{
			compute();
		}

		/**
		 * Compute base properties
		 */
		protected function compute():void
		{
			if (!_dataProvider)
			{
				_length = 0;
				_currentIndex = 0;
				return;
			}

			_length = Math.ceil(_dataProvider.length / _itemsPerPage);
			currentIndex = 0;
		}
	}
}
