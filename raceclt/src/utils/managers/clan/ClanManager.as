package utils.managers.clan
{
	import application.GameApplication;
	import utils.user.User;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.Responder;
	
	import mx.collections.ArrayCollection;
	
	import utils.clan.ClanError;
	import utils.game.GameManager;
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;
	import utils.shop.BuyResultCode;
	import utils.user.ClanUserInfo;
	import utils.user.ClanUserRole;
	import utils.user.UserClanInfo;
	
	public class ClanManager extends EventDispatcher
	{
		private var _currentGetClanFunction:Function;
		private var _currentGetClanInfoFunction:Function;
		
		public function ClanManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function getClansInfo(f:Function):void{
			_currentGetClanFunction = f;
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_GET_CLANS_INFO, ongetClansInfo);			
		}
		private function ongetClansInfo(obj:Object):void{
			var clans:Array = obj[ProtocolKeys.CLANS];
			_currentGetClanFunction(clans);
			_currentGetClanFunction = null;
		}		
		private function ongetClansInfoError(err:Object):void{			
		}
		
		public function getClanAllInfo(f:Function, clanid:int):void{			
			_currentGetClanInfoFunction = f;
			GameApplication.app.models.currentClan.users = new ArrayCollection();
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_GET_CLAN_ALL_INFO, ongetClanAllInfo, clanid);			
		}
		private function ongetClanAllInfo(claninfo:Object):void{			
			_currentGetClanInfoFunction(claninfo);
			_currentGetClanInfoFunction = null;
		}		
		private function ongetClanAllInfoError(err:Object):void{			
		}
		
		public function createClan(title:String):void{
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_CREATE_CLAN, oncreateClan, title);
		}
		private function oncreateClan(result:Object):void{
			var error:int = result[ProtocolKeys.ERROR];
			if(error == ClanError.OK){
				GameApplication.app.userinfomanager.myuser.moneyReal = int(result[ProtocolKeys.MONEY]);
				GameApplication.app.userinfomanager.myuser.claninfo.clantitle = result[ProtocolKeys.CLAN_TITLE];
				GameApplication.app.userinfomanager.myuser.claninfo.clanid = int(result[ProtocolKeys.CLAN_ID]);
				GameApplication.app.userinfomanager.myuser.claninfo.clanrole = ClanUserRole.OWNER;
				
				GameApplication.app.navigator.goClansRoom();
				GameApplication.app.popuper.showInfoPopUp("Поздравляем! Ваш клуб успешно создан!");
			}else if(error == ClanError.LOWLEVEL){
				GameApplication.app.popuper.showInfoPopUp("У вас низкий уровень. Клуб можно создавать только с 10 уровня.");
			}else if(error == ClanError.NOT_ENOUGHT_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У вас недостаточно денег для покупки клуба.");
			}else if(error == ClanError.CLAN_EXIST){
				GameApplication.app.popuper.showInfoPopUp("Клуб с таким названием уже существует. Выберите уникальное название клуба.");
			}else if(error == ClanError.INOTHERCLAN){
				GameApplication.app.popuper.showInfoPopUp("Вы уже состоите в другом клубе. Вам нужно покинуть клуб для создания нового.");
			}else if(error == ClanError.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Невозможно создать клуб.");
			}else {
				GameApplication.app.popuper.showInfoPopUp("Невозможно создать клуб.");
			}
		}		
		private function oncreateClanError(err:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно создать клуб.");
		}
		
		public function inviteuser(user:User):void {
			if (user.level >= 5) {
				GameApplication.app.callsmanager.call(ProtocolValues.CLAN_INVITE_USER, onInvite, user.id);
			}else {
				GameApplication.app.popuper.showInfoPopUp("В клуб можно приглашать только игроков, достигших 5 уровня.");
			}			
		}
		private function onInvite(obj:Object):void{
			var result:int = obj[ProtocolKeys.VALUE];
			if(result == ClanError.OK){
				GameApplication.app.popuper.showInfoPopUp("Приглашение доставлено.");
			}else if(result == ClanError.YOUNOTOWNER){
				GameApplication.app.popuper.showInfoPopUp("Вы не являетесь владельцем клуба и не можете приглашать других игроков.");
			}else if(result == ClanError.USEROFFLINE){
				GameApplication.app.popuper.showInfoPopUp("Пользователь вышел из игры.");
			}else if(result == ClanError.INOTHERCLAN){
				GameApplication.app.popuper.showInfoPopUp("Пользователь уже состоит в клубе.");
			}else if(result == ClanError.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Невозможно пригласить пользователя. Максимальное количество участников: 200.");
			}else{
				GameApplication.app.popuper.showInfoPopUp("Невозможно пригласить пользователя. Максимальное количество участников: 200.");
			}
		}		
		private function onInviteError(err:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно пригласить пользователя.");
		}
		
		public function inviteAccept():void{
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_INVITE_ACCEPT, onAccept);
		}
		private function onAccept(obj:Object):void{
			var clanid:int = obj[ProtocolKeys.VALUE];
			if(clanid > 0){
				GameApplication.app.userinfomanager.myuser.claninfo.clanid = clanid;
				GameApplication.app.userinfomanager.myuser.claninfo.clanrole = ClanUserRole.ROLE1;
			}else{
				GameApplication.app.popuper.showInfoPopUp("Невозможно вступить в клуб");
			}
		}		
		private function onAcceptError(err:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно вступить в клуб");
		}
		
		public function kick(userID:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_KICK, onKick, String(userID));
		}
		private function onKick(obj:Object):void{
			var error:int = obj[ProtocolKeys.ERROR];
			var userid:int = obj[ProtocolKeys.USER_ID];
			var role:int = obj[ProtocolKeys.ROLE];
			if(error == ClanError.OK){
				var user:UserClanInfo;
				for(var i:int; i < GameApplication.app.models.currentClan.users.length; i++){
					user = GameApplication.app.models.currentClan.users.getItemAt(i) as UserClanInfo;
					if(user && user.id == userid){
						if(role > 0){
							user.role = role;
						}else{
							GameApplication.app.models.currentClan.users.removeItemAt(i);							
						}
						return;
					}						
				}
			}else if(error == ClanError.YOUNOTOWNER){
				GameApplication.app.popuper.showInfoPopUp("Вы не являетесь владельцем клуба, в котором состоит этот пользователь.");
			}else if(error == ClanError.INOTHERCLAN){
				GameApplication.app.popuper.showInfoPopUp("Вы не являетесь владельцем клуба, в котором состоит этот пользователь.");
			}else if(error == ClanError.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Невозможно выгнать пользователя");
			}else {
				GameApplication.app.popuper.showInfoPopUp("Невозможно выгнать пользователя");
			}
		}		
		private function onKickError(err:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно выгнать пользователя");
		}
		
		public function setrole(userID:int, role:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_SET_ROLE, onKick, String(userID), role);
		}
		private function onSetRole(error:int):void{
			if(error == ClanError.OK){
			}else if(error == ClanError.NOROLE){
				GameApplication.app.popuper.showInfoPopUp("Попытка установить несуществующую роль пользователю.");
			}else if(error == ClanError.YOUNOTOWNER){
				GameApplication.app.popuper.showInfoPopUp("Вы не являетесь владельцем клуба, в котором состоит этот пользователь.");
			}else if(error == ClanError.INOTHERCLAN){
				GameApplication.app.popuper.showInfoPopUp("Вы не являетесь владельцем клуба, в котором состоит этот пользователь.");
			}else if(error == ClanError.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Невозможно установить роль пользователя.");
			}else {
				GameApplication.app.popuper.showInfoPopUp("Невозможно установить роль пользователя.");
			}
		}		
		private function onSetRoleError(err:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно установить роль пользователя.");
		}
		
		public function leave():void{
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_LEAVE, onLeave);
		}
		private function onLeave(obj:Object):void{
			var error:int = obj[ProtocolKeys.VALUE];
			if(error == ClanError.OK){
				GameApplication.app.navigator.goClansRoom();
				GameApplication.app.userinfomanager.myuser.claninfo.clanid = 0;
				GameApplication.app.userinfomanager.myuser.claninfo.clandeposite = 0;
				GameApplication.app.userinfomanager.myuser.claninfo.clandepositm = 0;
				GameApplication.app.userinfomanager.myuser.claninfo.clanrole = ClanUserRole.NO_ROLE;
			}else {
				GameApplication.app.popuper.showInfoPopUp("Невозможно покинуть клуб.");
			}
		}		
		private function onLeaveError(err:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно покинуть клуб.");
		}
		
		public function reset():void{
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_RESET, onReset);
		}
		private function onReset(obj:Object):void{
			var error:int = obj[ProtocolKeys.VALUE];
			if(error == ClanError.OK){
				GameApplication.app.navigator.goClanRoom(GameApplication.app.userinfomanager.myuser.claninfo.clanid);
			}else if(error == ClanError.YOUNOTOWNER) {
				GameApplication.app.popuper.showInfoPopUp("Вы не являетесь владельцем клуба.");
			}else {
				GameApplication.app.popuper.showInfoPopUp("Невозможно сбросить показатели.");
			}
		}		
		private function onResetError(err:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно сбросить показатели.");
		}
		
		public function destroy():void{
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_DESTROY, onDestroy);
		}
		private function onDestroy(obj:Object):void{
			var error:int = obj[ProtocolKeys.VALUE];
			if(error == ClanError.OK){
				GameApplication.app.popuper.showInfoPopUp("Ваш клуб удален.");
				GameApplication.app.navigator.goClansRoom();
				
				GameApplication.app.userinfomanager.myuser.claninfo.clanid = 0;
				GameApplication.app.userinfomanager.myuser.claninfo.clandeposite = 0;
				GameApplication.app.userinfomanager.myuser.claninfo.clandepositm = 0;
				GameApplication.app.userinfomanager.myuser.claninfo.clanrole = ClanUserRole.NO_ROLE;
			}else if(error == ClanError.YOUNOTOWNER) {
				GameApplication.app.popuper.showInfoPopUp("Вы не являетесь владельцем клуба.");
			}else {
				GameApplication.app.popuper.showInfoPopUp("Невозможно распустить клуб.");
			}
		}		
		private function onDestroyError(err:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно распустить клуб.");
		}
		
		public function getMoney():void{
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_GET_MONEY, ongetMoney);
		}
		private function ongetMoney(obj:Object):void{
			var error:int = obj[ProtocolKeys.VALUE];
			if(error == ClanError.OK){
				GameApplication.app.navigator.goClanRoom(GameApplication.app.userinfomanager.myuser.claninfo.clanid);
			}else if(error == ClanError.INOTHERCLAN) {
				GameApplication.app.popuper.showInfoPopUp("Вы пытаетесь забрать зарплату не из своего клуба.");
			}else if(error == ClanError.TIMEERROR) {
				GameApplication.app.popuper.showInfoPopUp("Можете забрать зарплату чуть позже.");
			}else {
				GameApplication.app.popuper.showInfoPopUp("Невозможно забрать зарплату.");
			}
		}		
		private function ongetMoneyError(err:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно забрать зарплату.");
		}
		
		public function buyexperience(exp:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.CLAN_BUY_EXPERIENCE, onBuyexperience, exp);
		}
		
		private function onBuyexperience(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				GameApplication.app.navigator.goClansRoom();
				GameApplication.app.popuper.showInfoPopUp("Поздравляем с удачной покупкой опыта!");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 756. Сообщите об ошибке разработчикам.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 791. Сообщите об ошибке разработчикам.");
			}
		}
		private function onBuyexperienceError(result:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке опыта.");
		}
	}
}