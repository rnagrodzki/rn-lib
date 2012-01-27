/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.net
{
	public class RequestConcurrency
	{
		/**
		 * Existing requests are not cancelled, and the developer is
		 * responsible for ensuring the consistency of returned data by carefully
		 * managing the event stream.
		 */
		public static const MULTIPLE:String = "multiple";

		/**
		 * Making only one request at a time is allowed on the method; additional requests made
		 * while a request is outstanding are immediately faulted on the client and are not sent to the server.
		 */
		public static const SINGLE:String = "single";

		/**
		 * Making a request causes the client to ignore a result or fault for any current outstanding request.
		 * Only the result or fault for the most recent request will be dispatched on the client.
		 * This may simplify event handling in the client application, but care should be taken to only use
		 * this mode when results or faults for requests may be safely ignored.
		 */
		public static const LAST:String = "last";

		/**
		 * All requests are added to queue and will invoke one after another
		 * immediately after receiving response from server. This is the default.
		 */
		public static const QUEUE : String = "queue";
	}
}
