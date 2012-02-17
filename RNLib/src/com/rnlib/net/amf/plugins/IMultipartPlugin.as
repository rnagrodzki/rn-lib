/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	/**
	 * Developer of MultipartPlugin is responsible to dispatch event
	 * <code>Event.READY</code> always after execute by RemoteAmfService
	 * init() or next() method. Please notice that init() method is calling
	 * only once at start "lifecycle" of plugin. Method next() is calling
	 * as many times as needed to complete work by plugin. After that
	 * plugin dispatch event <code>PluginEvent.COMPLETE</code>
	 *
	 * @see com.rnlib.net.amf.plugins.PluginEvent
	 */
	public interface IMultipartPlugin extends IPlugin
	{
		/**
		 * Method calling sequential in loop of requests on server after
		 * first init call until plugin finish his work and inform
		 * about it dispatched <code>PluginEvent.COMPLETE</code>
		 * or error occur and plugin dispatch <code>PluginEvent.CANCEL</code>.
		 *
		 * @see com.rnlib.net.amf.plugins.PluginEvent
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
