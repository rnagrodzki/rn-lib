/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net.amf.plugins
{
	import flash.events.IEventDispatcher;

	/**
	 * Developer of Plugin is responsible for dispatch
	 * <code>Event.COMPLETE</code> after executed by
	 * RemoteAmfService method init() then plugin is
	 * ready for return args pass to request on server
	 * by args getter.
	 */
	public interface IPlugin extends IEventDispatcher
	{
		/**
		 * Method called by RemoteAmfService o start
		 * plugin lifecycle.
		 * @param vo Param transfer from args remote method.
		 */
		function init(vo:IPluginVO):void;

		/**
		 * Method calling by RemoteAmfService on end of life
		 * plugin.
		 */
		function dispose():void;

		/**
		 * Method calling by RemoteAmfService in purpose getting
		 * arguments to pass into request on server.
		 */
		function get args():Array;
	}
}
