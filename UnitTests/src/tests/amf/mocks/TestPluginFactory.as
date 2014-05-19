/*
 * Copyright (c) 2012. Rafał Nagrodzki (rafal[dot]nagrodzki[dot]dev[at]gmail[dot]com)
 *  http://rafal-nagrodzki.com/
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package tests.amf.mocks
{
	import mx.core.IFactory;

	import rnlib.net.plugins.INetPlugin;
	import rnlib.net.plugins.INetPluginFactory;
	import rnlib.net.plugins.INetPluginVO;

	public class TestPluginFactory implements INetPluginFactory
	{
		protected var _plugin:IFactory;
		protected var _vo:Class;

		public function TestPluginFactory(plugin:IFactory, vo:Class)
		{
			_plugin = plugin;
			_vo = vo;
		}

		public function newInstance():INetPlugin
		{
			return _plugin.newInstance();
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
