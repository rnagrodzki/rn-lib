/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.remoteamfservice.plugins
{
	import com.rnlib.net.amf.plugins.IPlugin;
	import com.rnlib.net.amf.plugins.IPluginFactory;
	import com.rnlib.net.amf.plugins.IPluginVO;

	public class TestPluginFactory implements IPluginFactory
	{
		protected var _plugin:IPlugin;
		protected var _vo:Class;

		public function TestPluginFactory(plugin:IPlugin, vo:Class)
		{
			_plugin = plugin;
			_vo = vo;
		}

		public function newInstance():IPlugin
		{
			return _plugin;
		}

		public function isSupportVO(vo:IPluginVO):Boolean
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
