package utils.managers.persinfo
{
	import application.GameApplication;
	import application.components.popup.PopUp;
	import application.components.popup.changeInfo.PopUpChangeInfo;
	import application.components.popup.dailyBonus.PopUpDailyBonus;
	import application.components.popup.help.tutorial.second.PopUpTutorialSecond;
	import application.components.popup.help.tutorial.third.PopUpTutorialThird;
	import application.components.popup.pay.PopUpPay;
	import application.components.popup.userinfo.PopUpUserInfo;
	
	import flash.events.EventDispatcher;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import utils.changeinfo.ChangeInfoParams;
	import utils.chat.message.MessageType;
	import utils.game.betroominfo.BetResult;
	import utils.managers.ban.BanType;
	import utils.models.MailMessageModel;
	import utils.models.car.CarModel;
	import utils.models.quests.Quest;
	import utils.models.quests.QuestStatus;
	import utils.parser.Parser;
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;
	import utils.shop.BuyResultCode;
	import utils.user.ClanUserInfo;
	import utils.user.User;
	import utils.user.change.ChangeResult;

	public class UserInfoManager extends EventDispatcher
	{
		public var users:Object = new Object();
		[Bindable]
		public var myuser:User;
		
		public var popularparts:Array = new Array(); 
		public var populartitles:Array = new Array();
		public var popularicons:Array = new Array(IconPopular1, IconPopular2, IconPopular3, IconPopular4, IconPopular5, IconPopular6, IconPopular7, IconPopular8, IconPopular9, IconPopular10);

		private var _getPostsCallBack:Function;
		private var _getUserInfoCallBack:Function;
		private var _checkLuckCallBack:Function;
		
		private var _timeToUpdate:int = 0;
		private var _vipInterval:int = -1;
		
		public var cash:Object = new Object();
		
		private var getDailyBonusCallBack:Function;
		
		public function UserInfoManager()
		{	
			myuser = new User();
		}
		
		public function getDailyBonus(callBack:Function = null):void{
			getDailyBonusCallBack = callBack;
			
			GameApplication.app.callsmanager.call(ProtocolValues.GET_DAILY_BONUS, onGetDailyBonus);
		}
		
		private function onGetDailyBonus(obj:Object):void{
			if(getDailyBonusCallBack != null){
				getDailyBonusCallBack();
				getDailyBonusCallBack = null;
			}
			
			var days:int = obj[ProtocolKeys.VALUE];
			if(days > 0){
				GameApplication.app.popuper.show(new PopUpDailyBonus(days));
			}
		}
		
		public function initPersParams(userParams:Object):void{
			GameApplication.app.models.onlineUsersCount = int(userParams[ProtocolKeys.COUNT]) + 1;
			if(userParams[ProtocolKeys.CLAN_INFO]){
				myuser.claninfo = new ClanUserInfo(userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_ID], userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_TITLE], userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_DEPOSIT_M],
													userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_DEPOSIT_E], userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_ROLE], userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.GET_CLAN_MONEY_AT]);
			}
			if(userParams[ProtocolKeys.CARS]){
				var car:CarModel;
				var carsArr:Array = userParams[ProtocolKeys.CARS];
				for each(var carObj:Object in carsArr){
					car = Parser.parseCar(carObj);
					myuser.cars.addItem(car);
				}
				myuser.cars.refresh();

				if(GameApplication.app.so.data["activeCarID"] != undefined && GameApplication.app.so.data["activeCarID"] != "undefined" && myuser.getCarById(GameApplication.app.so.data["activeCarID"])){
					myuser.activeCar = myuser.getCarById(int(GameApplication.app.so.data["activeCarID"]));
				}else{
					myuser.activeCar = myuser.cars.getItemAt(0) as CarModel;
				}
				
				if(myuser.activeCar){
					setActiveCar(myuser.activeCar.id);
				}
			}
			if(userParams[ProtocolKeys.POPULAR_PARTS]){
				popularparts = userParams[ProtocolKeys.POPULAR_PARTS];
			}
			if(userParams[ProtocolKeys.POPULAR_TITLES]){
				populartitles = userParams[ProtocolKeys.POPULAR_TITLES];
			}
			if(userParams[ProtocolKeys.QUESTS]){
				var q:Quest;
				for(var key:String in userParams[ProtocolKeys.QUESTS]){
					if(userParams[ProtocolKeys.QUESTS][key]){
						q = GameApplication.app.models.questsModel.getQuestById(int(key));
						if(q){
							q.status = userParams[ProtocolKeys.QUESTS][key][ProtocolKeys.STATUS];
							q.currentValue = userParams[ProtocolKeys.QUESTS][key][ProtocolKeys.VALUE];
							if(q.status == QuestStatus.PERFORMED){
								GameApplication.app.models.questsModel.currentQuest = q;
							}
						}
					}
				}
			}
			
			myuser.id = int(userParams[ProtocolKeys.ID]);
			myuser.sex = int(userParams[ProtocolKeys.SEX]);
			myuser.role = int(userParams[ProtocolKeys.ROLE]);
			myuser.title = String(userParams[ProtocolKeys.TITLE]);	
			myuser.level = int(userParams[ProtocolKeys.LEVEL]);
			myuser.experience = int(userParams[ProtocolKeys.EXPERIENCE]);
			myuser.exphour = int(userParams[ProtocolKeys.EXP_HOUR]);
			myuser.expday = int(userParams[ProtocolKeys.EXP_DAY]);
			myuser.popular = int(userParams[ProtocolKeys.POPULAR]);
			myuser.maxExperience = int(userParams[ProtocolKeys.NEXT_LEVEL_EXPERIENCE]);			
			myuser.money = int(userParams[ProtocolKeys.MONEY]);
			myuser.moneyReal = int(userParams[ProtocolKeys.MONEY_REAL]);
			GameApplication.app.banmanager.setBanTime(int(userParams[ProtocolKeys.BAN_TIME]));
			
			GameApplication.app.apimanager.addMoneyUserID = myuser.id;
			
			GameApplication.app.models.options.action = int(userParams[ProtocolKeys.OPTIONS][ProtocolKeys.ACTION]);
			
			_timeToUpdate = 60 * 5 + Math.floor(Math.random() * (60 * 5));
			setInterval(updateInterval, 1000);
			
			setVip(int(userParams[ProtocolKeys.VIP]), int(userParams[ProtocolKeys.VIP_TIME]));
		}
		
		public function setVip(vip:int, vipTime:int):void{
			myuser.vip = vip;
			myuser.vipTime = vipTime;
			
			if(_vipInterval != -1){
				clearInterval(_vipInterval);
			}
			_vipInterval = setInterval(onVipInterval, 1000);
		}
		
		private function onVipInterval():void{
			if(myuser.vipTime <= 0){
				if(_vipInterval != -1){
					clearInterval(_vipInterval);
				}
				myuser.vip = 0;
				myuser.vipTime = 0;
			}
			myuser.vipTime--;
		}
		
		public function updateInterval():void{
			_timeToUpdate--;
			if(_timeToUpdate <= 0){
				GameApplication.app.callsmanager.call(ProtocolValues.UPDATE_USER, null);
				_timeToUpdate = 60 * 5 + Math.floor(Math.random() * (60 * 5));
			}
		}
		
		public function setPersParams(userParams:Object):void{			
			myuser.id = int(userParams[ProtocolKeys.ID]);
			myuser.sex = int(userParams[ProtocolKeys.SEX]);
			myuser.title = String(userParams[ProtocolKeys.TITLE]);	
			myuser.level = int(userParams[ProtocolKeys.LEVEL]);
			myuser.popular = int(userParams[ProtocolKeys.POPULAR]);
			myuser.experience = int(userParams[ProtocolKeys.EXPERIENCE]);
			myuser.exphour = int(userParams[ProtocolKeys.EXP_HOUR]);
			myuser.expday = int(userParams[ProtocolKeys.EXP_DAY]);
			myuser.maxExperience = int(userParams[ProtocolKeys.NEXT_LEVEL_EXPERIENCE]);			
			myuser.money = int(userParams[ProtocolKeys.MONEY]);
			myuser.moneyReal = int(userParams[ProtocolKeys.MONEY_REAL]);
			if(userParams[ProtocolKeys.CLAN_INFO]){
				myuser.claninfo = new ClanUserInfo(userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_ID], userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_TITLE], userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_DEPOSIT_M],
					userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_DEPOSIT_E], userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_ROLE], userParams[ProtocolKeys.CLAN_INFO][ProtocolKeys.GET_CLAN_MONEY_AT]);
			}
		}
		
		public function changeMyParams(obj:Object):void{
			if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_MONEY){
				myuser.money = obj[ProtocolKeys.VALUE1];
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_MONEY_MONEYREAL){
				myuser.money = obj[ProtocolKeys.VALUE1];
				myuser.moneyReal = obj[ProtocolKeys.VALUE2];
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_MONEY_MONEYREAL_POPULAR){
				myuser.money = obj[ProtocolKeys.VALUE1];
				myuser.moneyReal = obj[ProtocolKeys.VALUE2];
				myuser.popular = obj[ProtocolKeys.VALUE3];
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_MONEY_MONEYREAL_EXPERIENCE){
				myuser.money = obj[ProtocolKeys.VALUE1];
				myuser.moneyReal = obj[ProtocolKeys.VALUE2];
				myuser.experience = obj[ProtocolKeys.VALUE3];
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_EXPERIENCE){
				myuser.experience = obj[ProtocolKeys.VALUE1];
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_POPULAR){
				myuser.popular = obj[ProtocolKeys.VALUE1];
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_EXPERIENCE_AND_POPULAR){
				myuser.experience = obj[ProtocolKeys.VALUE1];
				myuser.popular = obj[ProtocolKeys.VALUE2];
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_MONEY_POPULAR){
				myuser.money = obj[ProtocolKeys.VALUE1];
				myuser.popular = obj[ProtocolKeys.VALUE2];
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_MONEY_EXPERIENCE){
				myuser.money = obj[ProtocolKeys.VALUE1];
				myuser.experience = obj[ProtocolKeys.VALUE2];
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_MONEY_BANTYPE){
				myuser.money = obj[ProtocolKeys.VALUE1];
				if(BanType.NO_BAN == obj[ProtocolKeys.VALUE2]) GameApplication.app.banmanager.banoff();
			}else if(obj[ProtocolKeys.PARAM] == ChangeInfoParams.USER_EXPERIENCE_MAXEXPERIENCE_LEVEL){
				myuser.experience = obj[ProtocolKeys.VALUE1];
				myuser.maxExperience = obj[ProtocolKeys.VALUE2];
				myuser.level = obj[ProtocolKeys.VALUE3];
			}
		}
		
		public function isBadPlayer():void{
			GameApplication.app.callsmanager.call(ProtocolValues.IS_BAD_PLAYER, null);
		}
		
		public function addToFriend(uid:int, note:String):void{
			GameApplication.app.callsmanager.call(ProtocolValues.ADD_TO_FRIEND, onAddToFriend, uid, note);
		}
		
		private function onAddToFriend(obj:Object):void{
			if(!obj[ProtocolKeys.VALUE]){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при добавлении друга. Возможно этот человек уже добавлен в друзья или превышено максимальное поличество друзей: 100.");
			}else{
				GameApplication.app.popuper.hidePopUp();
			}
		}
		
		public function addToEnemy(uid:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.ADD_TO_ENEMY, onAddToEnemy, uid);
		}
		private function onAddToEnemy(result:Object):void{
			if(result[ProtocolKeys.VALUE] == true){				
			}else{
				GameApplication.app.popuper.showInfoPopUp("Невозможно добавить пользователя во враги. Максимальное количество врагов: 100.");
			}
		}
		
		public function getMessages():void{
			var offset:int = 0;
			if(GameApplication.app.models.mailMessages){
				offset = GameApplication.app.models.mailMessages.length;
			}
			GameApplication.app.callsmanager.call(ProtocolValues.GET_MAIL_MESSAGES, null, offset);
		}
		
		public function removeMailMessage(mid:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.REMOVE_MAIL_MESSAGE, onRemoveMailMessage, mid);
		}
		
		private function onRemoveMailMessage(result:Object):void{
			var mid:int = result[ProtocolKeys.VALUE];
			var message:MailMessageModel;
			for(var i:int; i < GameApplication.app.models.mailMessages.length; i++){
				message = GameApplication.app.models.mailMessages.getItemAt(i) as MailMessageModel;
				if(message && message.id == mid){
					GameApplication.app.models.mailMessages.removeItemAt(i);
					return;
				}
			}
		}
		
		public function getFriends():void{
			GameApplication.app.callsmanager.call(ProtocolValues.GET_FRIENDS, null, GameApplication.app.models.friends.length);
		}
		
		public function getPosts(callBack:Function):void{
			_getPostsCallBack = callBack;
			GameApplication.app.callsmanager.call(ProtocolValues.GET_POSTS, onGetPosts);
		}
		
		private function onGetPosts(posts:Object):void{
			_getPostsCallBack && _getPostsCallBack(posts);
			_getPostsCallBack = null;
		}
		
		public function getEnemies():void{
			GameApplication.app.callsmanager.call(ProtocolValues.GET_ENEMIES, null, GameApplication.app.models.enemies.length);
		}
		
		public function checkLuck(callBack:Function, bet:int):void{
			_checkLuckCallBack = callBack;
			GameApplication.app.callsmanager.call(ProtocolValues.CHECK_LUCK, onCheckLuck, bet);
		}
		
		private function onCheckLuck(result:Object):void{
			_checkLuckCallBack && _checkLuckCallBack(result);
			_checkLuckCallBack = null;
		}
		
		public function userInAuction():void{
			GameApplication.app.callsmanager.call(ProtocolValues.USER_IN_AUCTION, null);
		}
		
		public function userOutAuction():void{
			GameApplication.app.callsmanager.call(ProtocolValues.USER_OUT_AUCTION, null);
		}
		
		public function auctionBet(bet:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.AUCTION_BET, onAuctionBet, bet);
		}
		
		private function onAuctionBet(err:int):void{			
			if(err == BetResult.NO_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У вас недостаточно денег");
			}else if(err == BetResult.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Невозможно сделать ставку. Возможно ваша ставка ниже минимальной.");
			}
		}
		
		public function removeFriend(uid:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.REMOVE_FRIEND, onRemoveFriend, uid);
		}	
		
		private function onRemoveFriend(result:Object):void{
			var userid:int = result[ProtocolKeys.VALUE];
			var user:User;
			for(var i:int; i < GameApplication.app.models.friends.length; i++){
				user = GameApplication.app.models.friends.getItemAt(i) as User;
				if(user && user.id == userid){
					GameApplication.app.models.friends.removeItemAt(i);
					return;
				}
			}
		}
		
		private function onRemoveFriendError(u:Object):void{			
			GameApplication.app.popuper.showInfoPopUp("Произошла ошибка при обращении к серверу");
		}
		
		public function removeEnemy(uid:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.REMOVE_ENEMY, onRemoveEnemy, uid);
		}	
		
		private function onRemoveEnemy(result:Object):void{
			var userid:int = result[ProtocolKeys.VALUE];
			var user:User;
			for(var i:int; i < GameApplication.app.models.enemies.length; i++){
				user = GameApplication.app.models.enemies.getItemAt(i) as User;
				if(user && user.id == userid){
					GameApplication.app.models.enemies.removeItemAt(i);
					return;
				}
			}
		}
		
		private function onRemoveEnemyError(u:Object):void{			
			GameApplication.app.popuper.showInfoPopUp("Произошла ошибка при обращении к серверу");
		}
		
		public function sendMail(uid:int, message:String):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SEND_MAIL, onSendMail, uid, message);
		}
		
		private function onSendMail(buyresult:Object):void{	
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				GameApplication.app.popuper.showInfoPopUp("Ваше сообщение успешно доставлено");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для отправки почты.");
			}else{
				GameApplication.app.popuper.showInfoPopUp("Произошла ошибка при обращении к серверу");
			}
		}
		
		private function onSendMailError(error:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Произошла ошибка при обращении к серверу");
		}
		
		public function showUserInfo(user:User, callBack:Function = null):void{
			_getUserInfoCallBack = callBack;
			GameApplication.app.callsmanager.call(ProtocolValues.GET_USER_INFO_BY_ID, onGetUserInfo, user.id);			
		}
		
		
		private function onGetUserInfo(u:Object):void{
			if(_getUserInfoCallBack != null){
				_getUserInfoCallBack(User.createFromObject(u));
				_getUserInfoCallBack = null;
			}else{			
				if(u != null){
					var popUp:PopUp = new PopUpUserInfo(User.createFromObject(u));
					GameApplication.app.popuper.show(popUp);
				}else{
					var m:Object = new Object();
					m[ProtocolKeys.TYPE] = MessageType.SYSTEM;
					m[ProtocolKeys.TEXT] = "Пользователь вышел из игры";
					GameApplication.app.gameContainer.chat.activeRoom.addMessage(m);
				}
			}
		}
		private function onError(error:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Произошла ошибка при обращении к серверу");
		}
		
		public function showchangeInfo():void{
			if(GameApplication.app.config.playmode != 1){
				var popUp:PopUpChangeInfo = new PopUpChangeInfo();			
				GameApplication.app.popuper.show(popUp);
			}
		}
		
		public function changeInfo(newtitle:String, newsex:int):void{
			if (newtitle.length){
				GameApplication.app.callsmanager.call(ProtocolValues.CHANGE_INFO, onChange, newtitle, newsex);
				GameApplication.app.popuper.hidePopUp();
			}else{
				GameApplication.app.popuper.showInfoPopUp("Необходимо ввести имя пользователя");
			}
		}
		private function onChange(result:Object):void{
			var code:int = result[ProtocolKeys.ERROR_CODE];
			if (code == ChangeResult.OK){
				GameApplication.app.userinfomanager.myuser.title = result[ProtocolKeys.USER][ProtocolKeys.TITLE];
				GameApplication.app.userinfomanager.myuser.sex = result[ProtocolKeys.USER][ProtocolKeys.SEX];
				GameApplication.app.userinfomanager.myuser.money = result[ProtocolKeys.USER][ProtocolKeys.MONEY];
				GameApplication.app.popuper.showInfoPopUp("Параметры пользователя успешно изменены.");
			}else if (code == ChangeResult.NO_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас недостаточно денег для этой операции.");
			}else if (code == ChangeResult.USER_EXIST){
				GameApplication.app.popuper.showInfoPopUp("Неверное имя пользователя. Пользователь с таким именем уже существует.");
			}else if (code == ChangeResult.UNDEFINED){
				GameApplication.app.popuper.showInfoPopUp("Произошла ошибка при изменении параметров пользователя. Сообщите об этом разработчикам!");
			}
		}
		private function onChangeError(err:Object):void{			
			GameApplication.app.popuper.showInfoPopUp("Произошла ошибка при изменении параметров пользователя. Сообщите об этом разработчикам!");			
		}
		
		public function startChangeInfo(newtitle:String, newsex:int):void{
			if (newtitle.length == 0){				
				newtitle = GameApplication.app.userinfomanager.myuser.title;
			}
			
			GameApplication.app.callsmanager.call(ProtocolValues.START_CHANGE_INFO, onStartChange, newtitle, newsex);
			GameApplication.app.popuper.hidePopUp();
		}
		
		private function onStartChange(result:Object):void{
			if (result[ProtocolKeys.ERROR_CODE] == ChangeResult.OK){
				GameApplication.app.userinfomanager.myuser.title = result[ProtocolKeys.USER][ProtocolKeys.TITLE];
				GameApplication.app.userinfomanager.myuser.sex = result[ProtocolKeys.USER][ProtocolKeys.SEX];
				GameApplication.app.userinfomanager.myuser.money = result[ProtocolKeys.USER][ProtocolKeys.MONEY];
				
				GameApplication.app.popuper.show(new PopUpTutorialSecond());
				
				GameApplication.app.gameContainer.chat.getUserByID(GameApplication.app.userinfomanager.myuser.id).title = GameApplication.app.userinfomanager.myuser.title; 
			}
		}
		
		public function getPopularTitle(value:int):String{
			for(var i:int; i < popularparts.length - 1; i++){
				if(popularparts[i] <= value && popularparts[i + 1] > value){
					return populartitles[i];
				}
			}
			return populartitles[populartitles.length - 1]
		}
		
		public function getPopularIconClass(value:int):Class{			
			for(var i:int; i < popularparts.length - 1; i++){
				if(popularparts[i] <= value && popularparts[i + 1] > value){
					return popularicons[i];
				}
			}
			return popularicons[popularicons.length - 1]
		}
		
		public function showOnlineTimeMoneyInfo():void{	
			GameApplication.app.callsmanager.call(ProtocolValues.GET_ONLINE_TIME_MONEY_INFO, onGetOnlineTimeMoneyInfo);
		}
		
		private function onGetOnlineTimeMoneyInfo(obj:Object):void{
			var money:int = obj[ProtocolKeys.VALUE];
			GameApplication.app.popuper.show(new PopUpPay(money));			
		}
		public function getOnlineTimeMoney():void{		
			GameApplication.app.callsmanager.call(ProtocolValues.GET_ONLINE_TIME_MONEY, null);
		}
		
		public function setActiveCar(carID:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SET_ACTIVE_CAR, null, carID);
		}
	}
}