/***************************************************************************************************
 * Copyright (c) 2012 Rafał Nagrodzki (http://nagrodzki.net)
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
package com.rnlib.net.plugins
{
	import com.rnlib.interfaces.IDisposable;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class FileReferencePlugin extends EventDispatcher implements INetPlugin, IDisposable
	{
		protected var _vo:FileReferencePluginVO;

		public function FileReferencePlugin()
		{
		}

		/**
		 * Method called by amf service before send request to server
		 * @param vo ValueObject passed by amf service witch is associated
		 * with current request
		 */
		public function init(vo:INetPluginVO):void
		{
			_vo = vo as FileReferencePluginVO;

			if (!_vo.fr.data)
			{
				_vo.fr.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
				_vo.fr.load();
			}
			else
			{
				dispatchEvent(new NetPluginEvent(NetPluginEvent.COMPLETE));
			}
		}

		private function onComplete(e:Event):void
		{
			_vo.args.unshift(_vo.fr.data);
			dispatchEvent(new NetPluginEvent(NetPluginEvent.COMPLETE));
		}

		/**
		 * Method returns argument passed to remote method
		 */
		public function get args():Array
		{
			return _vo.args;
		}

		/**
		 * Disposing plugin
		 */
		public function dispose():void
		{
			_vo = null;
		}

		protected var _dispatcher:IEventDispatcher;

		public function get dispatcher():IEventDispatcher
		{
			return _dispatcher;
		}

		public function set dispatcher(value:IEventDispatcher):void
		{
			_dispatcher = value;
		}
	}
}
