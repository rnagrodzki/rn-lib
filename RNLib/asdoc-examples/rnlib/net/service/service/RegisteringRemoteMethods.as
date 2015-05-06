package rnlib.net.service.service
{
	import flash.display.Sprite;

	import rnlib.net.service.*;

	/**
	 * @exampleText Example of registering remote method
	 */
	public class RegisteringRemoteMethods extends Sprite
	{
		public var service:RemoteService;

		public function RegisteringRemoteMethods()
		{
			service = new RemoteService();
			service.endpoint = "http://example.com/gateway"; // destination point
			service.service = "MyRemoteService"; // name of remote service
			service.addMethod("myMethod", onMyMethodResult, onMyMethodFault); // registering method with custom
		                                                                      // callbacks

			init();
		}

		public function init():void
		{
			var req:Request = service.myMethod(); // we registered this by addMethod function
			req.setExtraFaultParams("init");
		}

		public function onMyMethodResult(result:Object):void
		{
			trace(result);
		}

		public function onMyMethodFault(fault:Object, caller:String):void
		{
			if (fault is ErrorVO)
				trace(ErrorVO(fault).description);
			else
			{
				// do something else
				trace(fault);
			}

			trace("called on ", caller);
		}
	}
}
