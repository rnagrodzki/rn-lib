/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf
{
	import com.rnlib.interfaces.IDisposable;

	/**
	 * Helper for data storage calls of remote methods
	 */
	public class MethodVO implements IDisposable
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

		public function dispose():void
		{
			name = null;
			result = null;
			fault = null;
			args = null;
		}

		public function clone():MethodVO
		{
			var vo:MethodVO=new MethodVO();
			vo.args = args;
			vo.name = name;
			vo.result = result;
			vo.fault = fault;
			vo.uid = uid;
			return vo;
		}
	}
}
