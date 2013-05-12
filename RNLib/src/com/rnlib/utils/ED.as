/***************************************************************************************************
 * Copyright (c) 2012 Rafał Nagrodzki (http://nagrodzki.net)
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
package com.rnlib.utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.clearTimeout;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	public class ED
	{
		public function ED()
		{
		}

		public static const dispatcher:IEventDispatcher = new Sprite();

		//---------------------------------------------------------------
		//              <------ 	SYNC ------>
		//---------------------------------------------------------------

		public static function sync(e:Event, d:IEventDispatcher = null):Boolean
		{
			d = d || dispatcher;
			return d.dispatchEvent(e)
		}

		//---------------------------------------------------------------
		//              <------ ASYNC ------>
		//---------------------------------------------------------------

		private static var asyncEvents:Array = [];
		private static var asyncID:int = -1;

		/**
		 * Dispatch event asynchronously
		 * @param e Event to dispatch
		 * @param d Dispatcher
		 */
		public static function async(e:Event, d:IEventDispatcher = null):void
		{
			d = d || dispatcher;

			asyncEvents[asyncEvents.length] = new VO(d, e);
			if (asyncID == -1)
				asyncID = setTimeout(dispatchAsync, 1);
		}

		private static function dispatchAsync():void
		{
			clearTimeout(asyncID);
			asyncID = -1;

			// now we must free maim array for new async events from current frame
			// and we must dispatch all registered events in this frame
			var events:Array = asyncEvents.concat();
			asyncEvents = [];

			for each (var vo:VO in events)
			{
				vo.d.dispatchEvent(vo.e);
				vo.dispose();
			}
		}

		//---------------------------------------------------------------
		//              <------ ENTER FRAME ------>
		//---------------------------------------------------------------

		private static var ef:Array = [];

		public static function frame(e:Event, d:IEventDispatcher = null, override:Boolean = false):void
		{
			d = d || dispatcher;

			if (!(d is DisplayObject)) throw ArgumentError("Dispatcher cant be null, and must be instance of flash.display.DisplayObject");
			dispatcher.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			if (override) removeDuplicates(ef, d, e);

			ef[ef.length] = new VO(d, e);
		}

		private static function onEnterFrame(event:Event):void
		{
			for each (var vo:VO in ef)
			{
				vo.d.dispatchEvent(vo.e);
				vo.dispose();
			}
			ef = [];

			dispatcher.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		//---------------------------------------------------------------
		//              <------ RENDER ------>
		//---------------------------------------------------------------

		private static var r:Array = [];

		public static function render(e:Event, d:IEventDispatcher, override:Boolean = false):void
		{
			if (!(d is DisplayObject)) throw ArgumentError("Dispatcher cant be null, and must be instance of flash.display.DisplayObject");

			d.addEventListener(Event.RENDER, onRender);

			if (override) removeDuplicates(r, d, e);

			r[r.length] = new VO(d, e);
		}

		private static function onRender(event:Event):void
		{
			for each (var vo:VO in r)
			{
				vo.d.dispatchEvent(vo.e);
				vo.dispose();
			}
			r = [];

			dispatcher.removeEventListener(Event.RENDER, onRender);
		}

		//---------------------------------------------------------------
		//              <------ UTILS ------>
		//---------------------------------------------------------------

		private static function removeDuplicates(s:Array, d:IEventDispatcher, e:Event):void
		{
			var idx:uint = 0;
			for each (var vo:VO in s)
			{
				if (vo.d == d &&
						getQualifiedClassName(vo.e) == getQualifiedClassName(e) &&
						vo.e.type == e.type &&
						vo.e.bubbles == vo.e.bubbles &&
						vo.e.cancelable == e.cancelable)
					s.splice(idx, 1);
				else
					idx += 1;
			}
		}
	}
}

import flash.events.Event;
import flash.events.IEventDispatcher;

class VO
{
	public var d:IEventDispatcher;
	public var e:Event;

	public function VO(d:IEventDispatcher, e:Event)
	{
		this.d = d;
		this.e = e;
	}

	public function dispose():void
	{
		d = null;
		e = null;
	}
}
