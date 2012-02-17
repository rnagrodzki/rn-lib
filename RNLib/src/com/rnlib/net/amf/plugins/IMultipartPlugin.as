/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	public interface IMultipartPlugin extends IPlugin
	{
		function next():Boolean;

		function onResult(result:Object):void;

		function onFault(fault:Object):void;
	}
}
