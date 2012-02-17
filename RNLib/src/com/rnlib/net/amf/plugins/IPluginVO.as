/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	public interface IPluginVO
	{
		function get callback():Function;

		function get args():Array;

		function set args(value:Array):void;
	}
}
