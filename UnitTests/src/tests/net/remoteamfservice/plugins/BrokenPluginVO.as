/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.remoteamfservice.plugins
{
	import com.rnlib.net.amf.plugins.IPluginVO;

	public class BrokenPluginVO implements IPluginVO
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
