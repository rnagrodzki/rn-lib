/***************************************************************************************************
 * Copyright (c) 2013. Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
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
package rnlib.net.cache.rules
{
	public class CacheRuleConstants
	{
		/**
		 * This rule never be applied to remote methods invoke.
		 */
		public static const POLICY_NEVER:String = "never";

		/**
		 * This rule will applied before invoke remote method. In other words with this trigger
		 * you will force using resources from cache (if only they exists there) against
		 * downloading fresh data from server.
		 * <p>Make sure that all require data is cached. If they not, missing data will be get
		 * from server.</p>
		 */
		public static const POLICY_BEFORE_REQUEST:String = "beforeRequest";

		/**
		 * This rule will applied after receive response from server.
		 * <p>This trigger cache all new and outdated resources. Data from cache will be resolved
		 * only if server return <code>fault</code> status. So it's work mainly as fallback
		 * for server requests. Keep in mind that it's transparent for RemoteService so you can't
		 * be sure from which source you received data.</p>
		 */
		public static const POLICY_AFTER_REQUEST:String = "afterRequest";
	}
}
