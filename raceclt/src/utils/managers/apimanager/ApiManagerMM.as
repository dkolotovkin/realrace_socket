package utils.managers.apimanager
{
	import application.GameApplication;
	import application.components.popup.buymoney.mm.PopUpBuyMoneyMM;
	import application.components.popup.friendsBonus.PopUpFriendsBonus;
	import application.components.preloader.PreLoaderCircle;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.controls.Alert;
	import mx.graphics.codec.PNGEncoder;
	
	import utils.mailru.MailruCall;
	import utils.mailru.MailruCallEvent;
	import utils.multypart.MultipartURLLoader;
	import utils.protocol.ProtocolValues;
	import utils.user.Sex;

	public class ApiManagerMM extends ApiManager
	{		
		private var uid:String; 
		private var _preLoader:PreLoaderCircle = new PreLoaderCircle();	
		private var _connectInterval:int = -1;
		private var uploadUrl:String;
		private var uploadAlbumId:String;
		private var _postInterval:int = -1;
		
		public function ApiManagerMM()
		{			
			super();
			try{
				MailruCall.init('flash-app', GameApplication.app.config.privatekeymm);			
				MailruCall.addEventListener(Event.COMPLETE, mailruReadyHandler);
				MailruCall.addEventListener("common.upload", onUpload);
			}catch(e:*){
				//Alert.show("Error " + e);
			}
			
			autukey = GameApplication.app.config.authentication_key;
			appid = String(GameApplication.app.config.app_id);
			vid = GameApplication.app.parameters["vid"];
			idsocail = "mm" + vid;
			
			if(_connectInterval != -1){
				clearInterval(_connectInterval);
				_connectInterval = -1;
			}
			_connectInterval = setInterval(checkAddedAndConnect, 3000);
		}
		
		override public function init():void{
			GameApplication.app.gameContainer.promotionMode = true;
		}		
		
		private function mailruReadyHandler(event : Event) : void {
			checkAddedAndConnect();
			MailruCall.addEventListener(MailruCallEvent.ALBUM_CREATED, onAlbumCreated);
		}	
		
		private function checkAddedAndConnect():void{			
			MailruCall.removeEventListener(Event.COMPLETE, mailruReadyHandler);
			if(_connectInterval != -1){
				clearInterval(_connectInterval);
				_connectInterval = -1;
			}
			if (GameApplication.app.config.is_app_user != true) {
				//если не установлено - вызываем диалог установки с разрешением на размещение виджета
				try{
					MailruCall.exec('mailru.app.users.requireInstallation', null, []);
					_preLoader.text = "Необходимо установить приложение...";
					GameApplication.app.addElement(_preLoader);
				}catch(e:*){
					GameApplication.app.connect();
				}
			}else{
				GameApplication.app.connect();
				uid = MailruCall.exec('mailru.session.vid');	
				try{
					MailruCall.exec('mailru.common.users.getInfo', getMyUserInfo, String(uid));
				}catch(e:*){					
				}
			}
		}
	
		private function getMyUserInfo ( users : Object ) : void {
			for each(var u:* in users){
				title = u["last_name"] + " " + u["first_name"];
				url = u["link"];
				if (String(u[sex]) == String(0)){
					sex = String(Sex.MALE);
				}else{
					sex = String(Sex.FEMALE);
				}
			}
			//idsocail = "mm" + uid;
			//GameApplication.app.connect();
			
			_sid = setInterval(updateParams, 3000);
		}
		
		override public function post(ptitle:String, pcontent:String, bitmapData:BitmapData, isSS:Boolean = false):void{
			isSceneScreen = isSS;
			postTitle = ptitle;
			postContent = pcontent;
			postBitmapData = bitmapData;
			
			getAlbums();
		}
		
		private function getAlbums():void{
			MailruCall.exec('mailru.common.photos.getAlbums', onGetAlbums, []);
		}
		
		private function onGetAlbums(albums:Array):void{
			var mouseAlbumID:String;
			var mouseAlbumFind:Boolean;
			var mouseAlbumTitle:String = "Реальные гонки";
			
			for(var i:int = 0; i < albums.length; i++){
				var atitle:String = albums[i]["title"];
				if(atitle && atitle.indexOf(mouseAlbumTitle) >= 0){
					mouseAlbumID = albums[i]["aid"];
					mouseAlbumFind = true;
				}		
			}
			
			if(mouseAlbumFind){
				uploadAlbumId = mouseAlbumID;
				uploadPhoto();
			}else{
				var obj:Object = new Object();
				obj["name"] = mouseAlbumTitle;
				MailruCall.exec('mailru.common.photos.createAlbum', null, obj);				
			}
		}
		
		private function onAlbumCreated(e:Event):void{
			if(_postInterval != -1){
				clearInterval(_postInterval);
				_postInterval = -1;
			}
			_postInterval = setInterval(onPostInterval, 3000);			
		}
		
		private function onPostInterval():void{
			if(_postInterval != -1){
				clearInterval(_postInterval);
				_postInterval = -1;
			}
			getAlbums();
		}
		
		private function uploadPhoto():void{
			var fileName:String = "photo_" + int(Math.random() * 100000) + "_" + (new Date()).getTime() + ".png";
			var _mpLoader:MultipartURLLoader = new MultipartURLLoader(onLoadFile);
			_mpLoader.addVariable("fileName", fileName);
			_mpLoader.addFile((new PNGEncoder()).encode(postBitmapData), fileName, "file");			
			try{
				var uploadUrl:String = "http://" + GameApplication.app.config.serverAddress + "/upload.php";
				_mpLoader.load(uploadUrl);
			}catch(e:Error){
				trace(e);							
			}
		}
		
		private function onLoadFile(e:Event):void{
			var answerStr:String = e.target.data;
			if(answerStr.indexOf("ok") == 0){
				var answerArr:Array = answerStr.split(":");
				uploadUrl = "http://" + GameApplication.app.config.serverAddress + "/images/upload/" + answerArr[1];				
				var obj:Object = new Object();
				obj["url"] = uploadUrl;
				obj["aid"] = uploadAlbumId;
				obj["description"] = postContent;
				MailruCall.exec('mailru.common.photos.upload', null, obj);
			}
		}
		
		private function onUpload(e:Event):void{
			if(isSceneScreen && e["data"] && e["data"]["status"] == "uploadSuccess"){
				GameApplication.app.callsmanager.call(ProtocolValues.SOCIAL_POST, null);
			}
		}
		
		override public function inviteFriends():void{
			MailruCall.exec('mailru.app.friends.invite', null);
		}
		
		override public function buyMoney(money:uint = 0, gamemoney:uint = 0):void{						
			var params:Object = new Object();
			params["service_id"] = addMoneyUserID;
			params["service_name"] = "Покупка золотых монет";
			params["mailiki_price"] = money;
			
			MailruCall.exec('mailru.app.payments.showDialog', null, params);
			
			GameApplication.app.popuper.hidePopUp();
		}	
		
		override public function showBuyMoneyPopUp():void{			
			GameApplication.app.popuper.show(new PopUpBuyMoneyMM());
		}
		
		override public function getFriendsBonus():void{
			var count:uint = int(GameApplication.app.so.data["frendsinvited"]);
			if(count <= 10)
			{
				GameApplication.app.callsmanager.call(ProtocolValues.GET_FRIENDS_BONUS, onGetFriendsBonus, GameApplication.app.config.vid, GameApplication.app.config.mode, GameApplication.app.config.app_id, GameApplication.app.config.session_key);
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
			return "http://my.mail.ru/apps/553236";
		}
		
		override public function getHuntersAppUrl():String{
			return "http://my.mail.ru/apps/644633";
		}
	}
}