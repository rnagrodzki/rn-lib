/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.plugins
{
	public class NetPluginFactory implements INetPluginFactory
	{
		protected var _generator:Class;
		protected var _generatorVO:Class;

		public function NetPluginFactory(generator:Class, voGenerator:Class)
		{
			_generator = generator;
			_generatorVO = voGenerator;
		}

		public function newInstance():INetPlugin
		{
			return new _generator();
		}

		public function isSupportVO(vo:INetPluginVO):Boolean
		{
			return vo is _generatorVO;
		}

		public function dispose():void
		{
			_generator = null;
			_generatorVO = null;
		}
	}
}
