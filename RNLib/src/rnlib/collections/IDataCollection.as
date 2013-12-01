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
package rnlib.collections
{
	public interface IDataCollection
	{
		/**
		 * Dispose collections
		 *
		 * @see rnlib.interfaces.IDisposable
		 */
		function dispose():void;

		/**
		 * Add items into collections with default priority
		 * @param rest
		 */
		function push(...rest):void;

		/**
		 * Push item into collection with priority.
		 * @param item    Item to pushed
		 * @param priority    The priority level of the item in collections. The priority is designated by a signed
		 *         32-bit integer. The higher the number, the higher the priority. All items with priority n are
		 *         returned before item of priority n-1. If two or more items share the same priority,
		 *         they are returned in the order in which they were added. The default priority is 0.
		 */
		function pushWithPriority(item:*, priority:int = 1):DataCollectionItemVO;

		/**
		 * Update item priority
		 * @param item Searched item
		 * @param priority New priority for item
		 * @return <code>true</code> if item found and priority was updated, otherwise return <code>false</code>
		 */
		function updateItemPriority(item:*, priority:int):Boolean;

		/**
		 * Get next item in collections and remove it from collections
		 */
		function getItem():*;

		/**
		 * Removes item from the collections
		 * @param item
		 */
		function removeItem(item:*):void;

		/**
		 * Get length of collections
		 */
		function get length():uint;

		/**
		 * Clone collections object
		 * @return Cloned collections
		 */
		function clone():IDataCollection;

		/**
		 * Sort elements in collections.
		 * <p>Sort method is executed only if is needed.</p>
		 */
		function sort():void;

		/**
		 * Returns source of the collections
		 */
		function get source():Array;
	}
}
