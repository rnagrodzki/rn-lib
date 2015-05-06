/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package rnlib.net.service.helpers
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import rnlib.interfaces.IDisposable;
	import rnlib.net.plugins.INetPlugin;
	import rnlib.net.service.ErrorVO;
	import rnlib.net.service.Request;
	import rnlib.rnlib;

	use namespace rnlib;

	public class ResultMediatorVO implements IDisposable
	{
		public var uid:int;
		public var id:int;
		public var name:String;
		public var plugin:INetPlugin;
		public var timer:Timer = new Timer(60000, 1);

		public var resultHandler:Function;
		public var internalResultHandler:Function;
		public var methodVO:MethodVO;

		public var isDisposed:Boolean;

		public function get request():Request {return methodVO ? methodVO.request : null;}

		public function start(delay:uint = 60000):void
		{
			if (isDisposed)
				return;

			delay = request.rnlib::timeout > -1 ? request.rnlib::timeout : delay;

			if (delay <= 0)
				return;

			if (timer.delay != delay)
				timer.delay = delay;
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTime);
			timer.start();
		}

		public function result(r:Object):void
		{
			if (isDisposed)
				return;

			timer.stop();

			if (plugin is INetPlugin)
				internalResultHandler(plugin, r);
			else
				internalResultHandler(r, this);

			dispose();
		}

		public var faultHandler:Function;
		public var internalFaultHandler:Function;

		public function fault(f:Object):void
		{
			if (isDisposed)
				return;

			timer.stop();

			if (plugin is INetPlugin)
				internalFaultHandler(plugin, f);
			else
				internalFaultHandler(f, this);

			dispose();
		}

		public function canceled():void
		{

		}

		public function dispose():void
		{
			if (isDisposed)
				return;

			id = 0;
			name = null;
			internalFaultHandler = null;
			internalResultHandler = null;
			faultHandler = null;
			resultHandler = null;
			plugin = null;
			if (timer)
			{
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTime);
				timer.stop();
			}
			timer = null;
			isDisposed = true;
		}

		protected function onTime(ev:TimerEvent):void
		{
			if (isDisposed)
				return;

			var errorVO:ErrorVO = ErrorVO.CONNECTION_TIMEOUT.clone();
			fault(errorVO);
		}
	}
}
