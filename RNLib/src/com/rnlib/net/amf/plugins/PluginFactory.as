/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	public class PluginFactory implements IPluginFactory
	{
		protected var _generator:Class;
		protected var _generatorVO:Class;
		
		public function PluginFactory(generator:Class,voGenerator:Class)
		{
			_generator = generator;
		}

		public function newInstance():IPlugin
		{
			return new _generator();
		}

		public function isSupportVO(vo:IPluginVO):Boolean
		{
			return vo is _generatorVO;
		}
	}
}
