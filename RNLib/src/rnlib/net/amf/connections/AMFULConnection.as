/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
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
package rnlib.net.amf.connections
{
	import rnlib.interfaces.IDisposable;
	import rnlib.net.amf.AMFEvent;
	import rnlib.net.amf.processor.AMFHeader;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.ObjectEncoding;
	import flash.utils.Dictionary;

	import mx.core.ClassFactory;

	public class AMFULConnection extends EventDispatcher implements IAMFConnection, IDisposable
	{
		protected var _factory:ClassFactory;

		protected var _headers:Array;

		private var _loaders:Dictionary;

		private var _loadersCount:uint = 0;

		private var _url:String;

		public function AMFULConnection()
		{
			init();
		}

		protected function init():void
		{
			_redispatcher = this;
			_factory = new ClassFactory(AMFURLLoader);
			_loaders = new Dictionary();
		}

		private var _connected:Boolean = false;

		public function connect(uri:String):void
		{
			_url = uri;
			_connected = true;

			if (_redispatcher)
				_redispatcher.dispatchEvent(new AMFEvent(AMFEvent.CONNECTED));
		}

		public function get connected():Boolean
		{
			return _connected;
		}

		public function call(command:String, result:Function = null, fault:Function = null, ...args):void
		{
			var loader:AMFURLLoader = _factory.newInstance();
			loader.id = _loadersCount++;
			_loaders[loader.id] = loader;

			loader.url = _url;
			loader.redispatcher = _redispatcher;
			loader.objectEncoding = objectEncoding;
			if (_amfHeaders) loader.amfHeaders = _amfHeaders.concat();

			loader.addEventListener(Event.COMPLETE, onComplete);

			loader.call.apply(this, [command, result, fault].concat(args));
		}

		private function onComplete(e:Event):void
		{
			var loader:AMFURLLoader = e.target as AMFURLLoader;
			loader.removeEventListener(Event.COMPLETE, onComplete);
			_loaders[loader.id] = null;
			delete _loaders[loader.id];
			loader = null;
		}

		//---------------------------------------------------------------
		//              <------ AMF HEADERS ------>
		//---------------------------------------------------------------

		private var _amfHeaders:Array; // Array of AMFHeader

		/**
		 * Adds an AMF packet-level header which is sent with every request for
		 * the life of this AMFConnection.
		 */
		public function addHeader(name:String, mustUnderstand:Boolean = false, data:* = undefined):void
		{
			if (!_amfHeaders)
				_amfHeaders = [];

			var header:AMFHeader = new AMFHeader(name, mustUnderstand, data);
			_amfHeaders.push(header);
		}

		/**
		 * Removes any AMF headers found with the name given.
		 *
		 * @param name The name of the header(s) to remove.
		 *
		 * @return true if a header existed with the given name.
		 */
		public function removeHeader(name:String):Boolean
		{
			var exists:Boolean = false;

			if (_amfHeaders)
			{
				for (var i:uint = 0; i < _amfHeaders.length; i++)
				{
					var header:AMFHeader = _amfHeaders[i] as AMFHeader;
					if (header.name == name)
					{
						_amfHeaders.splice(i, 1);
						exists = true;
					}
				}
			}

			return exists;
		}

		public function close():void
		{
			for each (var amfl:AMFURLLoader in _loaders)
			{
				amfl.close();
				//todo: notify by fault close connection
			}

			if (_redispatcher)
				_redispatcher.dispatchEvent(new AMFEvent(AMFEvent.DISCONNECTED));
		}

		public function dispose():void
		{
			close();
			_headers = null;
			_loadersCount = 0;
			_loaders = new Dictionary();
		}

		//---------------------------------------------------------------
		//              <------ OBJECT ENCODING ------>
		//---------------------------------------------------------------

		private static var _defaultObjectEncoding:uint = ObjectEncoding.AMF3;

		/**
		 * The default object encoding for all AMFConnection instances. This
		 * controls which version of AMF is used during serialization. The default
		 * is AMF 3.
		 *
		 * @see #objectEncoding
		 * @see flash.net.ObjectEncoding
		 */
		public static function get defaultObjectEncoding():uint
		{
			return _defaultObjectEncoding;
		}

		public static function set defaultObjectEncoding(value:uint):void
		{
			_defaultObjectEncoding = value;
		}

		private var _objectEncoding:uint;
		private var objectEncodingSet:Boolean = false;

		/**
		 * The object encoding for this AMFConnection sets which AMF version to
		 * use during serialization. If set, this version overrides the
		 * defaultObjectEncoding.
		 *
		 * @see #defaultObjectEncoding
		 * @see flash.net.ObjectEncoding
		 */
		public function get objectEncoding():uint
		{
			if (!objectEncodingSet)
				return defaultObjectEncoding;

			return _objectEncoding;
		}

		public function set objectEncoding(value:uint):void
		{
			_objectEncoding = value;
			objectEncodingSet = true;
		}

		//---------------------------------------------------------------
		//              <------ CLIENT ------>
		//---------------------------------------------------------------

		public function get client():Object
		{
			//todo: implement method
			return null;
		}

		public function set client(value:Object):void
		{
			//todo: implement method
		}

		//---------------------------------------------------------------
		//              <------ REDISPATCHER ------>
		//---------------------------------------------------------------

		protected var _redispatcher:IEventDispatcher;

		/**
		 * If set class will dispatch native events of NetConnection.
		 * To prevent dispatching native events of NetConnection set <code>null</code>.
		 *
		 * @default this
		 */
		public function get redispatcher():IEventDispatcher
		{
			return _redispatcher;
		}

		public function set redispatcher(value:IEventDispatcher):void
		{
			if (value != _redispatcher)
			{
				for each (var amfl:AMFURLLoader in _loaders)
				{
					amfl.redispatcher = value;
				}

				_redispatcher = value;
			}
		}

		public function get keepAliveTime():int
		{
			return -1;
		}

		public function set keepAliveTime(value:int):void
		{
			// nothing to do here
		}

		public function get reconnectRepeatCount():uint
		{
			//todo: implement method
			return 0;
		}

		public function set reconnectRepeatCount(value:uint):void
		{
			//todo: implement method
		}
	}
}
