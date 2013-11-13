package rnlib.net.amf.service
{
	import rnlib.net.amf.*;
	import flash.display.Sprite;

	/**
	 * @exampleText Example of registering remote method
	 */
	public class RegisteringRemoteMethods extends Sprite
	{
		public var service:RemoteAmfService;

		public function RegisteringRemoteMethods()
		{
			service = new RemoteAmfService();
			service.endpoint = "http://example.com/gateway"; // destination point
			service.service = "MyRemoteService"; // name of remote service
			service.addMethod("myMethod", onMyMethodResult, onMyMethodFault); // registering method with custom callbacks

			init();
		}

		public function init():void
		{
			var req:AMFRequest = service.myMethod(); // we registered this by addMethod function
			req.setExtraFaultParams("init");
		}

		public function onMyMethodResult(result:Object):void
		{
			trace(result);
		}

		public function onMyMethodFault(fault:Object, caller:String):void
		{
			if (fault is AMFErrorVO)
				trace(AMFErrorVO(fault).description);
			else
			{
				// do something else
				trace(fault);
			}

			trace("called on ", caller);
		}
	}
}
