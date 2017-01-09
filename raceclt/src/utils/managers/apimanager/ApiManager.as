package utils.managers.apimanager
{
	import application.GameApplication;
	import application.components.popup.buymoney.site.PopUpBuyMoneySite;
	
	import flash.display.BitmapData;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.controls.Alert;
	
	import utils.protocol.ProtocolValues;
	import utils.user.Sex;

	public class ApiManager
	{
		public var idsocail:String;
		public var title:String;
		public var sex:String;
		public var autukey:String;
		public var vid:String;
		public var appid:String;
		public var url:String = null;
		public var photoPermOn:Boolean = false;
		public var addMoneyUserID:int;
		
		public var postTitle:String;
		public var postContent:String;
		public var postBitmapData:BitmapData;
		public var isSceneScreen:Boolean;
		
		protected var _sid:int = -1;
		
		public function ApiManager(){
		}
		
		public function init():void{
//			idsocail = "vk34507451";
			idsocail = "vk77838768954555";
//			idsocail = "vk778387689545563";
			title = "Дмитрий";
			url = "www.google.ru";
			sex = String(Sex.MALE);
			
			if (_sid != -1){
				clearInterval(_sid);
				_sid = -1;
			}
			_sid = setInterval(updateParams, 3000);
			
			GameApplication.app.connect();
			
			GameApplication.app.gameContainer.promotionMode = true;
			
//			GameApplication.app.serversmanager.checkServers();			
//			GameApplication.app.addElement(new StartSitePage());
		}
		
		public function post(title:String, content:String, bitmapData:BitmapData, isSceneScreen:Boolean = false):void{			
		}
		
		public function inviteFriends():void{
//			GameApplication.app.popuper.show(new PopUpFriendBonus());
		}
		
		public function showBuyMoneyPopUp():void{
//			var popup:PopUpBuyMoney = new PopUpBuyMoney("Покупка монет тестовая");			
//			GameApplication.app.popuper.show(popup);
//			if(GameApplication.app.config.playmode != 1){
//				GameApplication.app.popuper.show(new PopUpBuyMoneySite());
//			}
			GameApplication.app.popuper.show(new PopUpBuyMoneySite());
		}
		public function buyMoney(money:uint = 0, gamemoney:uint = 0):void{
		}
		
		public function getFriendsBonus():void{					
		}
		
		public function updateParams():void{
			if(_sid != -1){
				clearInterval(_sid);
				_sid = -1;
			}
			
			var updatedUrl:Boolean = Boolean(GameApplication.app.so.data["updatedUrl"]);
			if(!updatedUrl && GameApplication.app.userinfomanager && GameApplication.app.userinfomanager.myuser != null){
				if(url != null && 
					(
						GameApplication.app.userinfomanager.myuser.url == null || 
						(GameApplication.app.userinfomanager.myuser.url && GameApplication.app.userinfomanager.myuser.url.length == 0)
					)
				){
					GameApplication.app.so.data["updatedUrl"] = true;
					GameApplication.app.so.flush();
					GameApplication.app.callsmanager.call(ProtocolValues.UPDATE_PARAMS, null, url);
				}
			}
		}
		
		public function getMouseAppUrl():String{
			return "";
		}
		
		public function getHuntersAppUrl():String{
			return "";
		}
	}
}