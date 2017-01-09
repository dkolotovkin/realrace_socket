package utils.managers.apimanager
{
	import application.GameApplication;
	import application.components.popup.buymoney.od.PopUpBuyMoneyOD;
	import application.components.popup.friendsBonus.PopUpFriendsBonus;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.graphics.codec.PNGEncoder;
	
	import utils.multypart.MultipartURLLoader;
	import utils.od.api.forticom.ApiCallbackEvent;
	import utils.od.api.forticom.ForticomAPI;
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;
	import utils.vk.api.MD5;
	import utils.vk.api.serialization.json.JSON;

	public class ApiManagerOD extends ApiManager
	{
		private var uid:String;
		private var _connectInterval:int = -1;
		
		public function ApiManagerOD(){			
			super();
			ForticomAPI.connection = GameApplication.app.config.apiconnection;
			ForticomAPI.addEventListener(ForticomAPI.CONNECTED, apiIsReady);			
			ForticomAPI.addEventListener(ApiCallbackEvent.CALL_BACK, handleApiEvent);

			autukey = GameApplication.app.config.auth_sig;
			appid = GameApplication.app.config.session_key;									//в appID для одноклассников передается параметр session_key, т.к. он необходим для авторизации и appID не передается в flashvars
			vid = GameApplication.app.config.logged_user_id;
			idsocail = "od" + vid;			
//			url = "http://www.odnoklassniki.ru/profile/" + vid;								//неправильная ссылка, т.к. API не предоставляет реального ID пользователя, а ссылки на пользователей временные
					
			if(_connectInterval != -1){
				clearInterval(_connectInterval);
				_connectInterval = -1;
			}
			_connectInterval = setInterval(checkAddedAndConnect, 3000);
		}
		
		protected function apiIsReady(event : Event) : void
		{
			ForticomAPI.removeEventListener(ForticomAPI.CONNECTED, apiIsReady);
			checkAddedAndConnect();
		}
		
		protected function handleApiEvent(event : ApiCallbackEvent) : void{
//			Alert.show(event.method + "\n" + event.result + "\n" + event.data);
		}
		
		override public function post(ptitle:String, pcontent:String, bitmapData:BitmapData, isSS:Boolean = false):void{
			isSceneScreen = isSS;
			postTitle = ptitle;
			postContent = pcontent;
			postBitmapData = bitmapData;
			
			if(photoPermOn){
				getAlbums();
			}else{
				var photoPermotion:String = "PHOTO CONTENT";
				var request:URLRequest = new URLRequest(GameApplication.app.config.api_server + "api/users/hasAppPermission");
				var variables:URLVariables = new URLVariables();				
				variables["application_key"] = GameApplication.app.config.application_key;
				variables["ext_perm"] = photoPermotion;
				variables["session_key"] = GameApplication.app.config.session_key;
				var sigStr:String = "application_key=" + GameApplication.app.config.application_key + "ext_perm=" + photoPermotion + "session_key=" + GameApplication.app.config.session_key + GameApplication.app.config.session_secret_key;
				variables["sig"] = MD5.encrypt(sigStr);
				
				request.data = variables;
				request.method = URLRequestMethod.POST;
				
				var _loader:URLLoader = new URLLoader();
				_loader.addEventListener(Event.COMPLETE, onCheckPermission);
				_loader.load(request);
			}
		}
		
		private function onCheckPermission(e:Event):void{
			if(e.target.data == "true"){
				photoPermOn = true;
				getAlbums();
			}else{
				ForticomAPI.showPermissions("PHOTO CONTENT");		
			}
		}
		
		private function getAlbums():void{
			var request:URLRequest = new URLRequest(GameApplication.app.config.api_server + "api/photos/getAlbums");
			var variables:URLVariables = new URLVariables();
			variables["application_key"] = GameApplication.app.config.application_key;
			variables["session_key"] = GameApplication.app.config.session_key;
			var sigStr:String = "application_key=" + GameApplication.app.config.application_key + "session_key=" + GameApplication.app.config.session_key + GameApplication.app.config.session_secret_key;
			variables["sig"] = MD5.encrypt(sigStr);
			
			request.data = variables;
			request.method = URLRequestMethod.POST;
			
			var _loader:URLLoader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onGetAlbums);
			_loader.load(request);
		}
		
		private function onGetAlbums(e:Event):void{
			var answer:Object = JSON.decode(e.target.data);
			var albums:Array = answer["albums"];
			if(albums){
				var mouseAlbumID:String;
				var mouseAlbumFind:Boolean;
				var mouseAlbumTitle:String = "Реальные гонки";
				
				for(var i:int; i < albums.length; i++){
					var atitle:String = albums[i]["title"];
					if(atitle && atitle.indexOf(mouseAlbumTitle) >= 0){
						mouseAlbumID = albums[i]["aid"];
						mouseAlbumFind = true;
					}
				}
				if(mouseAlbumFind){
					getUploadServer(mouseAlbumID);
				}else{
					var request:URLRequest = new URLRequest(GameApplication.app.config.api_server + "api/photos/createAlbum");
					var variables:URLVariables = new URLVariables();				
					variables["application_key"] = GameApplication.app.config.application_key;
					variables["title"] = mouseAlbumTitle;
					variables["type"] = "public";
					variables["session_key"] = GameApplication.app.config.session_key;
					var sigStr:String = "application_key=" + GameApplication.app.config.application_key + "session_key=" + GameApplication.app.config.session_key + "title=" + mouseAlbumTitle + "type=public" + GameApplication.app.config.session_secret_key;
					variables["sig"] = MD5.encrypt(sigStr);
					
					request.data = variables;
					request.method = URLRequestMethod.POST;
					
					var _loader:URLLoader = new URLLoader();
					_loader.addEventListener(Event.COMPLETE, onCreateAlbum);
					_loader.load(request);
				}
			}
		}
		
		private function onCreateAlbum(e:Event):void{
			var answer:String = e.target.data;
			if(answer.indexOf("error") == -1){
				getUploadServer(answer.substr(1, answer.length - 2));				
			}
		}
		
		private function getUploadServer(mouseAlbumID:String):void{
			var request:URLRequest = new URLRequest(GameApplication.app.config.api_server + "api/photosV2/getUploadUrl");
			var variables:URLVariables = new URLVariables();				
			variables["application_key"] = GameApplication.app.config.application_key;
			variables["aid"] = mouseAlbumID;
			variables["session_key"] = GameApplication.app.config.session_key;
			var sigStr:String = "aid=" + mouseAlbumID + "application_key=" + GameApplication.app.config.application_key + "session_key=" + GameApplication.app.config.session_key + GameApplication.app.config.session_secret_key;
			variables["sig"] = MD5.encrypt(sigStr);
			
			request.data = variables;
			request.method = URLRequestMethod.POST;
			
			var _loader:URLLoader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onGetUploadServer);
			_loader.load(request);
		}
		
		private function onGetUploadServer(e:Event):void{
			var answerStr:String = e.target.data;
			var answer:Object = JSON.decode(answerStr);
			if(answerStr.indexOf("error") == -1){
				var _mpLoader:MultipartURLLoader = new MultipartURLLoader(onUploadPhoto);
				_mpLoader.addFile((new PNGEncoder()).encode(postBitmapData), "photo_" + (new Date().time) +".png", "photo");
				
				try {
					_mpLoader.load(answer["upload_url"]);
				} catch (e:Error) {
					trace(e);
				}
			}
		}
		
		private function onUploadPhoto(e:Event):void{
			var answerStr:String = e.target.data;
			if(answerStr.indexOf("error") == -1){
				var answer:Object = JSON.decode(e.target.data);
				var photoId:String = "";
				var token:String = "";
				for(var key:String in answer["photos"]){
					photoId = key;
					token = answer["photos"][key]["token"];
				}
				
				var request:URLRequest = new URLRequest(GameApplication.app.config.api_server + "api/photosV2/commit");
				var variables:URLVariables = new URLVariables();				
				variables["application_key"] = GameApplication.app.config.application_key;
				variables["photo_id"] = photoId;
				variables["token"] = token;
				variables["session_key"] = GameApplication.app.config.session_key;
				var sigStr:String = "application_key=" + GameApplication.app.config.application_key + "photo_id=" + photoId + "session_key=" + GameApplication.app.config.session_key + "token=" + token + GameApplication.app.config.session_secret_key;
				variables["sig"] = MD5.encrypt(sigStr);
				
				request.data = variables;
				request.method = URLRequestMethod.POST;
				
				var _loader:URLLoader = new URLLoader();
				_loader.addEventListener(Event.COMPLETE, onSavePhoto);
				_loader.load(request);
			}
		}
		
		private function onSavePhoto(e:Event):void{
			if(isSceneScreen){
				GameApplication.app.callsmanager.call(ProtocolValues.SOCIAL_POST, null);
			}
			GameApplication.app.popuper.showInfoPopUp("Снимок успешно добавлен в альбом.");
		}
		
		override public function init():void{	
			GameApplication.app.gameContainer.promotionMode = true;
		}
	
		private function checkAddedAndConnect():void{			
			ForticomAPI.removeEventListener(ForticomAPI.CONNECTED, apiIsReady);			
			
			if(_connectInterval != -1){
				clearInterval(_connectInterval);
				_connectInterval = -1;
			}
			GameApplication.app.connect();
			
//			_sid = setInterval(updateParams, 3000);											//нельзя получить ссылку, рабочую для всех пользователей
		}
		
		override public function inviteFriends():void{
			ForticomAPI.showInvite();
		}
		override public function buyMoney(money:uint = 0, gamemoney:uint = 0):void{			
			var buyName:String = "реалы";
			if(money == 25){
				buyName = 200 + " реалов";
			}else if(money == 80){
				buyName = 700 + " реалов";
			}else if(money == 120){
				buyName = 1300 + " реалов";
			}else if(money == 400){
				buyName = 4500 + " реалов";
			}else if(money == 1000){
				buyName = 12000 + " реалов";
			}
			
			//если необходимо закодировать несколько значений
			var attributesObj:Object = new Object();
			attributesObj[ProtocolKeys.USER_ID] = addMoneyUserID;
			var attributes:String = JSON.encode(attributesObj);
			
			ForticomAPI.showPayment(buyName, 'Все платные действия в игре, в том числе покупки, оплачиваются игровыми евро и реалами.', String(money), money, null, String(addMoneyUserID), 'OK', 'false');
			
			GameApplication.app.popuper.hidePopUp();
		}
		override public function showBuyMoneyPopUp():void{
			GameApplication.app.popuper.show(new PopUpBuyMoneyOD());
		}
		override public function getFriendsBonus():void{
			var count:uint = int(GameApplication.app.so.data["frendsinvited"]);
			if(count < 10)
			{
				GameApplication.app.callsmanager.call(ProtocolValues.GET_FRIENDS_BONUS, onGetFriendsBonus, GameApplication.app.config.session_secret_key, GameApplication.app.config.mode, GameApplication.app.config.app_id, GameApplication.app.config.session_key);
			}
		}
		private function onGetFriendsBonus(result:Object):void{	
			var delta:int = result[delta];
			var countfriends:int = result[countfriends];
			GameApplication.app.so.data["frendsinvited"] = int(countfriends);
			GameApplication.app.so.flush();
			
			if(delta > 0){
				GameApplication.app.popuper.show(new PopUpFriendsBonus(delta));
			}
		}
		private function onGetFriendsBonusError(error:Object):void{			
		}
		
		override public function getMouseAppUrl():String{
			return "http://www.odnoklassniki.ru/game/mouserun";
		}
		
		override public function getHuntersAppUrl():String{
			return "http://www.odnoklassniki.ru/game/hunters";
		}
	}
}