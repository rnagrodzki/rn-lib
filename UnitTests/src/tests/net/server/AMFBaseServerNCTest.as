/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net.server
{
	import com.rnlib.net.amf.connections.AMFNetConnection;

	public class AMFBaseServerNCTest extends AMFBaseServerTest
	{
		[Before]
		override public function before():void
		{
			conn = new AMFNetConnection();
			conn.connect(GATEWAY);
		}
	}
}
