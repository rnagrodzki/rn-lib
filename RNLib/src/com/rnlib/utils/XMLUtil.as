/***************************************************************************************************
 Copyright (c) 2012. Rafał Nagrodzki (rafal[dot]nagrodzki[dot]dev[at]gmail[dot]com)
 http://rafal-nagrodzki.com/

 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **************************************************************************************************/
package com.rnlib.utils
{
	import avmplus.getQualifiedClassName;

	public class XMLUtil
	{
		public function XMLUtil()
		{
		}

		public static function generatePackagesXML(classes:Array):XML
		{
			var xml:XML = XML("<menu></menu>");
			for each (var cl:Class in classes)
			{
				var qClass:String = getQualifiedClassName(cl);
				var parts:Array = qClass.split(".");
				if (parts.length > 1)
				{
					var last:String = parts.pop();
					parts = parts.concat(last.split("::"));
				}

				var xmlnode:Object = xml;
				for each (var part:String in parts)
				{
					var node:Object = <node/>;
					node.@name = part;
					var list:XMLList = xml..node.(@name == part);
					if (list.length() == 0)
					{
						xmlnode.appendChild(node);
						xmlnode = node;
					}
					else
					{
						xmlnode = list[0];
					}
				}

				xmlnode.@descriptor = qClass;
			}

			return xml;
		}
	}
}
