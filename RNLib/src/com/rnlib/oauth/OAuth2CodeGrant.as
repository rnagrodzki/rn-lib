/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.oauth
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
