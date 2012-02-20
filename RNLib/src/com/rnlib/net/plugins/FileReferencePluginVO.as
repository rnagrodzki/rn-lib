/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.plugins
{
	import flash.net.FileReference;

	public class FileReferencePluginVO implements INetPluginVO
	{
		public function FileReferencePluginVO()
		{
		}

		public var fr:FileReference;

		private var _args:Array;

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
