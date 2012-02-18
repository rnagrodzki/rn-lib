/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf
{
	/**
	 * Helper for data storage calls of remote methods
	 */
	public class MethodVO
	{
		/**
		 * Unique identifier for any remote call
		 */
		public var uid:int;

		/**
		 * Name of remote methods to call
		 */
		public var name:String;

		/**
		 * Callback to invoke after receive
		 * response from server
		 */
		public var result:Function;

		/**
		 * Callback to invoke after receive
		 * response from server
		 */
		public var fault:Function;

		/**
		 * Arguments to pass to remote method
		 */
		public var args:Object;
	}
}
