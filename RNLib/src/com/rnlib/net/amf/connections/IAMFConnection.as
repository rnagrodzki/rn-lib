/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.connections
{
	import flash.events.IEventDispatcher;

	public interface IAMFConnection extends IEventDispatcher
	{
		function connect(uri:String):void;

		function call(command:String, result:String = null, fault:String = null, ...args):void;

		function close():void;

		function dispose():void;

		function get objectEncoding():uint;

		function set objectEncoding(value:uint):void;

		function get client():Object;

		function set client(value:Object):void;

		function get connected():Boolean;

		function addHeader(name:String, mustUnderstand:Boolean = false, data:* = undefined):void;

		function removeHeader(name:String):Boolean;

		function get redispatcher():IEventDispatcher;

		function set redispatcher(value:IEventDispatcher):void;

		function get keepAliveTime():int;

		function set keepAliveTime(value:int):void;

		function get reconnectRepeatCount():uint;

		function set reconnectRepeatCount(value:uint):void;
	}
}
