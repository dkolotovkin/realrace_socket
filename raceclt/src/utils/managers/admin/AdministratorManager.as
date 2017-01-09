package utils.managers.admin
{
	import application.GameApplication;
	import application.components.popup.PopUp;
	import application.components.popup.userinfo.PopUpUserInfo;
	
	import flash.net.Responder;
	
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;
	import utils.user.User;

	public class AdministratorManager
	{
		public var lastUserID:uint;
		
		public function AdministratorManager(){
		}
		
		public function updateAllUsersParams():void{
			GameApplication.app.callsmanager.call(ProtocolValues.ADMIN_UPDATE_ALL_USERS_PARAMS, onUpdateAllUsersParams);
		}
		private function onUpdateAllUsersParams(obj:Object):void{
			var result:int = obj[ProtocolKeys.VALUE];
			if(result == 1){				
				GameApplication.app.popuper.showInfoPopUp("Действие выполнено!");
			}else if(result == 0){
				GameApplication.app.popuper.showInfoPopUp("Невозможно выполнить действие. Вожможно у вас нет прав доступа.");
			}
		}
		
		public function setModerator(userID:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.ADMIN_SET_MODERATOR, onSetParam, userID);
		}
		
		public function deleteModerator(userID:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.ADMIN_DELETE_MODERATOR, onSetParam, userID);
		}
		
		public function deleteUser(userID:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.ADMIN_DELETE_USER, onSetParam, userID);
		}
		
		public function setParam(userID:int, param:int, value:*):void{
			GameApplication.app.callsmanager.call(ProtocolValues.ADMIN_SET_PARAM, onSetParam, userID, param, value);
		}
		public function setNameParam(userID:int, param:int, value:*):void{
			GameApplication.app.callsmanager.call(ProtocolValues.ADMIN_SET_NAME_PARAM, onSetParam, userID, param, value);
		}
		
		private function onSetParam(obj:Object):void{
			var result:int = obj[ProtocolKeys.VALUE];
			if(result == 1){				
				GameApplication.app.popuper.showInfoPopUp("Действие выполнено!");
			}else if(result == 0){
				GameApplication.app.popuper.showInfoPopUp("Невозможно выполнить действие. Вожможно у вас нет прав доступа.");
			}
		}
		
		public function showInfo(userID:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.ADMIN_SHOW_INFO, onShowInfo, userID);
		}
		
		private function onShowInfo(u:Object):void{
			if(u != null){
				var popUp:PopUp;
				popUp = new PopUpUserInfo(User.createFromObject(u));
				GameApplication.app.popuper.show(popUp);
			}else{
				GameApplication.app.popuper.showInfoPopUp("Невозможно выполнить действие. Вожможно у вас нет прав доступа.");
			}
		}
		
		public function sendNotification(msg:String):void{
			if(msg && msg.length >= 5){
				GameApplication.app.callsmanager.call(ProtocolValues.ADMIN_SEND_NOTIFICATION, onSendNotification, msg);
			}else{
				GameApplication.app.popuper.showInfoPopUp("Слишком короткий текст сообщения.");
			}
		}
		
		private function onSendNotification(obj:Object):void{
			var result:int = obj[ProtocolKeys.VALUE];
			if(result == 1){				
				GameApplication.app.popuper.showInfoPopUp("Действие выполнено!");
			}else if(result == 0){
				GameApplication.app.popuper.showInfoPopUp("Невозможно выполнить действие. Вожможно у вас нет прав доступа.");
			}
		}
	}
}