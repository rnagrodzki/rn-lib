/***************************************************************************************************
 * Copyright (c) 2015. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
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

package rnlib.net.plugins
{
	import flash.utils.Dictionary;

	import rnlib.interfaces.IDisposable;
	import rnlib.net.service.ErrorVO;
	import rnlib.net.service.RemoteService;
	import rnlib.net.service.helpers.MethodVO;
	import rnlib.net.service.helpers.ResultMediatorVO;
	import rnlib.rnlib;

	public class ServicePluginsOwner implements INetPluginOwner, IDisposable
	{
		protected var _service:RemoteService;

		/**
		 * @private
		 * Dictionary
		 * key - reference of INetPlugin
		 * value - reference of MethodVO
		 */
		protected var _methodByPlugin:Dictionary = new Dictionary();

		[ArrayElementType("rnlib.net.plugins.INetPluginFactory")]
		/**
		 * @private
		 */
		protected var _pluginsFactories:Array;


		public function ServicePluginsOwner(service:RemoteService)
		{
			_service = service;
		}

		/**
		 * @private
		 * @param item
		 * @param index
		 * @param array
		 * @return
		 */
		private static function filterPlugins(item:*, index:int, array:Array):Boolean
		{return item is INetPluginFactory;}

		/**
		 * Collection of plugins associated with this object.
		 */
		public function get pluginsFactories():Array
		{
			if (!_pluginsFactories) return null;
			return _pluginsFactories.concat(null);
		}

		public function set pluginsFactories(value:Array):void
		{
			if (value)
				_pluginsFactories = value.filter(filterPlugins);
			else
				_pluginsFactories = null;
		}

		//---------------------------------------------------------------
		//
		//      PLUGINS API
		//
		//---------------------------------------------------------------
		public function pluginRequest(caller:INetPlugin, request:PluginRequestVO):void
		{
			if (!caller)
				throw new ArgumentError("Plugin caller must be setup");

			var vo:MethodVO = _methodByPlugin[caller];
			if (!vo)
				throw new Error("MethodVO not found for plugin");

			// update remote method arguments
			vo.args = request.values;

			_service.rnlib::callRemoteMethod(vo, caller);
		}
		
		public function pluginRisesFault(caller:INetPlugin, data:Object = null):void
		{
			if (!caller)
				throw new ArgumentError("Plugin caller must be setup");

			var vo:MethodVO = _methodByPlugin[caller];
			if (!vo)
				throw new Error("MethodVO not found for plugin");

			if (ErrorVO.isTimeout(data) && vo.shouldTryReconnection())
			{
				_service.rnlib::_activeConnections -= 1;
				vo.reconnect();
				_service.rnlib::callAsyncRemoteMethod(vo, caller);
				return;
			}

			disposePlugin(caller);
			_service.rnlib::callFinalFault(vo, data);
		}
		
		public function pluginRisesComplete(caller:INetPlugin, data:Object = null):void
		{
			if (!caller)
				throw new ArgumentError("Plugin caller must be setup");

			var vo:MethodVO = _methodByPlugin[caller];
			if (!vo)
				throw new Error("MethodVO not found for plugin");

			disposePlugin(caller);

			var rm:ResultMediatorVO = _service.rnlib::prepareResultMediator(vo);
			_service.rnlib::onResult(data, rm);
		}

		/**
		 * @private
		 * Check if passed ValueObject is supported by any registered INetPlugin
		 * @param vo
		 * @return
		 */
		public function pluginVOisSupported(vo:INetPluginVO):Boolean
		{
			for each (var factory:INetPluginFactory in _pluginsFactories)
				if (factory.isSupportVO(vo)) return true;
			return false;
		}

		/**
		 * @private
		 * Plugin can execute asynchronously methods so we wait until dispatch event
		 * that is ready to go
		 * @param vo
		 */
		public function waitForPlugin(vo:MethodVO):void
		{
			var pluginVO:INetPluginVO = vo.args as INetPluginVO;
			if (!pluginVO) return;

			var plugin:INetPlugin = matchPlugin(pluginVO);

			_service.dispatchEvent(new NetPluginEvent(NetPluginEvent.PLUGIN_CREATED, plugin));
			_methodByPlugin[plugin] = vo;

			plugin.init(this, pluginVO);
			_service.dispatchEvent(new NetPluginEvent(NetPluginEvent.PLUGIN_INITIALIZED, plugin));

			pluginVO = null;
			plugin = null;
		}

		/**
		 * @private
		 * Find matching plugin to passed ValueObject
		 * @param vo
		 * @return
		 */
		protected function matchPlugin(vo:INetPluginVO):INetPlugin
		{
			for each (var factory:INetPluginFactory in _pluginsFactories)
				if (factory.isSupportVO(vo)) return factory.newInstance();
			return null;
		}

		/**
		 * @private
		 * Global handler for IMultipartPlugins
		 * @param plugin
		 * @param r Object with result
		 */
		public function onPluginRequestResult(plugin:INetPlugin, r:Object):void
		{plugin.onResult(r);}

		/**
		 * @private
		 * Global handler for IMultipartPlugins
		 * @param plugin
		 * @param f Object with fault information
		 */
		public function onPluginRequestFault(plugin:INetPlugin, f:Object):void
		{plugin.onFault(f);}

		/**
		 * @private
		 * Encapsulate disposing plugin
		 * @param plugin INetPlugin to dispose
		 */
		protected function disposePlugin(plugin:INetPlugin):void
		{
			if (!_methodByPlugin[plugin])
				return;

			_methodByPlugin[plugin] = null;
			delete _methodByPlugin[plugin];

			_service.dispatchEvent(new NetPluginEvent(NetPluginEvent.PREPARE_TO_DISPOSE, plugin));
			plugin.dispose();
			_service.dispatchEvent(new NetPluginEvent(NetPluginEvent.PLUGIN_DISPOSED, plugin));
		}

		public function cancelRequest(vo:MethodVO):Boolean
		{
			//force cancel operation for plugins
			for (var plugin:Object in _methodByPlugin)
			{
				if (_methodByPlugin[plugin] === vo)
				{
					disposePlugin(plugin as INetPlugin);
					return true;
				}
			}
			return false;
		}

		public function dispose():void
		{
			for each (var factory:INetPluginFactory in _pluginsFactories)
				factory.dispose();

			_pluginsFactories = null;
			_methodByPlugin = new Dictionary();
		}
	}
}
