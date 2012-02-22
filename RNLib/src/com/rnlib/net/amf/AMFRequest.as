/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf
{
	public class AMFRequest
	{
		public var uid:int;

		internal var extraResult:Array;

		public function setExtraResultParams(...rest):AMFRequest
		{
			extraResult = rest;
			return this;
		}

		internal var extraFault:Array;

		public function setExtraFaultParams(...rest):AMFRequest
		{
			extraFault = rest;
			return this;
		}

		internal var requestSend:Boolean = false;
		public function get called():Boolean
		{
			return requestSend;
		}
	}
}
