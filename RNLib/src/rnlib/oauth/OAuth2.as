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
package rnlib.oauth
{
	import rnlib.utils.ED;

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.LocationChangeEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.StageWebView;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	[Event(name="authSuccess", type="rnlib.oauth.OAuth2Event")]
	[Event(name="authError", type="rnlib.oauth.OAuth2Event")]
	[Event(name="getAccessTokenSuccess", type="rnlib.oauth.OAuth2Event")]
	[Event(name="getAccessTokenError", type="rnlib.oauth.OAuth2Event")]

	public class OAuth2 extends EventDispatcher
	{
		protected var _redirectUri:String;

		protected var _authEndpoint:String;
		protected var _tokenEndpoint:String;

		/**
		 * New instance of OAuth 2.0 service
		 *
		 * @param authEndpoint The authorization endpoint used by the OAuth 2.0 server
		 * @param tokenEndpoint The token endpoint used by the OAuth 2.0 server
		 */
		public function OAuth2(authEndpoint:String, tokenEndpoint:String)
		{
			_authEndpoint = authEndpoint;
			_tokenEndpoint = tokenEndpoint;
		}

		protected var _so:SharedObject;
		protected function get so():SharedObject
		{
			if (!_so) _so = SharedObject.getLocal("rnlib.oauth");
			return _so;
		}

		public function saveSession(key:String):Boolean
		{
			if (!key) throw new Error("Key is required");

			if (_refreshToken)
			{
				so.data[key] = _refreshToken;
				so.flush();
				return true;
			}
			return false;
		}

		public function canAutoSignIn(key:String):Boolean
		{
			if (!key) throw new Error("Key is required");

			return so.data[key] != null;
		}

		//---------------------------------------------------------------
		//              <------ WEB VIEW ------>
		//---------------------------------------------------------------

		protected var _webView:StageWebView;

		public function get webView():StageWebView
		{
			return _webView;
		}

		public function set webView(value:StageWebView):void
		{
			if (value == _webView) return;

			unregisterWebView();
			_webView = value;
			registerWebView();

			if (_grant && _webView) _webView.loadURL(_grant.getFullAuthUrl(_authEndpoint));
		}

		protected function registerWebView():void
		{
			if (!_webView) return;

			_webView.addEventListener(ErrorEvent.ERROR, onWebError);
			_webView.addEventListener(LocationChangeEvent.LOCATION_CHANGE, onWebChange);
			_webView.addEventListener(LocationChangeEvent.LOCATION_CHANGING, onWebChange);
			_webView.addEventListener(Event.COMPLETE, onWebComplete);
		}

		private function onWebComplete(event:Event):void
		{

		}

		private function onWebChange(ev:LocationChangeEvent):void
		{
			if (ev.location.indexOf(_grant.redirectUri) != 0) return;

			ev.preventDefault();
			var params:Object = extractQueryParams(ev.location);
			var code:String = params.code;

			if (!code)
			{
				ED.sync(new OAuth2Event(OAuth2Event.AUTH_ERROR), this);
				return;
			}

			ED.sync(new OAuth2Event(OAuth2Event.AUTH_SUCCESS), this);

			tokenRequest(code);
		}

		private function tokenRequest(code:String):void
		{
			var loader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest(_tokenEndpoint);
			req.method = URLRequestMethod.POST;
			req.contentType = "application/x-www-form-urlencoded";

			var args:URLVariables = new URLVariables();
			args.grant_type = "authorization_code";
			args.code = code;
			args.redirect_uri = _grant.redirectUri;
			args.client_id = _grant.clientId;
			args.client_secret = _grant.clientSecret;
			req.data = args;

			registerLoader(loader);
			loader.load(req);
		}

		private function refreshRequest(token:String):void
		{
			_refreshToken = token;

			var loader:URLLoader = new URLLoader();
			var req:URLRequest = new URLRequest(_tokenEndpoint);
			req.method = URLRequestMethod.POST;
			req.contentType = "application/x-www-form-urlencoded";

			var args:URLVariables = new URLVariables();
			args.grant_type = "refresh_token";
			args.client_id = _grant.clientId;
			args.client_secret = _grant.clientSecret;
			args.refresh_token = token;
			req.data = args;

			registerLoader(loader);
			loader.load(req);
		}

		private function onWebError(event:ErrorEvent):void
		{
			_webView.dispose();
		}

		protected function unregisterWebView():void
		{
			if (!_webView) return;

			_webView.removeEventListener(ErrorEvent.ERROR, onWebError);
			_webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGE, onWebChange);
			_webView.removeEventListener(LocationChangeEvent.LOCATION_CHANGING, onWebChange);
			_webView.removeEventListener(Event.COMPLETE, onWebComplete);
		}

		//---------------------------------------------------------------
		//              <------ URL LOADER ------>
		//---------------------------------------------------------------

		protected function registerLoader(l:URLLoader):void
		{
			l.addEventListener(Event.COMPLETE, onLoaderComplete);
			l.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			l.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
		}

		private function onLoaderError(ev:Event):void
		{
			var loader:URLLoader = ev.target as URLLoader;
			unregisterLoader(loader);

			if (_grant.key)
			{
				delete so.data[_grant.key];
				so.flush();
			}

			ED.sync(new OAuth2Event(OAuth2Event.GET_ACCESS_TOKEN_ERROR), this);
		}

		private function onLoaderComplete(ev:Event):void
		{
			var loader:URLLoader = ev.target as URLLoader;
			var response:Object = PJson.decode(loader.data);
			unregisterLoader(loader);

			_accessToken = response.access_token;
			_refreshToken = response.refresh_token || _refreshToken;
			_tokenType = response.token_type;
			_scope = response.scope || _grant.scope;
			_state = response.state || _grant.state;

			if (_grant.key && response.refresh_token) saveSession(_grant.key);

			ED.sync(new OAuth2Event(OAuth2Event.GET_ACCESS_TOKEN_SUCCESS, response), this);
		}

		protected function unregisterLoader(l:URLLoader):void
		{
			l.removeEventListener(Event.COMPLETE, onLoaderComplete);
			l.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			l.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
		}

		/**
		 * @private
		 *
		 * Helper function to extract query from URL and URL fragment.
		 */
		private function extractQueryParams(url:String):Object
		{
			var delimiter:String = (url.indexOf("?") > 0) ? "?" : "#";
			var queryParamsString:String = url.split(delimiter)[1];
			var queryParamsArray:Array = queryParamsString.split("&");
			var queryParams:Object = new Object();

			for each (var queryParam:String in queryParamsArray)
			{
				var keyValue:Array = queryParam.split("=");
				queryParams[keyValue[0]] = keyValue[1];
			}  // for loop

			return queryParams;
		}

		//---------------------------------------------------------------
		//              <------ CODE GRANT ------>
		//---------------------------------------------------------------

		protected var _grant:OAuth2CodeGrant;

		public function auth(grant:OAuth2CodeGrant):String
		{
			_grant = grant || _grant;

			if (!_grant) return null;
			var fullUrl:String = _grant.getFullAuthUrl(_authEndpoint);

			if (_grant.key && canAutoSignIn(_grant.key))
			{
				ED.sync(new OAuth2Event(OAuth2Event.AUTH_SUCCESS), this);
				refreshRequest(so.data[_grant.key]);
				return fullUrl;
			}

			if (_webView) _webView.loadURL(fullUrl);

			return fullUrl;
		}

		//---------------------------------------------------------------
		//              <------ PROPERTIES ------>
		//---------------------------------------------------------------

		private var _accessToken:String;

		public function get accessToken():String
		{
			return _accessToken;
		}

		private var _refreshToken:String;

		public function get refreshToken():String
		{
			return _refreshToken;
		}

		private var _tokenType:String;

		public function get tokenType():String
		{
			return _tokenType;
		}

		private var _scope:String;

		public function get scope():String
		{
			return _scope;
		}

		private var _state:Object;

		public function get state():Object
		{
			return _state;
		}
	}
}

import by.blooddy.crypto.serialization.JSON;

class PJson
{
	public static function encode(obj:Object):String
	{
		return by.blooddy.crypto.serialization.JSON.encode(obj);
	}

	public static function decode(str:String):Object
	{
		return by.blooddy.crypto.serialization.JSON.decode(str);
	}
}
