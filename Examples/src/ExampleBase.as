/*
 * Copyright (c) 2012. Rafał Nagrodzki (rafal[dot]nagrodzki[dot]dev[at]gmail[dot]com)
 *  http://rafal-nagrodzki.com/
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package
{
	import spark.components.Group;
	import spark.components.Label;
	import spark.layouts.VerticalLayout;

	public class ExampleBase extends Group
	{
		public function ExampleBase()
		{
		}

		//---------------------------------------------------------------
		//              	<------ TITLE ------>
		//---------------------------------------------------------------

		private var _title:String;

		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;

			if (_titleLabel) _titleLabel.text = value;
		}

		protected var _titleLabel:Label;

		//---------------------------------------------------------------
		//              <------ DESCRIPTION ------>
		//---------------------------------------------------------------

		private var _description:String;

		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		protected var _descriptionLabel:Label;

		//---------------------------------------------------------------
		//              <------ COMPONENT LIFECYCLE ------>
		//---------------------------------------------------------------

		override public function initialize():void
		{
			percentWidth = 100;
			percentHeight = 100;

			layout = new VerticalLayout();

			super.initialize();
		}

		override protected function createChildren():void
		{
			if(!_descriptionLabel)
			{
				_descriptionLabel = new Label();
				_descriptionLabel.text = _description;

				_descriptionLabel.setStyle("textAlign", "center");
				_descriptionLabel.setStyle("fontSize", 14);
				_descriptionLabel.setStyle("paddingTop", 0);
				_descriptionLabel.setStyle("paddingBottom", 5);
				_descriptionLabel.percentWidth = 100;

				addElementAt(_descriptionLabel,0);
			}

			if (!_titleLabel)
			{
				_titleLabel = new Label();
				_titleLabel.text = _title;

				_titleLabel.setStyle("textAlign", "center");
				_titleLabel.setStyle("fontSize", 20);
				_titleLabel.setStyle("paddingTop", 10);
				_titleLabel.setStyle("paddingBottom", 10);
				_titleLabel.percentWidth = 100;

				addElementAt(_titleLabel,0);
			}

			super.createChildren();
		}
	}
}
