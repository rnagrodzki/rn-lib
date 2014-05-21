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
package tests.amf.callingRemote.multipartPlugin.mocks
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import rnlib.net.plugins.INetMultipartPlugin;
	import rnlib.net.plugins.INetPluginVO;

	import tests.amf.mocks.ConnectionMock;

	public class MultipartPluginMock extends EventDispatcher implements INetMultipartPlugin
	{
		[ArrayElementType("tests.amf.callingRemote.multipartPlugin.mocks.MultipartPluginMockSequenceVO")]
		public var eventsSequence:Array;
		public var connection:ConnectionMock;

		public function MultipartPluginMock(connection:ConnectionMock = null)
		{
			this.connection = connection;
		}


		public function nextFromSequence(result:Boolean):void
		{
			var vo:MultipartPluginMockSequenceVO = eventsSequence.shift();
			if (vo.data)
			{
				if (vo.event)
					vo.event.data = vo.data;
				if (vo.faultEvent)
					vo.faultEvent.data = vo.data;
			}

			if (vo.exceptionBeforeEvent)
				throw vo.exceptionBeforeEvent;

			if (connection && vo.responseStatus != -1)
				connection.forceResponseStatus = vo.responseStatus;

			dispatchEvent(result ? vo.event : vo.faultEvent);

			if (vo.exceptionAfterEvent)
				throw vo.exceptionAfterEvent;
		}

		public function onResult(result:Object):void
		{
			nextFromSequence(true);
		}

		public function onFault(fault:Object):void
		{
			nextFromSequence(false);
		}

		public function init(vo:INetPluginVO):void
		{
			if (vo is MultipartPluginMockVO)
				eventsSequence = MultipartPluginMockVO(vo).eventsSequence;

			nextFromSequence(true);
		}

		public function dispose():void
		{
		}

		public function get args():Array
		{
			return null;
		}

		public function get dispatcher():IEventDispatcher
		{
			return null;
		}

		public function set dispatcher(value:IEventDispatcher):void
		{
		}
	}
}
