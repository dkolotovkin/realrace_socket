package utils.managers.apimanager
{
	import application.GameApplication;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.setInterval;
	
	import utils.md5.Md5;
	import utils.user.User;
	import utils.vk.api.serialization.json.JSON;

	public class ApiManagerMB extends ApiManager
	{
		public function ApiManagerMB()
		{
			super();
			
			var params:String = GameApplication.app.config.oid + "app_id=" + GameApplication.app.config.app_id + "blocks=info" + "method=anketa.getInfo" + "oids=" + GameApplication.app.config.oid + "sid=" + GameApplication.app.config.sid + GameApplication.app.config.privatekeymb;
			
			var request:URLRequest = new URLRequest("http://api.aplatform.ru");
			var variables:URLVariables = new URLVariables();
			variables["method"] = "anketa.getInfo";
			variables["app_id"] = GameApplication.app.config.app_id;
			variables["oids"] = [GameApplication.app.config.oid];
			variables["sig"] = Md5.hash(params);
			variables["sid"] = GameApplication.app.config.sid;
			variables["blocks"] = "info";
			
			request.data = variables;
			request.method = URLRequestMethod.POST;
			
			var _loader:URLLoader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onGetInfo);
			_loader.load(request);
		}
		
		private function onGetInfo(e:Event):void{
			var obj:Object = JSON.decode(e.target.data);
			try{
				title = obj["data"][0]["info"]["name"];
			}catch(e:*){
				title = "Мышь " + Math.round(Math.random() * 1000);
			}
		}
		
		public function showUserPage(user:User):void
		{
			var userID:String = user.idSocial.substring(2, user.idSocial.length);
			var params:String = GameApplication.app.config.oid + "app_id=" + GameApplication.app.config.app_id + "blocks=info" + "method=anketa.getInfo" + "oids=" + userID + "sid=" + GameApplication.app.config.sid + GameApplication.app.config.privatekeymb;
			
			var request:URLRequest = new URLRequest("http://api.aplatform.ru");
			var variables:URLVariables = new URLVariables();
			variables["method"] = "anketa.getInfo";
			variables["app_id"] = GameApplication.app.config.app_id;
			variables["oids"] = [userID];
			variables["sig"] = Md5.hash(params);
			variables["sid"] = GameApplication.app.config.sid;
			variables["blocks"] = "info";
			
			request.data = variables;
			request.method = URLRequestMethod.POST;
			
			var _loader:URLLoader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onShowUserPage);
			_loader.load(request);
		}
		
		private function onShowUserPage(e:Event):void{
			var obj:Object = JSON.decode(e.target.data);
			try{
				var userUrl:String = obj["data"][0]["info"]["anketa_link"];
				var request:URLRequest = new URLRequest(userUrl);
				try {
					navigateToURL(request, '_blank');
				} catch (e:Error) {
					trace("Error occurred!");
				}
			}catch(e:*){
			}
		}
		
		override public function init():void{
			idsocail = "mb" + GameApplication.app.config.oid;
			autukey = GameApplication.app.config.auth_key;
			appid = String(GameApplication.app.config.app_id);
			vid = String(GameApplication.app.config.oid);
			
			url = "http://mamba.ru/anketa.phtml?oid=" + GameApplication.app.config.oid;
			
			GameApplication.app.connect();
			
			_sid = setInterval(updateParams, 5000);
		}
		
		override public function showBuyMoneyPopUp():void{			
		}
	}
}