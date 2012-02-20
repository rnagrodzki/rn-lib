/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.remoteamfservice.plugins
{
	import com.rnlib.net.plugins.INetPluginVO;

	public class TestPluginVO implements INetPluginVO
	{
		public function TestPluginVO()
		{
		}

		protected var _args:Array;

		public function get args():Array
		{
			return _args;
		}

		public function set args(value:Array):void
		{
			_args = value;
		}
	}
}
