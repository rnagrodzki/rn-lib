/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.plugins
{
	import flash.events.IEventDispatcher;

	/**
	 * Developer of Plugin is responsible for dispatch
	 * <code>NetPluginEvent.READY</code> after executed by
	 * RemoteAmfService method init(). The event inform
	 * amf service that plugin is ready for return args
	 * which will pass to request on server by args getter.
	 *
	 *
	 * @see com.rnlib.net.plugins.NetPluginEvent
	 */
	public interface INetPlugin extends IEventDispatcher
	{
		/**
		 * Method called by RemoteAmfService o start
		 * plugin lifecycle.
		 * @param vo Param transfer from args remote method.
		 *
		 * @see com.rnlib.net.plugins.NetPluginEvent
		 */
		function init(vo:INetPluginVO):void;

		/**
		 * Method calling by RemoteAmfService on end of life
		 * plugin.
		 *
		 * @see com.rnlib.interfaces.IDisposable
		 */
		function dispose():void;

		/**
		 * Method calling by RemoteAmfService in purpose getting
		 * arguments to pass into request on server.
		 */
		function get args():Array;

		/**
		 * Dispatcher pass to give possibility dispatching events
		 * on RemoteAmfService.
		 */
		function get dispatcher():IEventDispatcher;
		function set dispatcher(value:IEventDispatcher):void;
	}
}
