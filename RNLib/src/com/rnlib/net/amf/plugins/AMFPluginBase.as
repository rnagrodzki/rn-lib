/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	import flash.events.EventDispatcher;

	public class AMFPluginBase extends EventDispatcher implements IPlugin
	{
		public function AMFPluginBase()
		{
		}

		public function acceptable(vo:IPluginVO):Boolean
		{
			return false;
		}

		public function init(vo:IPluginVO):void
		{
		}
	}
}
