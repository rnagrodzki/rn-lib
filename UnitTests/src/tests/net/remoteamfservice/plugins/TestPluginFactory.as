/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.remoteamfservice.plugins
{
	import com.rnlib.net.plugins.INetPlugin;
	import com.rnlib.net.plugins.INetPluginFactory;
	import com.rnlib.net.plugins.INetPluginVO;

	public class TestPluginFactory implements INetPluginFactory
	{
		protected var _plugin:INetPlugin;
		protected var _vo:Class;

		public function TestPluginFactory(plugin:INetPlugin, vo:Class)
		{
			_plugin = plugin;
			_vo = vo;
		}

		public function newInstance():INetPlugin
		{
			return _plugin;
		}

		public function isSupportVO(vo:INetPluginVO):Boolean
		{
			return vo is _vo;
		}

		public function dispose():void
		{
			_plugin = null;
			_vo = null;
		}
	}
}
