/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
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
				trace(qClass);
				var parts:Array = qClass.split(".");
				if (parts.length > 1)
				{
					var last:String = parts.pop();
					parts = parts.concat(last.split("::"));
				}

				trace(parts);

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

			trace(xml);
			return xml;
		}
	}
}
