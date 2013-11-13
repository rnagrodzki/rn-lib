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
package rnlib.net.amf.connections
{
	import rnlib.interfaces.IDisposable;
	import rnlib.net.amf.AMFEvent;
	import rnlib.net.amf.ReflexiveClient;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Timer;

	[Event(name="connected", type="rnlib.net.amf.AMFEvent")]
	[Event(name="disconnected", type="rnlib.net.amf.AMFEvent")]
	[Event(name="reconnect", type="rnlib.net.amf.AMFEvent")]
	[Event(name="header", type="rnlib.net.amf.AMFEvent")]

	/**
	 * Implementation of <code>IAMFConnection</code> based on <code>flash.net.NetConnection</code>.
	 * <p>Gives all advantages and disadvantages of netConnection. Lack of upload and download progress
	 * with problems of recognize lose connection but with real live transmission of data.</p>
	 */
	public class AMFNetConnection extends EventDispatcher implements IAMFConnection, IDisposable
	{
		private var _nc:NetConnection;

		private var _uri:String;

		private var _timer:Timer;

		/**
		 * Constructor
		 * @param nc Optional parameter with instance of NetConnection. If don't passed new instance will be created.
		 */
		public function AMFNetConnection(nc:NetConnection = null)
		{
			init(nc);
		}

		private function init(nc:NetConnection = null):void
		{
			_nc = nc || new NetConnection();
			var client:ReflexiveClient = new ReflexiveClient();
			client.callback = onHeaderCalled;
			_nc.client = client;
			_nc.addEventListener(IOErrorEvent.IO_ERROR, onError);
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			_nc.addEventListener(NetStatusEvent.NET_STATUS, onStatus);

			_timer = new Timer(_keepAliveTime);
			_timer.addEventListener(TimerEvent.TIMER, onTick);

			_redispatcher = this;
		}

		public function dispose():void
		{
			if (_nc)
			{
				_nc.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				_nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
				_nc.removeEventListener(NetStatusEvent.NET_STATUS, onStatus);
				close();
				_nc = null;
			}

			if (_timer)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, onTick);
				_timer = null;
			}
		}

		private function onTick(e:TimerEvent):void
		{
			close();
		}

		//---------------------------------------------------------------
		//              <------ KEEP ALIVE ------>
		//---------------------------------------------------------------

		private var _keepAliveTime:int = 10000;

		/**
		 * Time in milliseconds to keep alive connection
		 */
		public function get keepAliveTime():int
		{
			return _keepAliveTime;
		}

		public function set keepAliveTime(value:int):void
		{
			if (_keepAliveTime != value)
			{
				_timer.delay = value < 20 ? 20 : value;
				_keepAliveTime = value;
			}
		}

		//---------------------------------------------------------------
		//              <------ RECONNECT REPEAT COUNT ------>
		//---------------------------------------------------------------

		private var _reconnectRepeatCount:uint = 1;

		/**
		 * Determine how many times connection will auto reconnect.
		 * For example with value 2, connection try connect two times to the server after failure.
		 * To disable auto reconnect feature set 0.
		 */
		public function get reconnectRepeatCount():uint
		{
			return _reconnectRepeatCount;
		}

		public function set reconnectRepeatCount(value:uint):void
		{
			_reconnectRepeatCount = value;
		}

		//---------------------------------------------------------------
		//              <------ REDISPATCHER ------>
		//---------------------------------------------------------------

		private var _redispatcher:IEventDispatcher;

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
			_redispatcher = value;
		}

		private var _internalReconnectCount:int = 0;

		private function reconnect():void
		{
			if (_internalReconnectCount++ < _reconnectRepeatCount)
			{
				connect(_uri);
				dispatchEvent(
						new AMFEvent(
								AMFEvent.RECONNECT,
								_internalReconnectCount));
			}
			else
				_internalReconnectCount = 0;
		}

		private function onStatus(e:NetStatusEvent):void
		{
			trace(e.info);
			if (e.info == "NetConnection.Call.BadVersion" || e.info == "NetConnection.Call.Failed")
			{
				_connected = false;
				dispatchEvent(
						new AMFEvent(
								AMFEvent.DISCONNECTED));
				reconnect();
			}

			if (_redispatcher) _redispatcher.dispatchEvent(e);
		}

		private function onError(e:Event):void
		{
			_connected = false;
			dispatchEvent(
					new AMFEvent(
							AMFEvent.DISCONNECTED));
			reconnect();
			if (_redispatcher) _redispatcher.dispatchEvent(e);
		}

		/**
		 * Connect with server
		 * @param uri
		 */
		public function connect(uri:String):void
		{
			_uri = uri;
			_nc.connect(uri);
			_timer.start();
			_connected = true;
			dispatchEvent(
					new AMFEvent(
							AMFEvent.CONNECTED));
		}

		/**
		 * Close connection
		 */
		public function close():void
		{
			_timer.reset();
			_nc.close();
			_connected = false;
			dispatchEvent(
					new AMFEvent(
							AMFEvent.DISCONNECTED));
		}

		private var _connected:Boolean = false;

		/**
		 * Is connected to server
		 */
		public function get connected():Boolean
		{
			return _connected;
		}

		/**
		 * Calls a command or method on Flash Media Server or on an application server running Flash Remoting.
		 * Before calling NetConnection.call() you must call NetConnection.connect() to connect to the server.
		 * You must create a server-side function to pass to this method.
		 * You cannot connect to commonly reserved ports. For a complete list of blocked ports,
		 * see "Restricting Networking APIs" in the ActionScript 3.0 Developer's Guide.
		 *
		 * @param command A method specified in the form [objectPath/]method. For example,
		 * the someObject/doSomething command tells the remote server to call the
		 * clientObject.someObject.doSomething() method, with all the optional ... arguments parameters.
		 * If the object path is missing, clientObject.doSomething() is invoked on the remote server.
		 * With Flash Media Server, command is the name of a function defined in an application's server-side script.
		 * You do not need to use an object path before command if the server-side script is placed
		 * at the root level of the application directory.
		 *
		 * @param result An optional function that is used to handle return values from the server.
		 *
		 * @param fault An optional function that is used to handle return values from the server.
		 *
		 * @param rest Optional arguments that can be of any ActionScript type, including a reference
		 * to another ActionScript object. These arguments are passed to the method specified
		 * in the command parameter when the method is executed on the remote application server.
		 */
		public function call(command:String, result:Function = null, fault:Function = null, ...rest):void
		{
			var params:Array = [command, new Responder(result, fault)];
			try
			{
				_nc.call.apply(_nc, params.concat(rest));
				_connected = true;
			} catch (e:Error)
			{
				try
				{
					_nc.connect(_uri);
					_nc.call.apply(_nc, params.concat(rest));
					_connected = true;
				} catch (e:Error)
				{
					_connected = false;
				}
			}
		}

		//---------------------------------------------------------------
		//              <------ OBJECT ENCODING ------>
		//---------------------------------------------------------------

		public function get objectEncoding():uint
		{
			return _nc.objectEncoding;
		}

		public function set objectEncoding(value:uint):void
		{
			_nc.objectEncoding = value;
		}

		//---------------------------------------------------------------
		//              <------ CLIENT ------>
		//---------------------------------------------------------------

		protected var _client:Object;

		public function get client():Object
		{
			return _client;
		}

		public function set client(value:Object):void
		{
			if (_client != value)
			{
				_client = value;
			}
		}

		//---------------------------------------------------------------
		//              <------ HEADERS ------>
		//---------------------------------------------------------------

		protected function onHeaderCalled(name:String, ...args):void
		{
			try
			{
				if (_client && _client.hasOwnProperty(name))
					_client[name].apply(null, args);
			} catch (e:Error)
			{ }

			if (_redispatcher)_redispatcher.dispatchEvent(new AMFEvent(AMFEvent.HEADER));
		}

		public function addHeader(name:String, mustUnderstand:Boolean = false, data:* = undefined):void
		{
			_nc.addHeader(name, mustUnderstand, data);
		}

		public function removeHeader(name:String):Boolean
		{
			_nc.addHeader(name);
			return true;
		}
	}
}
