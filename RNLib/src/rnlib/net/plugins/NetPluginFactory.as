/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
 * A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/
package rnlib.net.plugins
{
	public class NetPluginFactory implements INetPluginFactory
	{
		/**
		 *  An Object whose name/value pairs specify the properties to be set
		 *  on each object generated by the <code>newInstance()</code> method.
		 *
		 *  <p>For example, if you set <code>properties</code> to
		 *  <code>{ text: "Hello", width: 100 }</code>, then every instance
		 *  of the <code>generator</code> class that is generated by calling
		 *  <code>newInstance()</code> will have its <code>text</code> set to
		 *  <code>"Hello"</code> and its <code>width</code> set to
		 *  <code>100</code>.</p>
		 */
		public var properties:Object = null;

		protected var _generator:Class;
		protected var _generatorVO:Class;

		public function NetPluginFactory(generator:Class, voGenerator:Class = null)
		{
			_generator = generator;
			_generatorVO = voGenerator;
		}

		public function newInstance():INetPlugin
		{
			var instance:INetPlugin = new _generator();

			if (properties != null)
			{
				for (var p:String in properties)
					instance[p] = properties[p];
			}

			return instance;
		}

		public function isSupportVO(vo:INetPluginVO):Boolean
		{
			if (!_generatorVO) return true;

			return vo is _generatorVO;
		}

		public function dispose():void
		{
			_generator = null;
			_generatorVO = null;
		}
	}
}
