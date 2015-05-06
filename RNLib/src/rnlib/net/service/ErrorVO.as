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

package rnlib.net.service
{
	/**
	 * Class for strict typing fault messages receiving from server.
	 *
	 * <p>Please notice that message will be rewrite only in fault handler.
	 * VO is unavailable for errors like connection status 404 or 500 and so on.</p>
	 *
	 * @see rnlib.net.service.RemoteService
	 */
	public class ErrorVO
	{
		public static const CONNECTION_TIMEOUT:ErrorVO = new ErrorVO("timeout", "Connection timeout");
		public static const CONNECTION_CANCELED:ErrorVO = new ErrorVO("canceled", "Canceled by user");

		/**
		 * Check if it's error object
		 * @param obj
		 * @return
		 */
		public static function isFault(obj:Object):Boolean
		{
			return obj && obj.hasOwnProperty("level") && obj.level == "error" || obj is ErrorVO;
		}

		public static function isTimeout(obj:Object):Boolean
		{
			if (obj is ErrorVO)
				return ErrorVO(obj).code == CONNECTION_TIMEOUT.code;
			return false;
		}

		public static function isCanceled(obj:Object):Boolean
		{
			if (obj is ErrorVO)
				return ErrorVO(obj).code == CONNECTION_CANCELED.code;
			return false;
		}

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

		public function ErrorVO(code:String = null, description:String = null)
		{
			level = "error";
			this.code = code;
			this.description = description;
		}

		/**
		 * Rewrite object received from server on strict typed error.
		 * @param obj
		 * @return
		 */
		public static function rewrite(obj:Object):ErrorVO
		{
			if (!obj) return null;

			if (obj is ErrorVO)
				return ErrorVO(obj);

			var vo:ErrorVO = new ErrorVO();

			if (obj.hasOwnProperty("code")) vo.code = obj.code;
			if (obj.hasOwnProperty("description")) vo.description = obj.description;

			if (vo.description is Array)
				vo.description = (vo.description as Array).join("\n");

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

		public function clone():ErrorVO
		{
			var vo:ErrorVO = new ErrorVO();
			vo.code = code;
			vo.description = description;
			vo.level = level;
			vo.details = details;
			return vo;
		}
	}
}
