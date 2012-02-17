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
				dispatchEvent(new PluginEvent(PluginEvent.READY));
			}
		}

		private function onComplete(e:Event):void
		{
			_vo.args.unshift(_vo.fr.data);
			dispatchEvent(new PluginEvent(PluginEvent.READY));
		}

		public function get args():Array
		{
			return _vo.args;
		}

		public function dispose():void
		{
			_vo = null;
		}
	}
}
