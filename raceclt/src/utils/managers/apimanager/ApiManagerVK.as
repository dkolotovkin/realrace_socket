package utils.managers.apimanager
{
	import application.GameApplication;
	import application.components.popup.buymoney.vk.PopUpBuyMoneyVK;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.graphics.codec.PNGEncoder;
	
	import utils.multypart.MultipartURLLoader;
	import utils.protocol.ProtocolValues;
	import utils.vk.APIConnection;
	import utils.vk.api.serialization.json.JSON;
	
	public class ApiManagerVK extends ApiManager
	{
		public var vkapi:APIConnection;
		
		public function ApiManagerVK()
		{
			super();
			autukey = GameApplication.app.config.auth_key;
			vid = GameApplication.app.config.viewer_id;
			appid = String(GameApplication.app.config.api_id);
			idsocail = "vk" + vid;
			url = "http://vk.com/id" + vid;
			
			//ExternalInterface - для приложения типа iframe, vkapi - для приложения типа flash
			ExternalInterface.addCallback("onGetUploadServer", onGetUploadServer);
			ExternalInterface.addCallback("onSavePhoto", onSavePhoto);
			ExternalInterface.addCallback("onPostPhoto", onPostPhoto);

//			vkapi = new APIConnection(GameApplication.app.stage.loaderInfo.parameters as Object);
		}
		
		override public function post(ptitle:String, pcontent:String, bitmapData:BitmapData, isSS:Boolean = false):void{
			isSceneScreen = isSS;
			postTitle = ptitle;
			postContent = pcontent;
			postBitmapData = bitmapData;
			ExternalInterface.call("getWallUploadServer");
//			vkapi.api('photos.getWallUploadServer', null, onGetUploadServer, onApiError);
		}
		
		private function onGetUploadServer(data: Object): void {
			var _mpLoader:MultipartURLLoader = new MultipartURLLoader(onUploadPhoto);
			_mpLoader.addFile((new PNGEncoder()).encode(postBitmapData), "photo_" + (new Date().time) +".png", "photo");
			
			try{
				var uploadUrl:String = data["response"]["upload_url"];
				_mpLoader.load(uploadUrl);
			}catch (e:Error){
			}
		}
		
		private function onUploadPhoto(e:Event):void{
			var answer:Object = JSON.decode(e.target.data);
			var server:String = answer["server"];
			var photo:String = answer["photo"];
			var hash:String = answer["hash"];
			ExternalInterface.call("saveWallPhoto", answer["server"], answer["photo"], answer["hash"]);
//			vkapi.api('photos.saveWallPhoto', {server: answer["server"], photo: answer["photo"], hash: answer["hash"]}, onSavePhoto, onApiError);
		}
		
		private function onSavePhoto(data: *):void{
			var str:String = "";
			ExternalInterface.call("post", postContent, data["response"][0]["id"]);
//			vkapi.api('wall.post', {message: postContent, attachments: data[0]["id"]}, onPostPhoto, onApiError);
		}
		
		private function onPostPhoto(data: Object): void{
			if(isSceneScreen){
				GameApplication.app.callsmanager.call(ProtocolValues.SOCIAL_POST, null);
			}
		}
		
		override public function init():void{
			if (_sid != -1){
				clearInterval(_sid);
				_sid = -1;
			}
			_sid = setInterval(updateParams, 3000);
			
			GameApplication.app.connect();
			GameApplication.app.gameContainer.promotionMode = true;
		}
		
		override public function inviteFriends():void{
			ExternalInterface.call("showInviteBox");
//			vkapi.callMethod("showInviteBox");
		}
		override public function buyMoney(money:uint = 0, gamemoney:uint = 0):void{
			ExternalInterface.call("showOrderBox", money);
			GameApplication.app.popuper.hidePopUp();
//			vkapi.callMethod("showOrderBox", {type: "item", item: money});
		}
		
		override public function showBuyMoneyPopUp():void{
			GameApplication.app.popuper.show(new PopUpBuyMoneyVK());
		}
		
		override public function getFriendsBonus():void{			
		}
		
		override public function getMouseAppUrl():String{
			return "http://vk.com/mouserunru";
		}
		
		override public function getHuntersAppUrl():String{
			return "http://vk.com/app2473027";
		}
	}
}