/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.plugins
{
	import com.rnlib.interfaces.IDisposable;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	public class MultipartFilePlugin extends EventDispatcher implements INetMultipartPlugin, IDisposable
	{
		protected var _vo:FileReferencePluginVO;

		public function MultipartFilePlugin()
		{
		}

		public static const CHUNK_SIZE:uint = 100 * 1024; //100KB

		private var _filePos:uint = 0;

		protected function getNextFilePart():void
		{
			var ba:ByteArray = new ByteArray();
			_vo.fr.data.position = _filePos;
			ba.readBytes(_vo.fr.data, _filePos,
						 _filePos + CHUNK_SIZE > _vo.fr.data.length ? _vo.fr.data.length - _filePos : CHUNK_SIZE);
			_vo.args[0] = ba;
			_filePos += CHUNK_SIZE;
		}

		public function next():void
		{
			getNextFilePart();
			dispatchEvent(new NetPluginEvent(NetPluginEvent.READY));
		}

		public function onResult(result:Object):void
		{
			// if file was upload we send plugin complete event
			if (_filePos >= _vo.fr.data.length)
				dispatchEvent(new NetPluginEvent(NetPluginEvent.COMPLETE));
		}

		public function onFault(fault:Object):void
		{
			dispatchEvent(new NetPluginEvent(NetPluginEvent.CANCEL));
		}

		public function init(vo:INetPluginVO):void
		{
			_vo = vo as FileReferencePluginVO;

			if (!_vo.fr.data)
			{
				_vo.fr.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
				_vo.fr.load();
			}
			else
			{
				getNextFilePart();
				dispatchEvent(new NetPluginEvent(NetPluginEvent.READY));
			}
		}

		private function onComplete(e:Event):void
		{
			getNextFilePart();
			dispatchEvent(new NetPluginEvent(NetPluginEvent.READY));
		}

		public function dispose():void
		{
			_vo = null;
		}

		public function get args():Array
		{
			return _vo.args;
		}

		protected var _dispatcher:IEventDispatcher;

		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}

		public function set dispatcher(value:IEventDispatcher):void
		{
			_dispatcher = value;
		}
	}
}
