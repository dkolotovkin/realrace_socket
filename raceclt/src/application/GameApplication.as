package application
{
	import application.components.connectionbtngr.ConnectionBtnGroup;
	import application.components.errorlabel.ErrorLabel;
	import application.components.log.LogPanel;
	import application.components.preloader.PreLoaderCircle;
	import application.gamecontainer.GameContainer;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.SharedObject;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.managers.ToolTipManager;
	
	import spark.components.Application;
	
	import utils.chat.ChatManager;
	import utils.chat.actionshower.ActionsShowerMenu;
	import utils.game.GameManager;
	import utils.log.Log;
	import utils.managers.admin.AdministratorManager;
	import utils.managers.apimanager.ApiManager;
	import utils.managers.apimanager.ApiManagerMM;
	import utils.managers.apimanager.ApiManagerOD;
	import utils.managers.apimanager.ApiManagerSite;
	import utils.managers.apimanager.ApiManagerVK;
	import utils.managers.ban.BanManager;
	import utils.managers.calls.CallsManager;
	import utils.managers.clan.ClanManager;
	import utils.managers.constructor.ConstructorManager;
	import utils.managers.navigation.NavigationManager;
	import utils.managers.persinfo.UserInfoManager;
	import utils.managers.quests.QuestsManager;
	import utils.managers.tooltip.GameToolTipManager;
	import utils.managers.tooltip.types.simple.ToolTip;
	import utils.models.Models;
	import utils.parser.Parser;
	import utils.popup.PopUpManager;
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;
	import utils.shop.ShopManager;
	import utils.sound.SoundManager;
	import utils.user.UserRole;
	import utils.vk.api.serialization.json.JSON;
	
	public class GameApplication extends Application
	{
		[Bindable]
		public static var app:GameApplication;
		
		[Bindable]
		public var config:GameApplicationConfig;
		public var gameContainer:GameContainer = new GameContainer();		
		public var navigator:NavigationManager = new NavigationManager();
		public var actionShowerMenu : ActionsShowerMenu = new  ActionsShowerMenu();
		public var logPanel:LogPanel;
		[Bindable]
		public var userinfomanager:UserInfoManager = new UserInfoManager();
		public var tooltiper:GameToolTipManager = new GameToolTipManager();
		public var chatmanager:ChatManager = new ChatManager();
		[Bindable]
		public var gamemanager:GameManager = new GameManager();
		[Bindable]
		public var constructor:ConstructorManager = new ConstructorManager();
		public var shopmanager:ShopManager = new ShopManager();		
		public var callsmanager:CallsManager;
		public var popuper:PopUpManager;
		public var apimanager:ApiManager;
		
		[Bindable]
		public var banmanager:BanManager = new BanManager();
		public var clanmanager:ClanManager = new ClanManager();
		public var adminmanager:AdministratorManager = new AdministratorManager();
		public var soundmanager:SoundManager;
		public var questsmanager:QuestsManager;
		
		[Bindable]
		public var models:Models = new Models();
		
		public var connectPreLoader:PreLoaderCircle = new PreLoaderCircle();
		private var _errorLabel:ErrorLabel = new ErrorLabel();
		private var _connectBtnGr:ConnectionBtnGroup = new ConnectionBtnGroup();
		
		private var _connectionInterval:int = -1;
		private var _addtostageIntervall:int = -1;
		private var _tryconnected:Boolean;
		private var _timeToConnect:uint;
		
		private var _needConnected:Boolean = true;
		private var _socket:Socket;
		
		private var _checkInterval:int = -1;
		private var _lasttime:Number;
		public var so:SharedObject;
		public var sostatic:SharedObject;
		
		private var buffer:String;
		
		public function get socket():Socket{
			return _socket;
		}
		
		public function GameApplication()
		{
			super();
			app = this;
			config = new GameApplicationConfig(app);
			Security.allowDomain("*");
			so = SharedObject.getLocal("realrace", "/");
			sostatic = SharedObject.getLocal("realracestatic_" + config.staticDataVersion);
			models.settings.init();
			soundmanager = new SoundManager();
			buffer = "";
			Log.add("init GameApplication");
			
			try{
				_socket = new Socket();
				_socket.addEventListener(ProgressEvent.SOCKET_DATA, onData);
				_socket.addEventListener(IOErrorEvent.IO_ERROR, onSocketError);
				_socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSocketError);
				_socket.addEventListener(IOErrorEvent.VERIFY_ERROR, onSocketError);
				_socket.addEventListener(Event.CLOSE, onSocketError);
				_socket.addEventListener(Event.CONNECT, onConnectToServer);
				callsmanager = new CallsManager(_socket);
			}catch(e:*){
			}
			
			popuper = new PopUpManager();
			
			actionShowerMenu.percentHeight = 100;
			actionShowerMenu.percentWidth = 100;
			
			ToolTipManager.showDelay = 400;
			ToolTipManager.scrubDelay = 0;
			ToolTipManager.toolTipClass = ToolTip;
			tooltiper.append(this);
			
			connectPreLoader.text = "Подключение к серверу...";
			_errorLabel.text = "В настоящее время сервер не доступен. Повторите попытку чуть позже...";			
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);		
			
			if(_addtostageIntervall != -1){
				clearInterval(_addtostageIntervall);
				_addtostageIntervall = -1;
			}
			_addtostageIntervall = setInterval(createApiManager, 5000);
			
			var _date:Date = new Date();
			_lasttime = _date.getTime();
			_checkInterval = setInterval(checkSpeed, 10000);
		}
		
		protected function onConnectToServer(event:Event):void
		{
			connectPreLoader.text = "Подключение к серверу...";
			if(GameApplication.app.config.mode == GameMode.SITE){
				GameApplication.app.callsmanager.call(ProtocolValues.LOGIN_SITE, onLogIn, apimanager.idsocail, config.confirmationid, config.currentVersion, config.playmode);
			}else{
				GameApplication.app.callsmanager.call(ProtocolValues.LOGIN, onLogIn, apimanager.idsocail, null, apimanager.autukey, apimanager.vid, config.mode, apimanager.appid, config.currentVersion);
			}
		}
		
		private function checkSpeed():void{
			var _date:Date = new Date();
			var _delta:Number = _date.getTime() - _lasttime;
			_lasttime = _date.getTime();
			
			if(_delta < 9700 && _socket && _socket.connected){
				userinfomanager.isBadPlayer();	
				_needConnected = false;
			}
		}
		
		private function onAddedToStage(event : Event) : void {
			questsmanager = new QuestsManager();
			createApiManager();
			stage.quality = models.settings.stageQuality;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void{
			if(e.keyCode == 75 && e.ctrlKey){								//ctrl + K
				navigator.goConstructor();
			}else if(e.keyCode == 67 && e.ctrlKey && e.shiftKey){			//ctrl + C
				Log.clear();
			}else if(e.keyCode == 76 && e.ctrlKey && e.shiftKey){			//ctrl + L
				if(logPanel){
					if(contains(logPanel)){
						removeElement(logPanel);
					}
					logPanel = null;
				}else{
					logPanel = new LogPanel();
					addElement(logPanel);
				}
			}
		}
		
		private function createApiManager():void{			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			if(_addtostageIntervall != -1){
				clearInterval(_addtostageIntervall);
				_addtostageIntervall = -1;
			}
			
			if(GameApplication.app.config.mode == GameMode.DEBUG){
				apimanager = new ApiManager();
			}else if (GameApplication.app.config.mode == GameMode.VK){
				apimanager = new ApiManagerVK();
			}else if (GameApplication.app.config.mode == GameMode.MM){				
				apimanager = new ApiManagerMM();
			}else if (GameApplication.app.config.mode == GameMode.OD){				
				apimanager = new ApiManagerOD();
			}else if (GameApplication.app.config.mode == GameMode.SITE){
				apimanager = new ApiManagerSite();
			}			
			apimanager.init();
		}
		
		public function reconnect():void{			
			if(_socket != null && _socket.connected){				
				_socket.close();
			}
		}		
		
		public function connect():void{
			if (!_socket.connected && _needConnected){
				try{
					_socket.connect(config.serverAddress, config.serverPort);
					_tryconnected = true;					
				}catch(e:*){
					_tryconnected = false;
					gamemanager.exitGame();
					chatmanager.exitGame();
					
					gameContainer.chat.closeRooms();
				}
				updateUIByConnection();
			}
		}
		
		private function onSocketError(e:Event):void{
			_tryconnected = false;
			gamemanager.exitGame();
			chatmanager.exitGame();
			models.settings.gameRunning = false;
			
			gameContainer.chat.closeRooms();
			updateUIByConnection();
		}
		
		//метод для обновления графики при коннекте. по хорошему нужно переписать коннект по-человечески
		private function updateUIByConnection():void{
			if(_connectionInterval != -1){
				clearInterval(_connectionInterval);
				_connectionInterval = -1;
			}
			
			if (_tryconnected){
				if(!contains(connectPreLoader)) addElement(connectPreLoader);
				contains(_errorLabel) && removeElement(_errorLabel);
				contains(_connectBtnGr) && removeElement(_connectBtnGr);
			}else{
				addElement(_errorLabel);
				contains(connectPreLoader) && removeElement(connectPreLoader);				
			}
			
			if (!_socket.connected){	
				contains(gameContainer) && removeElement(gameContainer);
				contains(actionShowerMenu) && removeElement(actionShowerMenu);
				contains(popuper.popupzone) && removeElement(popuper.popupzone);
				
				if (!_tryconnected){
					_timeToConnect = config.connetionInterval;				
					_connectionInterval = setInterval(updateTimeToConnect, 1000);
					updateTimeToConnect();
				}
			}else{
				contains(connectPreLoader) && removeElement(connectPreLoader);
				contains(_errorLabel) && removeElement(_errorLabel);
				
				addElement(gameContainer);
				addElement(popuper.popupzone);
				addElement(actionShowerMenu);
			}
		}
		
		private function updateTimeToConnect():void{
			if(_timeToConnect > 0){
				var seconds:String = "секунду";
				if(_timeToConnect > 1 && _timeToConnect < 5) seconds = "секунды";
				else if(_timeToConnect > 1) seconds = "секунд";
				_errorLabel.text = "В настоящее время сервер не доступен. \nПовторите попытку подключения через " + _timeToConnect + " " + seconds + "...";
				_timeToConnect--;
			}else{
				if(_connectionInterval != -1){
					clearInterval(_connectionInterval);
					_connectionInterval = -1;
				}
				
				contains(_errorLabel) && removeElement(_errorLabel);
				if(!contains(_connectBtnGr)) addElement(_connectBtnGr);
			}
		}
		
		private function onData(event:ProgressEvent):void
		{
			_tryconnected = false;
			var data:String = _socket.readUTFBytes(_socket.bytesAvailable);
			var datas:Array = data.split(config.lineSeparator);
			
			for(var i:int = 0; i < datas.length; i++){
				buffer += datas[i]
				if((i + 1) < datas.length){
					processData(buffer);
					buffer = "";
				}
			}		
		}
		
		private function processData(data:String):void
		{
			try{
				var jsonObj:Object = JSON.decode(data);
				switch (int(jsonObj[ProtocolKeys.COMMAND])){
					case ProtocolValues.PROCESS_MESSAGE:
					{
						chatmanager.processMassage(jsonObj);
						break;
					}
					case ProtocolValues.PROCESS_GAME_ACTION:
					{
						gamemanager.processGameAction(jsonObj);
						break;
					}
					case ProtocolValues.PROCESS_USER_PRESENTS:
					{
						Parser.parseUserItemsPresent(jsonObj[ProtocolKeys.ITEMS]);
						break;
					}
					case ProtocolValues.PROCESS_CURRENT_CLAN_USERS:
					{
						Parser.parseCurrentClanUsers(jsonObj);
						break;
					}
					case ProtocolValues.PROCESS_FRIENDS:
					{
						Parser.parseFriends(jsonObj[ProtocolKeys.USERS]);
						break;
					}
					case ProtocolValues.PROCESS_ENEMIES:
					{
						Parser.parseEnemies(jsonObj[ProtocolKeys.USERS]);
						break;
					}
					case ProtocolValues.PROCESS_MAIL_MESSAGES:
					{
						Parser.parseMailMessages(jsonObj[ProtocolKeys.MESSAGES]);
						break;
					}
					case ProtocolValues.PROCESS_PROTOTYPES:
					{
						Parser.parseItemPrototypes(jsonObj[ProtocolKeys.PROTOTYPES]);
						break;
					}					
					case ProtocolValues.CALLBACK:
					{
						callsmanager.callBack(int(jsonObj[ProtocolKeys.CALLBACKID]), jsonObj);
						break;
					}
					case ProtocolValues.INIT_PERS_PARAMS:
					{
						userinfomanager.initPersParams(jsonObj);
						navigator.goHome();
						break;
					}
				}
			}catch(e:*){
				
			}
		}
		
		private function onLogIn(obj:Object):void{			
			if (obj[ProtocolKeys.VALUE]) 
			{
				if(config.playmode == 1){
					connectPreLoader.text = "Вход в игровую комнату...";
					GameApplication.app.callsmanager.call(ProtocolValues.USER_IN_COMMON_ROOM, onEnterCommonRoom);
				}else{
					connectPreLoader.text = "Загрузка вещей...";
					shopmanager.init(onShopInit);					
				}
			}else{
				_tryconnected = false;
				updateUIByConnection();
			}
		}
		
		private function onShopInit():void{
			connectPreLoader.text = "Вход в игровую комнату...";
			if(userinfomanager.myuser && 
				(userinfomanager.myuser.role == UserRole.ADMINISTRATOR || userinfomanager.myuser.role == UserRole.ADMINISTRATOR_MAIN || userinfomanager.myuser.role == UserRole.MODERATOR)){
				GameApplication.app.callsmanager.call(ProtocolValues.USER_IN_MODS_ROOM, onEnterModsRoom);
			}else{
				GameApplication.app.callsmanager.call(ProtocolValues.USER_IN_COMMON_ROOM, onEnterCommonRoom);
			}
		}
		
		private function onEnterModsRoom(result:Object):void{
			GameApplication.app.callsmanager.call(ProtocolValues.USER_IN_COMMON_ROOM, onEnterCommonRoom);
		}
		
		private function onEnterCommonRoom(result:Object):void{
			Log.add("onEnterCommonRoom");
			
			_tryconnected = false;
			updateUIByConnection();
			navigator.goHome();
			models.settings.gameRunning = true;
			
			if(GameApplication.app.config.playmode == 1){
			}else{
				GameApplication.app.userinfomanager.getDailyBonus(onGetDailyBonus);
			}
		}
		
		private function onGetDailyBonus():void{
			apimanager.getFriendsBonus();
		}
		
		override protected function createChildren():void{
			this.percentWidth = this.percentHeight = 100;
			super.createChildren();
		}
	}
}