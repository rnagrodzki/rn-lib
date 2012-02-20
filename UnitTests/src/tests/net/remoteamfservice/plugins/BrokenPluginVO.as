/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.remoteamfservice.plugins
{
	import com.rnlib.net.plugins.INetPluginVO;

	public class BrokenPluginVO implements INetPluginVO
	{
		public function BrokenPluginVO()
		{
		}

		public function get args():Array
		{
			return null;
		}

		public function set args(value:Array):void
		{
		}
	}
}
