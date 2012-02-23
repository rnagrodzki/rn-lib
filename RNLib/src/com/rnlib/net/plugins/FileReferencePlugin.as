/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.plugins
{
	import com.rnlib.interfaces.IDisposable;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class FileReferencePlugin extends EventDispatcher implements INetPlugin, IDisposable
	{
		protected var _vo:FileReferencePluginVO;

		public function FileReferencePlugin()
		{
		}

		/**
		 * Method called by amf service before send request to server
		 * @param vo ValueObject passed by amf service witch is associated
		 * with current request
		 */
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
				dispatchEvent(new NetPluginEvent(NetPluginEvent.COMPLETE));
			}
		}

		private function onComplete(e:Event):void
		{
			_vo.args.unshift(_vo.fr.data);
			dispatchEvent(new NetPluginEvent(NetPluginEvent.COMPLETE));
		}

		/**
		 * Method returns argument passed to remote method
		 */
		public function get args():Array
		{
			return _vo.args;
		}

		/**
		 * Disposing plugin
		 */
		public function dispose():void
		{
			_vo = null;
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