/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.amf.mocks
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.ObjectEncoding;
	import flash.utils.setTimeout;

	import rnlib.net.amf.AMFEvent;

	import rnlib.net.amf.connections.IAMFConnection;
	import rnlib.net.amf.processor.AMFHeader;

	public class ConnectionMock extends EventDispatcher implements IAMFConnection
	{
		/**
		 * Data to pass with response. Resets after every call
		 */
		public var dataToPass:Object;
		/**
		 * Resets after every call
		 * -1 not set
		 * 0 force fault
		 * 1 force result
		 */
		public var forceResponseStatus:int = -1;

		private var _connected:Boolean = false;
		private var _redispatcher:IEventDispatcher;
		private var _amfHeaders:Array;
		private var _objectEncoding:uint;
		private var objectEncodingSet:Boolean = false;

		public var _callResult:Boolean;

		public function ConnectionMock(callResult:Boolean = true)
		{
			_callResult = callResult;
		}

		private static var _defaultObjectEncoding:uint = ObjectEncoding.AMF3;

		public static function get defaultObjectEncoding():uint
		{
			return _defaultObjectEncoding;
		}

		public static function set defaultObjectEncoding(value:uint):void
		{
			_defaultObjectEncoding = value;
		}


		public function connect(uri:String):void
		{
			_connected = true;
			if (_redispatcher)
				_redispatcher.dispatchEvent(new AMFEvent(AMFEvent.CONNECTED));
		}

		public function close():void
		{
			_connected = false;
			if (_redispatcher)
				_redispatcher.dispatchEvent(new AMFEvent(AMFEvent.DISCONNECTED));
		}

		public function get connected():Boolean
		{
			return _connected;
		}

		public function call(command:String, result:Function = null, fault:Function = null, ...args):void
		{
			var callResult:Boolean = _callResult;
			if(forceResponseStatus >= 0)
			{
				callResult = forceResponseStatus == 1;
				forceResponseStatus = -1;
			}

			setTimeout(callResult ? result : fault, 10, dataToPass);
			dataToPass = null;
		}

		public function get reconnectRepeatCount():uint
		{
			return 0;
		}

		public function set reconnectRepeatCount(value:uint):void
		{
		}

		public function get client():Object
		{
			return null;
		}

		public function set client(value:Object):void
		{
		}

		public function addHeader(name:String, mustUnderstand:Boolean = false, data:* = undefined):void
		{
			if (!_amfHeaders)
				_amfHeaders = [];

			var header:AMFHeader = new AMFHeader(name, mustUnderstand, data);
			_amfHeaders.push(header);
		}

		public function removeHeader(name:String):Boolean
		{
			var exists:Boolean = false;

			if (_amfHeaders)
			{
				for (var i:uint = 0; i < _amfHeaders.length; i++)
				{
					var header:AMFHeader = _amfHeaders[i] as AMFHeader;
					if (header.name == name)
					{
						_amfHeaders.splice(i, 1);
						exists = true;
					}
				}
			}

			return exists;
		}

		public function get objectEncoding():uint
		{
			if (!objectEncodingSet)
				return defaultObjectEncoding;

			return _objectEncoding;
		}

		public function set objectEncoding(value:uint):void
		{
			_objectEncoding = value;
			objectEncodingSet = true;
		}

		public function get redispatcher():IEventDispatcher
		{
			return _redispatcher;
		}

		public function set redispatcher(value:IEventDispatcher):void
		{
			_redispatcher = value;
		}

		public function get keepAliveTime():int
		{
			return -1;
		}

		public function set keepAliveTime(value:int):void
		{
		}

		public function dispose():void
		{
			close();
			_amfHeaders = null;
		}
	}
}
