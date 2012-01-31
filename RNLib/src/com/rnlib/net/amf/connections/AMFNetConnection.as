/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.connections
{
	import com.rnlib.net.*;
	import com.rnlib.net.amf.AMFEvent;

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

	[Event(name="connected", type="com.rnlib.net.amf.AMFEvent")]
	[Event(name="disconnected", type="com.rnlib.net.amf.AMFEvent")]
	[Event(name="reconnect", type="com.rnlib.net.amf.AMFEvent")]

	public class AMFNetConnection extends EventDispatcher implements IAMFConnection
	{
		private var _nc:NetConnection;

		private var _uri:String;

		private var _reconnectRepeatCount:uint = 1;

		private var _redispatcher:IEventDispatcher;

		private var _internalReconnectCount:int = 0;

		private var _connected:Boolean = false;

		private var _keepAliveTime:int = 10000;

		private var _timer:Timer;

		/**
		 * Constructor
		 * @param nc Optional parameter with instance of NetConnection. If don't passed new instance will be created.
		 */
		public function AMFNetConnection(nc:NetConnection = null)
		{
			_nc = nc || new NetConnection();
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
		 *
		 * @return <code>true</code> if method call without any exceptions.
		 */
		public function call(command:String, result:Function = null, fault:Function = null, ...rest):Boolean
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
					return false;
				}
			}
			return true;
		}
	}
}
