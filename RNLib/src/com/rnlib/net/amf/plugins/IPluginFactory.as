/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	public interface IPluginFactory
	{
		function newInstance():IPlugin;

		function isSupportVO(vo:IPluginVO):Boolean;
	}
}
