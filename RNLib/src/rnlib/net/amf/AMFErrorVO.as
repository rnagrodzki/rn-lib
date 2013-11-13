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
	/**
	 * Class for strict typing fault messages receiving from server.
	 *
	 * <p>Please notice that message will be rewrite only in fault handler.
	 * VO is unavailable for errors like connection status 404 or 500 and so on.</p>
	 *
	 * @see rnlib.net.amf.RemoteAmfService
	 */
	public class AMFErrorVO
	{
		/**
		 * Code of error if available.
		 */
		public var code:String;
		/**
		 * Description of error if available.
		 */
		public var description:String;
		/**
		 * Stack trace of error if available.
		 */
		public var details:Object;
		/**
		 * Level of message. Default should be <code>error</code>.
		 */
		public var level:String;
		/**
		 * Type of messages.
		 */
		public var type:String;

		/**
		 * Check if it's error object
		 * @param obj
		 * @return
		 */
		public static function isFault(obj:Object):Boolean
		{
			return obj.hasOwnProperty("level") && obj.level == "error";
		}

		/**
		 * Rewrite object received from server on strict typed error.
		 * @param obj
		 * @return
		 */
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

		/**
		 * @private
		 */
		public function toLocaleString():Object
		{
			return super.toString();
		}

		/**
		 * Override method for better tracing of errors.
		 * @return
		 */
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
