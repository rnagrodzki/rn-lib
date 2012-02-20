/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.plugins
{
	import com.rnlib.interfaces.IDisposable;

	public interface INetPluginFactory extends IDisposable
	{
		function newInstance():INetPlugin;

		function isSupportVO(vo:INetPluginVO):Boolean;
	}
}
