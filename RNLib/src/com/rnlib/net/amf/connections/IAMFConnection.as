/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.connections
{
	import flash.events.IEventDispatcher;

	public interface IAMFConnection extends IEventDispatcher
	{
		//---------------------------------------------------------------
		//              <------ CONNECTION ------>
		//---------------------------------------------------------------

		function connect(uri:String):void;

		function close():void;

		function get connected():Boolean;

		function call(command:String, result:Function = null, fault:Function = null, ...args):void;

		function dispose():void;

		//---------------------------------------------------------------
		//              <------ RECONNECT REPEAT COUNT ------>
		//---------------------------------------------------------------

		function get reconnectRepeatCount():uint;

		function set reconnectRepeatCount(value:uint):void;

		//---------------------------------------------------------------
		//              <------ CLIENT ------>
		//---------------------------------------------------------------

		function get client():Object;

		function set client(value:Object):void;

		//---------------------------------------------------------------
		//              <------ HEADERS ------>
		//---------------------------------------------------------------

		function addHeader(name:String, mustUnderstand:Boolean = false, data:* = undefined):void;

		function removeHeader(name:String):Boolean;

		//---------------------------------------------------------------
		//              <------ OBJECT ENCODING ------>
		//---------------------------------------------------------------

		function get objectEncoding():uint;

		function set objectEncoding(value:uint):void;

		//---------------------------------------------------------------
		//              <------ REDISPATCHER ------>
		//---------------------------------------------------------------

		function get redispatcher():IEventDispatcher;

		function set redispatcher(value:IEventDispatcher):void;

		//---------------------------------------------------------------
		//              <------ KEEP ALIVE ------>
		//---------------------------------------------------------------

		function get keepAliveTime():int;

		function set keepAliveTime(value:int):void;
	}
}
