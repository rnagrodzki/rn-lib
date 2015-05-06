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
package mocks
{
	import rnlib.net.plugins.INetPlugin;
	import rnlib.net.plugins.INetPluginOwner;
	import rnlib.net.plugins.INetPluginVO;
	import rnlib.net.plugins.PluginRequestVO;

	public class PluginMock implements INetPlugin
	{
		[ArrayElementType("mocks.PluginMockSequenceVO")]
		public var dataSequence:Array;
		public var connection:ConnectionMock;

		protected var _owner:INetPluginOwner;

		public function PluginMock(connection:ConnectionMock = null)
		{
			this.connection = connection;
		}

		public function onResult(result:Object):void
		{
			if (dataSequence.length)
				nextFromSequence();
			else
				_owner.pluginRisesComplete(this, result);
		}

		public function onFault(fault:Object):void
		{
			_owner.pluginRisesFault(this, fault);
		}

		public function init(owner:INetPluginOwner, vo:INetPluginVO):void
		{
			_owner = owner;
			if (vo is PluginMockVO)
				dataSequence = PluginMockVO(vo).dataSequence;

			nextFromSequence();
		}

		public function dispose():void
		{
		}

		private function nextFromSequence():void
		{
			var vo:PluginMockSequenceVO = dataSequence.shift();

			if (vo.exceptionBeforeRequest)
				throw vo.exceptionBeforeRequest;

			if (connection)
			{
				if (vo.responseStatus != -1)
					connection.forceResponseStatus = vo.responseStatus;

				connection.dataToPass = vo.receiveData;
			}

			_owner.pluginRequest(this, new PluginRequestVO(vo.sendData));

			if (vo.exceptionAfterRequest)
				throw vo.exceptionAfterRequest;
		}
	}
}
