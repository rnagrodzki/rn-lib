/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.amf.callingRemote
{
	import tests.amf.callingRemote.registerMethod.RegisterMethod;
	import tests.amf.callingRemote.multipartPlugin.MultipartPluginsSuite;

	[Suite(order="1")]
	[RunWith("org.flexunit.runners.Suite")]
	public class CallingRemote
	{
		public var registerMethod:RegisterMethod;
		public var registerMultipartPluginMethod:MultipartPluginsSuite;
	}
}
