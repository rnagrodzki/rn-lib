/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal[at]nagrodzki.net)
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

package rnlib.net.amf
{
	public class AMFErrorVO
	{
		public var code:String;
		public var description:String;
		public var details:Object;
		public var level:String;
		public var type:String;

		public static function rewrite(obj:Object):AMFErrorVO
		{
			if (!obj) return null;

			var vo:AMFErrorVO = new AMFErrorVO();

			if (obj.hasOwnProperty("code")) vo.code = obj.code;
			if (obj.hasOwnProperty("description")) vo.description = obj.description;

			if (vo.description is Array)
			{
				var desc:String = "";
				for (var i:int = 0; i < vo.description.length; i++)
					desc += vo.description[i] + "\n";

				vo.description = desc;
			}

			if (obj.hasOwnProperty("details")) vo.details = obj.details;
			if (obj.hasOwnProperty("level")) vo.level = obj.level;
			if (obj.hasOwnProperty("type")) vo.type = obj.type;

			return vo;
		}

		public function toLocaleString():Object
		{
			return super.toString();
		}

		public function toString():String
		{
			var msg:String = "[AMFErrorVO]"
					+ "\n\t" + level
					+ "\n\t" + description
					+ "\n\t" + code
					+ "\n\t" + type
					+ "\n\t" + details;
			return msg;
		}
	}
}
