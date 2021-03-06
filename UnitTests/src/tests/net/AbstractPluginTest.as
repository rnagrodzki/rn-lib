/***************************************************************************************************
 * Copyright (c) 2014. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
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

/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.net
{
	import mocks.*;

	import mx.core.ClassFactory;

	import rnlib.net.plugins.NetPluginFactory;
	import rnlib.net.service.RemoteService;
	import rnlib.net.service.Request;

	import tests.AbstractTest;

	public class AbstractPluginTest extends AbstractTest
	{
		public const METHOD_NAME:String = "myMethod";

		protected var _service:RemoteService;

		override public function setupClass():void
		{
			super.setupClass();

			var connection:ConnectionMock = new ConnectionMock();
			var factory:NetPluginFactory = new NetPluginFactory(PluginMock, PluginMockVO);
			factory.properties = {connection: connection};

			_service = new RemoteService();
			_service.connection = connection;
			_service.endpoint = "x";
			_service.service = "MyService";
			_service.pluginsFactories = [factory];
		}

		[Before]
		override public function setup():void
		{
			super.setup();
			_service.addMethod(METHOD_NAME);
		}

		[After]
		override public function tearDown():void
		{
//			_service.removeMethod(METHOD_NAME);
			super.tearDown();
		}

		protected function callInSequence(arr:Array):Request
		{
			var sequence:Array = [];
			var factory:ClassFactory = new ClassFactory(PluginMockSequenceVO);

			for each (var props:Object in arr)
			{
				factory.properties = props;
				sequence.push(factory.newInstance());
			}

			var vo:PluginMockVO = new PluginMockVO();
			vo.dataSequence = sequence;
			return _service[METHOD_NAME](vo);
		}
	}
}
