/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;

	public class ED
	{
		public function ED()
		{
		}

		public static const dispatcher:IEventDispatcher = new Sprite();

		public static function now(e:Event, d:IEventDispatcher = null):Boolean
		{
			d = d || dispatcher;
			return d.dispatchEvent(e)
		}

		//---------------------------------------------------------------
		//              <------ ENTER FRAME ------>
		//---------------------------------------------------------------

		private static var ef:Array = [];

		public static function enterFrame(e:Event, d:IEventDispatcher = null, override:Boolean = false):void
		{
			d = d || dispatcher;
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

		public static function render(e:Event, d:IEventDispatcher = null, override:Boolean = false):void
		{
			d = d || dispatcher;
			dispatcher.addEventListener(Event.RENDER, onRender);

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
