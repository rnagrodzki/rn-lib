/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package com.rnlib.utils
{
	public class ArrayUtil
	{
		/**
		 *  Returns the index of the item in the Array.
		 *
		 *  @param item The item to find in the Array.
		 *  @param source The Array to search for the item.
		 *  @return The index of the item, and -1 if the item is not in the list.
		 */
		public static function getItemIndex(item:Object, source:Array):int
		{
			var n:int = source.length;
			for (var i:int = 0; i < n; i++)
			{
				if (source[i] === item)
					return i;
			}

			return -1;
		}

		/**
		 *  Returns the index of the item in the Array.
		 *
		 *  @param property The name of property in which look for
		 *  @param value The property name to find in the Array.
		 *  @param source The Array to search for the item.
		 *  @return The index of the item, and -1 if the item is not in the list.
		 */
		public static function getItemPropertieIndex(property:String, value:String, source:Array):int
		{
			var n:int = source.length;
			for (var i:int = 0; i < n; i++)
			{
				if (source[i][property] == value)
					return i;
			}

			return -1;
		}
	}
}
