/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package view.oauth2
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;

	import mx.core.UIComponent;

	public class MobileWebComponent extends UIComponent
	{
		public function MobileWebComponent()
		{
		}

		private var _web:StageWebView;

		public function get web():StageWebView
		{
			return _web;
		}

		public function set web(value:StageWebView):void
		{
			_web = value;
		}

		private var _url:String;

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			if (value == _url) return;

			_url = value;

			if (_web)
				_web.loadURL(_url);
		}

		override protected function createChildren():void
		{
			super.createChildren();

			_web = new StageWebView();
			_web.stage = stage;

			if (_url)
				_web.loadURL(_url);

			minWidth = 100;
			minHeight = 100;
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			var point:Point = localToGlobal(new Point());

			_web.viewPort = new Rectangle(point.x, point.y, unscaledWidth, unscaledHeight);
		}
	}
}
