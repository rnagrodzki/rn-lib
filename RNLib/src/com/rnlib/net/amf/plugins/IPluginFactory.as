/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	import com.rnlib.interfaces.IDisposable;

	public interface IPluginFactory extends IDisposable
	{
		function newInstance():IPlugin;

		function isSupportVO(vo:IPluginVO):Boolean;
	}
}
