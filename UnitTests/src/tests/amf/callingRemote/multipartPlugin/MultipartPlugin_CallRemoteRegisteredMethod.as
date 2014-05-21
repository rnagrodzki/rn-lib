/**
 * @author Rafał Nagrodzki (e-mail: rafal@nagrodzki.net)
 */
package tests.amf.callingRemote.multipartPlugin
{
	import org.morefluent.integrations.flexunit4.after;

	import rnlib.net.amf.AMFEvent;
	import rnlib.net.plugins.NetPluginEvent;

	[TestCase(order="1")]
	public class MultipartPlugin_CallRemoteRegisteredMethod extends AbstractMultiPluginTest
	{
		[Test(order="1", async)]
		public function raisesGlobalResultEventOnServerResult():void
		{
			after(AMFEvent.RESULT, 100).on(_service).pass();
			after(AMFEvent.FAULT, 100).on(_service).fail();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{event: new NetPluginEvent(NetPluginEvent.COMPLETE)}
			]);
		}

		[Test(order="2", async)]
		public function raisesGlobalFaultEventOnCancelEvent():void
		{
			after(AMFEvent.FAULT, 100).on(_service).pass();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{event: new NetPluginEvent(NetPluginEvent.CANCEL)},
				{event: new NetPluginEvent(NetPluginEvent.COMPLETE)}
			]);
		}

		[Test(order="3", async)]
		public function raisesGlobalFaultEventOnCancelRequest():void
		{
			after(AMFEvent.FAULT, 100).on(_service).pass();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{event: new NetPluginEvent(NetPluginEvent.COMPLETE)}
			]).cancel();
		}

		[Test(order="4", async)]
		public function allowPluginRaisesFaultEventOnServerFault():void
		{
			after(AMFEvent.FAULT, 100).on(_service).pass();
			after(AMFEvent.RESULT, 100).on(_service).fail();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{
					event: new NetPluginEvent(NetPluginEvent.READY),
					responseStatus: 0
				},
				{
					event: new NetPluginEvent(NetPluginEvent.COMPLETE),
					faultEvent: new NetPluginEvent(NetPluginEvent.CANCEL)
				}
			]);
		}

		[Test(order="4", async)]
		public function allowPluginRaisesResultEventOnServerFault():void
		{
			after(AMFEvent.RESULT, 100).on(_service).pass();
			after(AMFEvent.FAULT, 100).on(_service).fail();

			callInSequence([
				{event: new NetPluginEvent(NetPluginEvent.READY)},
				{
					event: new NetPluginEvent(NetPluginEvent.READY),
					responseStatus: 0
				},
				{
					event: new NetPluginEvent(NetPluginEvent.CANCEL),
					faultEvent: new NetPluginEvent(NetPluginEvent.COMPLETE)
				}
			]);
		}
	}
}
