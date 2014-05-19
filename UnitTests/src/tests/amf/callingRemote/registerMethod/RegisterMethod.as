/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.amf.callingRemote.registerMethod
{
	import tests.amf.callingRemote.registerMethod.ReturningFault;
	import tests.amf.callingRemote.registerMethod.ReturningResult;

	[Suite(order="1")]
	[RunWith("org.flexunit.runners.Suite")]
	public class RegisterMethod
	{
		public var returningResult:ReturningResult;
		public var returningFault:ReturningFault;

	}
}
