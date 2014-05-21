import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.net.FileReferenceList;
import flash.net.registerClassAlias;

import rnlib.net.RequestConcurrency;
import rnlib.net.amf.AMFRequest;
import rnlib.net.amf.helpers.MockResponseVO;
import rnlib.net.amf.RemoteAmfService;
import rnlib.net.plugins.FileReferencePlugin;
import rnlib.net.plugins.FileReferencePluginVO;
import rnlib.net.plugins.NetPluginFactory;

/**
 * @exampleText Advanced usage of RemoteAMFService. In this example we will login user, upload files in collections on server and logout after finish.
 */
public class AdvancedUsage extends Sprite
{
	public var service:RemoteAmfService;

	public function AdvancedUsage()
	{
		setup(true);
		automaticLoginUser();
	}

	//---------------------------------------------------------------
	//
	//      BASIC SETUP
	//
	//---------------------------------------------------------------

	public function setup(useMocks:Boolean = false):void
	{
		// register alias for typed objects
		registerClassAlias("vo.Data", DataVO);

		// create and setup service
		service = new RemoteAmfService();
		service.service = "MyAdvRemoteService";
		service.concurrency = RequestConcurrency.QUEUE;
		service.maxConnections = 1;
		service.proceedAfterError = true;

		// register remote methods
		// it's couple ways to catch response from server
		service.addMethod("login", onUserLogged, onUserLoginFault); // by custom handlers
		service.addMethod("logout"); // by global handlers service.result && service.fault or AMFEvent
		service.addMethod("upload_assets", onFileUplaoded); // you can mixed this ways

		// register plugins associated with service
		service.pluginsFactories = [new NetPluginFactory(FileReferencePlugin, FileReferencePluginVO)];

		// mock all or part of your remote methods
		if (useMocks)
		{
			service.addMockMethod("login", mockLoginMethod);
			service.addMockMethod("logout", mockLogoutMethod);
		}
	}

	public function automaticLoginUser():void
	{
		// login user calling remote method
		// if you pass properly data result will be called, fault otherwise
		service.login("tester", "1234");
	}

	public function prepareUI():void
	{
		addEventListener(MouseEvent.CLICK, onSelectFiles);
	}

	public function logoutUser():void
	{
		trace("logout user");
		service.logout();
	}

	//---------------------------------------------------------------
	//
	//      HANDLERS
	//
	//---------------------------------------------------------------

	private function onUserLoginFault(vo:DataVO):void
	{
		trace("Wrong user name or password");
	}

	private function onUserLogged(vo:DataVO):void
	{
		trace("login successful");
		prepareUI();
	}

	private function onFileUplaoded(response:Object, extraFunc:Function):void
	{
		if (extraFunc) extraFunc();
	}

	private function onSelectFiles(ev:MouseEvent):void
	{
		// now we should select some files
		var files:FileReferenceList = new FileReferenceList();
		files.addEventListener(Event.SELECT, onFilesSelected);
		files.browse();
	}

	private function onFilesSelected(ev:Event):void
	{
		var files:FileReferenceList = ev.target as FileReferenceList;
		var lastRequest:AMFRequest;
		for each (var file:FileReference in files.fileList)
		{
			// lets do some magic!
			// In this single line all selected files will loaded just in time
			// and passed on server to upload_assets remote method.
			// All requests are queued so only one file will upload at same time.
			lastRequest = service.upload_assets(new FileReferencePluginVO(file));
		}
		lastRequest.setExtraResultParams(logoutUser);
	}

	//---------------------------------------------------------------
	//
	//      MOCK METHODS
	//
	//---------------------------------------------------------------

	public function mockLoginMethod(user:String, pass:String):MockResponseVO
	{
		trace("called mock method login");
		trace("user", user);
		trace("password", pass);

		var data:DataVO = new DataVO();
		data.user = user;
		data.assets = [];

		var mock:MockResponseVO = new MockResponseVO();
		mock.success = user == "tester" && pass == "1234";
		mock.interval = 200; // wait 200ms until pass response
		mock.response = [data];

		return mock;
	}

	public function mockLogoutMethod():MockResponseVO
	{
		trace("called mock logout method");
		return new MockResponseVO(true, 100, [true]);
	}
}

public class DataVO
{
	public var user:String;
	public var status:String;
	public var assets:Array;
}