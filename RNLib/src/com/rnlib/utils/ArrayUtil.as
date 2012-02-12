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
		public static function getItemPropertyIndex(property:String, value:String, source:Array):int
		{
			var n:int = source.length;
			for (var i:int = 0; i < n; i++)
			{
				if (source[i][property] == value)
					return i;
			}

			return -1;
		}

		/**
		 * Sort elements and remove duplicates without modifying original array
		 * @param source	Array to sort and remove duplicates
		 * @param fields	sort on specified fields
		 * @return	Copy of original sorted array without duplicates
		 */
		public static function sortAndRemoveDuplicates(source:Array, fields:Array = null):Array
		{
			source = source.concat();
			if (fields)
				source.sortOn(fields);
			else
				source.sort();

			for (var i:int = 0, j:int = 1; j < source.length;)
			{
				if (compareFields(source[i], source[j], fields))
				{
					source.splice(j, 1);
				}
				else
				{
					i++;
					j++;
				}
			}

			return source;
		}

		private static function compareFields(obj1:Object, obj2:Object, fields:Array):Boolean
		{
			if (!fields) return obj1 == obj2;

			for each (var prop:String in fields)
			{
				if (obj1[prop] != obj2[prop]) return false;
			}
			return true;
		}
	}
}
