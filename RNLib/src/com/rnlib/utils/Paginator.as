/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.utils
{
	import flash.events.EventDispatcher;

	import mx.collections.IList;
	import mx.events.CollectionEvent;

	public class Paginator extends EventDispatcher
	{
		public function Paginator()
		{
		}

		//---------------------------------------------------------------
		//              <------ SETTINGS ------>
		//---------------------------------------------------------------

		protected var _itemsPerPage:int = 10;

		public function get itemsPerPage():int
		{
			return _itemsPerPage;
		}

		public function set itemsPerPage(value:int):void
		{
			_itemsPerPage = value;
			compute();
		}

		public function dispose():void
		{
			dataProvider = null;
			_collection = null;
		}

		//---------------------------------------------------------------
		//              <------ NAVIGATION ------>
		//---------------------------------------------------------------

		public function next():void
		{
			currentIndex+=1;
		}

		public function prev():void
		{
			currentIndex-=1;
		}

		public function first():void
		{
			currentIndex = 0;
		}

		public function last():void
		{
			currentIndex = _length - 1;
		}

		protected var _currentIndex:int;

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
			value = value > _dataProvider.length ? _dataProvider.length : value;

			if (value == _currentIndex) return;
			_currentIndex = value;
			_dirtyCollection = true;
		}

		private var _length:int;

		public function get length():int
		{
			return _length;
		}

		private var _dirtyCollection:Boolean = false;
		private var _collection:Array;

		public function get collection():Array
		{
			if (_dirtyCollection)
			{
				_dirtyCollection = false;
				var end:int = (_currentIndex + 1) * _itemsPerPage;
				end = end > _dataProvider.length ? _dataProvider.length : end;
				_collection = _dataProvider.toArray().slice(_currentIndex * _itemsPerPage, end);

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
			if (_dataProvider)
			{
				_dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onExternalChange);
			}

			_dataProvider = value;

			if (_dataProvider)
			{
				_dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, onExternalChange);
				compute();
				_dirtyCollection = true;
			}
		}

		protected function onExternalChange(e:CollectionEvent):void
		{
			compute();
		}

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