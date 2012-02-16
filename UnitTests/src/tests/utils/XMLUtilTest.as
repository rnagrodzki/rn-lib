/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.utils
{
	import com.rnlib.utils.XMLUtil;

	import tests.utils.xmlHelpers.Helper1;
	import tests.utils.xmlHelpers.Helper2;
	import tests.utils.xmlHelpers.others.Helper3;
	import tests.utils.xmlHelpers.others.Helper4;

	public class XMLUtilTest
	{
		[Test(description="Generate XML from list of classes", order="1")]
		public function generateXMLFromClasses():void
		{
			var a:Array = [
					Helper1,
					Helper2,
					Helper3,
					Helper4
			];
			var xml:XML = XMLUtil.generatePackagesXML(a);
		}
	}
}
