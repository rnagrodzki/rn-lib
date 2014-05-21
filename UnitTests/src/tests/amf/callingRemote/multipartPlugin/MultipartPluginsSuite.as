/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.amf.callingRemote.multipartPlugin
{
	import tests.amf.callingRemote.multipartPlugin.MultipartPlugin_CallRemoteRegisteredMethod;

	[Suite(order="3")]
	[RunWith("org.flexunit.runners.Suite")]
	public class MultipartPluginsSuite
	{
		public var callRegisteredMethod:MultipartPlugin_CallRemoteRegisteredMethod;
		public var callRegisteredMethodThrowingExceptions:MultipartPlugin_CallRemoteRegisteredMethodThrowingExceptions;
	}
}
