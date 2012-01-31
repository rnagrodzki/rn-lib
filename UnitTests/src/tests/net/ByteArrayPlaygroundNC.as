/**
 * Copyright (c) Rafał Nagrodzki (http://rafal-nagrodzki.com)
 */
package tests.net
{
	import com.rnlib.net.amf.connections.AMFNetConnection;

	public class ByteArrayPlaygroundNC extends ByteArrayPlayground
	{
		[Before]
		override public function before():void
		{
			conn = new AMFNetConnection();
			conn.connect(GATEWAY);
		}
	}
}
