/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	/**
	 * Developer of MultipartPlugin is responsible to dispatch event
	 * <code>Event.COMPLETE</code> always after execute by RemoteAmfService
	 * init() or next() method. Please notice that init() method is calling
	 * only once at start "lifecycle" of plugin. Method next() is calling
	 * as many times as still return <code>true</code>.
	 *
	 * Full lifecycle of MultipartPlugin can be as follow:
	 * constructor() -> init() -> dispatch complete event
	 * -> onResult()/onFault()
	 * -------- this part can be repeatable many times -----------
	 * -> next() return true -> dispatch complete event
	 * -> onResult()/onFault()
	 */
	public interface IMultipartPlugin extends IPlugin
	{
		/**
		 * Method calling sequential in loop of requests on server after
		 * first init call until is returning <code>true</code>.
		 * @return If return <code>false</code> loop of requests
		 * on server is break down.
		 */
		function next():void;

		/**
		 * Callback to pass result from server
		 * @param result
		 */
		function onResult(result:Object):void;

		/**
		 * Callback to pass fault from server
		 * @param fault
		 */
		function onFault(fault:Object):void;
	}
}
