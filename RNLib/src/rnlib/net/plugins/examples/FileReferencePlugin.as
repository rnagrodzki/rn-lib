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
package rnlib.net.plugins.examples
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import rnlib.interfaces.IDisposable;
	import rnlib.net.plugins.*;

	public class FileReferencePlugin extends EventDispatcher implements INetPlugin, IDisposable
	{
		protected var _vo:FileReferencePluginVO;
		protected var _owner:INetPluginOwner;

		public function FileReferencePlugin()
		{
		}

		/**
		 * Method called by amf service before send request to server
		 * @param owner
		 * @param vo ValueObject passed by amf service witch is associated
		 * with current request
		 */
		public function init(owner:INetPluginOwner, vo:INetPluginVO):void
		{
			_vo = vo as FileReferencePluginVO;
			_owner = owner;

			if (!_vo.fileReference.data)
			{
				_vo.fileReference.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
				_vo.fileReference.load();
			}
			else
			{
				_owner.pluginRequest(this, new PluginRequestVO(_vo.fileReference.data));
			}
		}

		private function onComplete(e:Event):void
		{
			_vo.args.unshift(_vo.fileReference.data);
			_owner.pluginRequest(this, new PluginRequestVO(_vo.fileReference.data));
		}

		public function onResult(result:Object):void {_owner.pluginRisesComplete(this, result);}

		public function onFault(fault:Object):void {_owner.pluginRisesFault(this, fault);}

		/**
		 * Disposing plugin
		 */
		public function dispose():void
		{
			_vo = null;
		}
	}
}
