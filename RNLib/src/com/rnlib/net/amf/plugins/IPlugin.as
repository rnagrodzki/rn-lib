/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	import flash.events.IEventDispatcher;

	public interface IPlugin extends IEventDispatcher
	{
		function init(vo:IPluginVO):void;

		function get args():Array;
	}
}
