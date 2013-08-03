/**
 * @author Rafał Nagrodzki (http://nagrodzki.net)
 */
package tests.net.remoteamfservice.plugins.vo
{
	import rnlib.net.plugins.INetMultipartPlugin;
	import rnlib.net.plugins.INetPluginVO;

	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class MultipartBrokenPlugin extends EventDispatcher implements INetMultipartPlugin
	{
		public var exceptionOnInit:Boolean;
		public var exceptionOnNext:Boolean;
		public var exceptionOnGetArgs:Boolean;
		public var exceptionOnDispose:Boolean;

		public function MultipartBrokenPlugin()
		{
			super();
		}

		public function next():void
		{
			if (exceptionOnNext) throw new Error("Exception on next");
		}

		public function onResult(result:Object):void
		{
		}

		public function onFault(fault:Object):void
		{
		}

		public function init(vo:INetPluginVO):void
		{
			if (exceptionOnInit) throw new Error("Exception on init");
		}

		public function dispose():void
		{
			if (exceptionOnDispose) throw new Error("Exception on dispose");
		}

		public function get args():Array
		{
			if (exceptionOnGetArgs) throw new Error("Exception on get args");
			return null;
		}

		protected var _disp:IEventDispatcher;
		public function get dispatcher():IEventDispatcher {return _disp;}
		public function set dispatcher(value:IEventDispatcher):void {_disp = value;}
	}
}
