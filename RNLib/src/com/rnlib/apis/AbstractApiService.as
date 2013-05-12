/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.apis
{
	import by.blooddy.crypto.serialization.JSON;

	import com.rnlib.oauth.OAuth2;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.Dictionary;

	public class AbstractApiService extends EventDispatcher
	{
		public function AbstractApiService()
		{
		}

		protected var _oauth:OAuth2;

		public function get oauth():OAuth2
		{
			return _oauth;
		}

		public function set oauth(value:OAuth2):void
		{
			if (value == _oauth) return;

			_oauth = value;
		}

		protected function loadData(req:URLRequest, result:Function, fault:Function = null):void
		{
			if (!_oauth) return;

			var l:URLLoader = new URLLoader();
			registerLoader(l, result, fault || onError);

			req.requestHeaders.push(new URLRequestHeader("Authorization", _oauth.tokenType + " " + _oauth.accessToken));
			l.load(req);
		}

		protected var _faultHandlers:Dictionary = new Dictionary(true);
		protected var _resultHandlers:Dictionary = new Dictionary(true);

		protected function registerLoader(l:URLLoader, result:Function, fault:Function):void
		{
			_resultHandlers[l] = result;
			_faultHandlers[l] = fault;

			l.addEventListener(Event.COMPLETE, result);
			l.addEventListener(IOErrorEvent.IO_ERROR, fault);
			l.addEventListener(SecurityErrorEvent.SECURITY_ERROR, fault);
		}

		protected function onError(ev:Event):void
		{
			unregisterLoader(ev);
		}

		public static function jsonDecode(data:String):Object
		{
			return by.blooddy.crypto.serialization.JSON.decode(data);
		}

		public static function eventJsonDecode(ev:Event):Object
		{
			return jsonDecode(ev.target.data);
		}

		protected function unregisterLoader(ev:Event):void
		{
			var l:URLLoader = ev.target as URLLoader;

			if (!l) return;

			l.removeEventListener(Event.COMPLETE, _resultHandlers[l]);
			l.removeEventListener(IOErrorEvent.IO_ERROR, _faultHandlers[l]);
			l.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _faultHandlers[l]);

			delete _resultHandlers[l];
			delete _faultHandlers[l];
		}
	}
}
