/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	import flash.events.IEventDispatcher;

	public interface IPlugin extends IEventDispatcher
	{
		/**
		 * Test if Value Object is acceptable by plugin to future process.
		 * @param vo Value Object to test.
		 * @return <code>true</code> if plugin accept Value Object, <code>false</code> otherwise.
		 */
		function acceptable(vo:IPluginVO):Boolean;


		function init(vo:IPluginVO):void;
	}
}
