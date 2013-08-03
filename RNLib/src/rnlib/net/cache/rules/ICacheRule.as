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
package rnlib.net.cache.rules
{
	public interface ICacheRule
	{
		/**
		 * Determine when value from cache will be grab.
		 * <p>If not set <code>"never"</code> value will be used.</p>
		 *
		 * @see rnlib.net.cache.rules.CacheRuleConstants#POLICY_AFTER_REQUEST
		 * @see rnlib.net.cache.rules.CacheRuleConstants#POLICY_BEFORE_REQUEST
		 * @see rnlib.net.cache.rules.CacheRuleConstants#POLICY_NEVER
		 */
		function get policy():String;

		/**
		 * Resolve identifier to cache resources based on passed parameters
		 * @param methodName The name of called method
		 * @param requestUID The unique request identifier
		 * @param params The parameters passed to body of remote method
		 * @return Unique identifier of cache resources
		 */
		function resolveID(methodName:String, requestUID:int, params:Array):Object;
	}
}
