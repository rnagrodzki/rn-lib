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
	public class OAuth2CodeGrant
	{
		private var _clientId:String;
		private var _clientSecret:String;
		private var _redirectUri:String;
		private var _scope:String;
		private var _state:Object;
		private var _key:String;

		/**
		 * Constructor.
		 *
		 * @param clientId The client identifier
		 * @param clientSecret The client secret
		 * @param redirectUri The redirect URI to return to after the authorization process has completed
		 * @param scope (Optional) The scope of the access request expressed as a list of space-delimited, case-sensitive strings
		 * @param state (Optional) An opaque value used by the client to maintain state between the request and callback
		 * @param sessionKey (Optional) Key to storage refresh token
		 */
		public function OAuth2CodeGrant(clientId:String, clientSecret:String, redirectUri:String, scope:String = null, state:Object = null, sessionKey:String = null)
		{
			_clientId = clientId;
			_clientSecret = clientSecret;
			_redirectUri = redirectUri;
			_scope = scope;
			_state = state;
			_key = sessionKey;
		}

		public function get key():String
		{
			return _key;
		}

		/**
		 * The client identifier as described in the OAuth spec v2.15,
		 * section 3, Client Authentication.
		 *
		 * @see http://tools.ietf.org/html/draft-ietf-oauth-v2-15#section-3
		 */
		public function get clientId():String
		{
			return _clientId;
		}

		/**
		 * The client secret.
		 */
		public function get clientSecret():String
		{
			return _clientSecret;
		}

		/**
		 * The redirect endpoint for the client as described in the OAuth
		 * spec v2.15, section 3.1.2, Redirection Endpoint.
		 *
		 * @see http://tools.ietf.org/html/draft-ietf-oauth-v2-20#section-3.1.2
		 */
		public function get redirectUri():String
		{
			return _redirectUri;
		}

		/**
		 * The scope of the access request expressed as a list of space-delimited,
		 * case-sensitive strings.
		 */
		public function get scope():String
		{
			return _scope;
		}

		/**
		 * An opaque value used by the client to maintain state between the request
		 * and callback.
		 */
		public function get state():Object
		{
			return _state;
		}

		/**
		 * Convenience method for getting the full authorization URL.
		 */
		public function getFullAuthUrl(authEndpoint:String):String
		{
			var url:String = authEndpoint + "?response_type=code&client_id=" + clientId + "&redirect_uri=" + redirectUri;

			// scope is optional
			if (scope != null && scope.length > 0)
			{
				url += "&scope=" + scope;
			}  // if statement

			// state is optional
			if (state != null)
			{
				url += "&state=" + state;
			}  // if statement

			return url;
		}
	}
}
