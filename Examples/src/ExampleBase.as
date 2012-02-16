/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
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
