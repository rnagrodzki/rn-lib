/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package rnlib.net.amf.helpers
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import rnlib.interfaces.IDisposable;
	import rnlib.net.amf.AMFErrorVO;
	import rnlib.net.amf.AMFRequest;
	import rnlib.net.plugins.INetMultipartPlugin;
	import rnlib.net.plugins.INetPlugin;

	public class ResultMediatorVO implements IDisposable
	{
		public var uid:int;
		public var id:int;
		public var name:String;
		public var plugin:INetPlugin;
		public var request:AMFRequest;
		public var timer:Timer = new Timer(60000, 1);

		public var resultHandler:Function;
		public var internalResultHandler:Function;

		public var isDisposed:Boolean;

		public function start(delay:uint = 60000):void
		{
			if(isDisposed)
				return;

			if (timer.delay != delay)
				timer.delay = delay;
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTime);
			timer.start();
		}

		public function result(r:Object):void
		{
			if(isDisposed)
				return;

			timer.stop();

			if (plugin is INetMultipartPlugin)
			{
				internalResultHandler(plugin, r);
			}
			else
				internalResultHandler(r, name, id, uid);

			dispose();
		}

		public var faultHandler:Function;
		public var internalFaultHandler:Function;

		public function fault(f:Object):void
		{
			if(isDisposed)
				return;

			timer.stop();

			if (plugin is INetMultipartPlugin)
			{
				internalFaultHandler(plugin, f);
			}
			else
				internalFaultHandler(f, name, id, uid);

			dispose();
		}

		public function dispose():void
		{
			if(isDisposed)
				return;

			id = 0;
			name = null;
			internalFaultHandler = null;
			internalResultHandler = null;
			faultHandler = null;
			resultHandler = null;
			plugin = null;
			request = null;
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
			if(isDisposed)
				return;

			fault(new AMFErrorVO("Connection timeout"));
		}
	}
}
