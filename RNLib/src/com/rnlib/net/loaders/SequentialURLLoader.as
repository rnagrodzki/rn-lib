/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.loaders
{
	import com.rnlib.interfaces.IDisposable;
	import com.rnlib.queue.IQueue;
	import com.rnlib.queue.PriorityQueue;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import mx.utils.ObjectUtil;

	[Event(name="complete", type="com.rnlib.net.loaders.SequentialLoaderEvent")]

	public class SequentialURLLoader extends EventDispatcher implements IDisposable
	{
		protected var _queue:IQueue;
		protected var _urlLoader:URLLoader;
		protected var _request:URLRequest;

		public function SequentialURLLoader(urlRequestsArray:Array = null)
		{
			init(urlRequestsArray);
		}

		protected function init(requests:Array):void
		{
			_queue = new PriorityQueue();

			for each (var item:Object in requests)
			{
				addRequest(item);
			}
		}

		/**
		 * Add new url or URLRequest object to queue of requests
		 * @param item
		 */
		protected function addRequest(item:Object):void
		{
			if (item is URLRequest) _queue.push(item);
			else if (item is String)
			{
				var req:URLRequest = new URLRequest(item as String);
				_queue.push(req);
			}
		}

		/**
		 * Start loading requests in queue
		 */
		public function load():void
		{
			if (!_queue || _queue && _queue.length == 0) return;

			if (_urlLoader) return;

			recreateLoader();
			var req:URLRequest = _queue.item as URLRequest;
			_request = req;

			_urlLoader.load(req);
		}

		/**
		 * Dispose loader
		 */
		public function dispose():void
		{
			disposeLoader();

			_queue.dispose();
			_queue = null;
			_request = null;
		}

		//---------------------------------------------------------------
		//              <------ URL LOADER HANDLERS ------>
		//---------------------------------------------------------------

		protected function recreateLoader():void
		{
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, onComplete);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}

		protected function disposeLoader():void
		{
			if (!_urlLoader) return;

			_urlLoader.removeEventListener(Event.COMPLETE, onComplete);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

			_urlLoader.close();
			_urlLoader = null;
		}

		protected function onComplete(ev:Event):void
		{
			dispatchEvent(new SequentialLoaderEvent(
					SequentialLoaderEvent.COMPLETE,
					ObjectUtil.copy(_urlLoader.data),
					ObjectUtil.copy(_request) as URLRequest));

			disposeLoader();

			if (_queue && _queue.length > 0)
				load();
		}

		/**
		 * If set to <code>true</code> if error receive jump to next request in queue
		 * and continue execute other requests. Default value is <code>false</code>.
		 */
		public var proceedAfterError:Boolean = false;

		protected function onError(ev:Event):void
		{
			dispatchEvent(ev);

			disposeLoader();

			if (_queue && _queue.length > 0 && proceedAfterError)
				load();
		}
	}
}
