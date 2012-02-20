/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.plugins
{
	/**
	 * Developer of MultipartPlugin is responsible to dispatch event
	 * <code>Event.READY</code> always after execute by RemoteAmfService
	 * init() or next() method. Please notice that init() method is calling
	 * only once at start "lifecycle" of plugin. Method next() is calling
	 * as many times as needed to complete work by plugin. After that
	 * plugin dispatch event <code>NetPluginEvent.COMPLETE</code>
	 *
	 * @see com.rnlib.net.plugins.NetPluginEvent
	 */
	public interface INetMultipartPlugin extends INetPlugin
	{
		/**
		 * Method calling sequential in loop of requests on server after
		 * first init call until plugin finish his work and inform
		 * about it dispatched <code>NetPluginEvent.COMPLETE</code>
		 * or error occur and plugin dispatch <code>NetPluginEvent.CANCEL</code>.
		 *
		 * @see com.rnlib.net.plugins.NetPluginEvent
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
