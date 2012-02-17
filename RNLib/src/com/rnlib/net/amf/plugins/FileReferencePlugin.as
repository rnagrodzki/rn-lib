/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class FileReferencePlugin extends EventDispatcher implements IPlugin
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
		public function init(vo:IPluginVO):void
		{
			_vo = vo as FileReferencePluginVO;

			if (!_vo.fr.data)
			{
				_vo.fr.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
				_vo.fr.load();
			}
			else
			{
				dispatchEvent(new PluginEvent(PluginEvent.COMPLETE));
			}
		}

		private function onComplete(e:Event):void
		{
			_vo.args.unshift(_vo.fr.data);
			dispatchEvent(new PluginEvent(PluginEvent.COMPLETE));
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
	}
}
