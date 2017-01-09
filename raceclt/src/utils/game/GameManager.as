package utils.game
{
	import application.GameApplication;
	import application.components.popup.extraction.PopUpExtraction;
	import application.components.popup.help.tutorial.third.PopUpTutorialThird;
	import application.gamecontainer.scene.game.GameWorld;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import utils.game.action.GameActionStartRequestCode;
	import utils.game.action.GameActionSubType;
	import utils.game.action.GameActionType;
	import utils.game.action.GameType;
	import utils.game.betroominfo.GameBetRoomInfo;
	import utils.models.game.GameStatus;
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;
	import utils.user.User;

	public class GameManager extends EventDispatcher
	{
		public var timer:Timer;
		public var timeround:int;
		public var roomID:int;		
		public var gameworld:GameWorld;
		[Bindable]
		public var gameMode:Boolean = false;
		[Bindable]
		public var testMode:Boolean = false;
		public var myUserFinished:Boolean = false;
		public var gameType:int = GameType.UNDEFINED;
		[Bindable]
		public var creatorMapText:String;
		[Bindable]
		public var mapName:String;
		
		private var _callBackBetGames:Function;
		private var _callBackBetsInfo:Function;
		
		public var sendRequest:Boolean = false;
		
		public var fistGame:Boolean = true;
		
		public function GameManager(){
		}
		
		/*
		* ИГРА НА ДЕНЬГИ
		*/
		
		//получить информацию о доступных играх на деньги
		public function getBetGamesInfo(callback:Function):void{
			_callBackBetGames = callback;
			GameApplication.app.callsmanager.call(ProtocolValues.GAME_GET_BET_GAMES_INFO, ongetBetGamesInfo);
		}		
		private function ongetBetGamesInfo(obj:Object):void{			
			var rooms:Array = obj[ProtocolKeys.ROOMS];
			var list:Array = new Array();
			for(var i:uint = 0; i < rooms.length; i++){
				if(rooms[i]){
					var creator:User = null;
					if(rooms[i][ProtocolKeys.CREATOR]){
						creator = User.createFromObject(rooms[i][ProtocolKeys.CREATOR]);
						creator.isonline = true;
					}
					
					if(rooms[i][ProtocolKeys.USERS]){
						var room:GameBetRoomInfo = new GameBetRoomInfo(rooms[i][ProtocolKeys.ID], rooms[i][ProtocolKeys.BET], rooms[i][ProtocolKeys.TIME], rooms[i][ProtocolKeys.ISSEATS], Boolean(rooms[i][ProtocolKeys.RLOCKED]), rooms[i][ProtocolKeys.USERS], creator);
						list.push(room);
					}
				}
			}
			
			_callBackBetGames && _callBackBetGames(list);			
			_callBackBetGames = null;
		}
		
		//создать игру на деньги
		public function createBetGame(bet:int, pass:String):void{
			if(!sendRequest){				
				GameApplication.app.callsmanager.call(ProtocolValues.GAME_CREATE_BET_GAME, onStart, bet, pass);
				sendRequest = true;
			}
		}
		//войти в игру на деньги
		public function addToBetGame(roomID:int, pass:String):void{
			if(!sendRequest){
				GameApplication.app.callsmanager.call(ProtocolValues.GAME_ADD_TO_BET_GAME, onStart, roomID, pass);
				sendRequest = true;
			}
		}
		
		/*
		* ОБЫЧНАЯ ИГРА
		*/
		
		//войти в игру(в забег)
		public function sendStartRequest(districtID:int):void{
			if(GameApplication.app.userinfomanager.myuser.activeCar){
				if(GameApplication.app.userinfomanager.myuser.activeCar.durability > 0){
					if(!sendRequest){
						sendRequest = true;
						GameApplication.app.callsmanager.call(ProtocolValues.GAME_START_REQUEST, onStart, GameApplication.app.userinfomanager.myuser.activeCar.id, districtID);
					}
				}else{
					GameApplication.app.popuper.showInfoPopUp("Ваш активный автомобиль нуждается в ремонте!");
				}
			}else{
				GameApplication.app.popuper.showInfoPopUp("Укажите автомобиль для гонки!");
			}
		}
		private function onStart(result:Object):void{
			if(result[ProtocolKeys.CODE] == GameActionStartRequestCode.OK){
				if(!gameMode){
					GameApplication.app.popuper.hidePopUp();
					GameApplication.app.navigator.goFindUsersScreen(result[ProtocolKeys.WAIT_TIME]);
				}
			}else if(result[ProtocolKeys.CODE] == GameActionStartRequestCode.ERROR_CAR_DURABILITY){
				GameApplication.app.popuper.showInfoPopUp("Ваш активный автомобиль нуждается в ремонте!");
			}else if(result[ProtocolKeys.CODE] == GameActionStartRequestCode.ERROR_CAR_UNDEFINED){
				GameApplication.app.popuper.showInfoPopUp("Указанный вами автомобиль не найден!");
			}else if(result[ProtocolKeys.CODE] == GameActionStartRequestCode.ERROR_DISTRICT){
				GameApplication.app.popuper.showInfoPopUp("Класс вашего активного автомобиля не подходит для указанного района! Выберите подходящие друг другу по классу район и автомобиль.");
			}else if(result[ProtocolKeys.CODE] == GameActionStartRequestCode.ERROR_DISTRICT_UNDEFINED){
				GameApplication.app.popuper.showInfoPopUp("Указан некорректный район для заезда!");
			}else if(result[ProtocolKeys.CODE] == GameActionStartRequestCode.ERROR_NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У вас недостаточно денег для игры!");
			}else if(result[ProtocolKeys.CODE] == GameActionStartRequestCode.ERROR_NO_ROOM){
				GameApplication.app.popuper.showInfoPopUp("Игровая комната не найдена, возможно игра уже началась!");
			}else if(result[ProtocolKeys.CODE] == GameActionStartRequestCode.ERROR_NO_SEATS){
				GameApplication.app.popuper.showInfoPopUp("Нет свободных мест!");
			}else if(result[ProtocolKeys.CODE] == GameActionStartRequestCode.ERROR_BAD_PASSWARD){
				GameApplication.app.popuper.showInfoPopUp("Указан неверный пароль!");
			}else{
				GameApplication.app.popuper.showInfoPopUp("Ошибка при старте заезда!");
			}
			sendRequest = false;
		}
		
		public function myUserOut():void{
			dispatchEvent(new GameManagerEvent(GameManagerEvent.MY_USER_OUT, 0));
		}		
		
		public function processGameAction(action:Object):void{			
			if(action){
				if (action[ProtocolKeys.TYPE] == GameActionType.NOT_ENOUGH_USERS){
					GameApplication.app.navigator.goMapPage();
					GameApplication.app.popuper.showInfoPopUp("Нет желающих поиграть прямо сейчас. Повторите попытку немного позже.");
				}else if(action[ProtocolKeys.TYPE] == GameActionType.START){
					if(GameApplication.app.userinfomanager.myuser.activeCar){
						if(GameApplication.app.userinfomanager.myuser.activeCar.rented == 0){
							GameApplication.app.userinfomanager.myuser.activeCar.durability--;
						}
					}
					
					GameApplication.app.gameContainer.chat.finishedpanel.clearPanel();
					GameApplication.app.gameContainer.chat.miniMapPanel.clearPanel();
					gameMode = true;
					myUserFinished = false;
					gameType = action[ProtocolKeys.GAME_TYPE];
					
					if(action[ProtocolKeys.MAP]){
						GameApplication.app.models.gameModel.mapID = action[ProtocolKeys.MAP][ProtocolKeys.ID];
						GameApplication.app.models.gameModel.laps = action[ProtocolKeys.MAP][ProtocolKeys.LAPS];
					}
					GameApplication.app.models.gameModel.currentLap = 0;
					
					gameworld = GameApplication.app.navigator.goGameWorld(action[ProtocolKeys.ROOM_ID], action[ProtocolKeys.DISTRICT], (action[ProtocolKeys.USERS] as Array), (action[ProtocolKeys.CARS] as Array), (action[ProtocolKeys.COLORS] as Array), action[ProtocolKeys.GAME_TYPE]);
					gameworld.keyBoardReaction = false;
					
					GameApplication.app.soundmanager.gameSoundStart();
					
					GameApplication.app.models.gameModel.gameStatus = GameStatus.FINISH_ON;
					
					timeround = 5 * 60;
					timer = new Timer(1000, timeround);
					timer.start();
					timer.addEventListener(TimerEvent.TIMER, timerHandler);
					dispatchEvent(new GameManagerEvent(GameManagerEvent.TIMER_UPDATE, timeround));					
				}else if(action[ProtocolKeys.TYPE] == GameActionType.ACTION){
					if (gameworld != null && gameworld.roomID == int(action[ProtocolKeys.ROOM_ID])){
						var linerVelocityArr:Array;
						if (action[ProtocolKeys.SUBTYPE] == GameActionSubType.GOTOLEFT){
							linerVelocityArr = (action[ProtocolKeys.LINER_VELOCITY] as String).split(":");
							gameworld.userGotoLeft(action[ProtocolKeys.INITIATOR_ID], action[ProtocolKeys.DOWN], action[ProtocolKeys.USERX], action[ProtocolKeys.USERY], action[ProtocolKeys.ROTATION], linerVelocityArr[0], linerVelocityArr[1]);
						}else if (action[ProtocolKeys.SUBTYPE] == GameActionSubType.GOTORIGHT){
							linerVelocityArr = (action[ProtocolKeys.LINER_VELOCITY] as String).split(":");
							gameworld.userGotoRight(action[ProtocolKeys.INITIATOR_ID], action[ProtocolKeys.DOWN], action[ProtocolKeys.USERX], action[ProtocolKeys.USERY], action[ProtocolKeys.ROTATION], linerVelocityArr[0], linerVelocityArr[1]);
						}else if (action[ProtocolKeys.SUBTYPE] == GameActionSubType.FORWARD){
							linerVelocityArr = (action[ProtocolKeys.LINER_VELOCITY] as String).split(":");
							gameworld.userForward(action[ProtocolKeys.INITIATOR_ID], action[ProtocolKeys.DOWN], action[ProtocolKeys.USERX], action[ProtocolKeys.USERY], action[ProtocolKeys.ROTATION], linerVelocityArr[0], linerVelocityArr[1]);
						}else if (action[ProtocolKeys.SUBTYPE] == GameActionSubType.BACK){
							linerVelocityArr = (action[ProtocolKeys.LINER_VELOCITY] as String).split(":");
							gameworld.userBack(action[ProtocolKeys.INITIATOR_ID], action[ProtocolKeys.DOWN], action[ProtocolKeys.USERX], action[ProtocolKeys.USERY], action[ProtocolKeys.ROTATION], linerVelocityArr[0], linerVelocityArr[1]);
						}else if (action[ProtocolKeys.SUBTYPE] == GameActionSubType.BRAKE){
							linerVelocityArr = (action[ProtocolKeys.LINER_VELOCITY] as String).split(":");
							gameworld.userBrake(action[ProtocolKeys.INITIATOR_ID], action[ProtocolKeys.DOWN], action[ProtocolKeys.USERX], action[ProtocolKeys.USERY], action[ProtocolKeys.ROTATION], linerVelocityArr[0], linerVelocityArr[1]);
						}else if (action[ProtocolKeys.SUBTYPE] == GameActionSubType.FINISH){
							GameApplication.app.gameContainer.chat.finishedpanel.addFinishedUser(action[ProtocolKeys.POSITION], action[ProtocolKeys.INITIATOR_TITLE]);
						}
					}
				}else if (action[ProtocolKeys.TYPE] == GameActionType.FINISH_EXTRACTION){
					if(gameworld != null && gameworld.roomID == int(action[ProtocolKeys.ROOM_ID])){
						GameApplication.app.popuper.show(new PopUpExtraction(action[ProtocolKeys.EXTRACTION], action[ProtocolKeys.POSITION]));
					}
				}else if (action[ProtocolKeys.TYPE] == GameActionType.FINISH){
					if(gameworld != null && gameworld.roomID == int(action[ProtocolKeys.ROOM_ID])){
						exitGame();
						var position:int = action[ProtocolKeys.POSITION];
						if(position < 0){
							var extraction:Object = new Object();
							extraction[ProtocolKeys.EXPERIENCE] = -2;
							GameApplication.app.popuper.show(new PopUpExtraction(extraction, position));
						}
					}
				}else if (action[ProtocolKeys.TYPE] == GameActionType.FINISH_BET){
					if(gameworld != null && gameworld.roomID == int(action[ProtocolKeys.ROOM_ID])){
						exitGame();
						var popUpBet:PopUpExtraction = new PopUpExtraction(action[ProtocolKeys.EXTRACTION], action[ProtocolKeys.POSITION]);			
						GameApplication.app.popuper.show(popUpBet);
					}
				}else if (action[ProtocolKeys.TYPE] == GameActionType.WAIT_START){
					if (!gameMode){
						GameApplication.app.popuper.hidePopUp();
						GameApplication.app.navigator.goFindUsersScreen(action[ProtocolKeys.WAIT_TIME]);
					}
				}else if(action[ProtocolKeys.TYPE] == GameActionType.PASSED_5_SECOND){
					if(gameworld != null && gameworld.roomID == int(action[ProtocolKeys.ROOM_ID])){
						gameworld.removeRoundTimer();
						gameworld.keyBoardReaction = true;
					}
				}else if(action[ProtocolKeys.TYPE] == GameActionType.NEW_LAP){
					if(gameworld != null && gameworld.roomID == int(action[ProtocolKeys.ROOM_ID])){
						GameApplication.app.models.gameModel.currentLap++;
						if(GameApplication.app.models.gameModel.currentLap >= GameApplication.app.models.gameModel.laps){
							gameworld.myUserFinished();
							myUserFinished = true;
						}
					}
				}else if(action[ProtocolKeys.TYPE] == GameActionType.RETURN_TO_START){
				}
			}else{
				GameApplication.app.navigator.goHome();
				GameApplication.app.popuper.showInfoPopUp("Произошла ошибка. Код ошибки 222. Сообщите об этом разработчикам!");
			}
		}
		
		public function exitGame():void{
			if(gameworld){
				GameApplication.app.gameContainer.chat.finishedpanel.clearPanel();
				GameApplication.app.actionShowerMenu.hideMenu();
				
				if(timer){
					timer.removeEventListener(TimerEvent.TIMER, timerHandler);
					timer.stop();
				}
				
				gameworld.destroyWorld();
				
				GameApplication.app.navigator.goMapPage();

				gameworld = null;
				
				gameMode = false;
				myUserFinished = false;
				gameType = GameType.UNDEFINED;
			}
			GameApplication.app.soundmanager.gameSoundEnd();
		}
		
		private function timerHandler(e:TimerEvent):void{
			dispatchEvent(new GameManagerEvent(GameManagerEvent.TIMER_UPDATE, (timeround * 1000 - (e.target as Timer).currentCount * (e.target as Timer).delay) / 1000));
		}
		
		public function goToLeft(down:Boolean, _x:Number, _y:Number, _r:Number, _lvx:Number, _lvy:Number):void{
			_x = Math.round(_x * 100) / 100;
			_y = Math.round(_y * 100) / 100;
			_r = Math.round(_r * 100) / 100;
			_lvx = Math.round(_lvx * 100) / 100;
			_lvy = Math.round(_lvy * 100) / 100;
			GameApplication.app.callsmanager.call(ProtocolValues.GAME_GO_TO_LEFT, null, gameworld.roomID, down, _x, _y, _r, _lvx + ":" + _lvy);
		}
		public function goToRight(down:Boolean, _x:Number, _y:Number, _r:Number, _lvx:Number, _lvy:Number):void{
			_x = Math.round(_x * 100) / 100;
			_y = Math.round(_y * 100) / 100;
			_r = Math.round(_r * 100) / 100;
			_lvx = Math.round(_lvx * 100) / 100;
			_lvy = Math.round(_lvy * 100) / 100;
			GameApplication.app.callsmanager.call(ProtocolValues.GAME_GO_TO_RIGHT, null, gameworld.roomID, down, _x, _y, _r, _lvx + ":" + _lvy);
		}
		public function forward(down:Boolean, _x:Number, _y:Number, _r:Number, _lvx:Number, _lvy:Number):void{
			_x = Math.round(_x * 100) / 100;
			_y = Math.round(_y * 100) / 100;
			_r = Math.round(_r * 100) / 100;
			_lvx = Math.round(_lvx * 100) / 100;
			_lvy = Math.round(_lvy * 100) / 100;
			GameApplication.app.callsmanager.call(ProtocolValues.GAME_FORWARD, null, gameworld.roomID, down, _x, _y, _r, _lvx + ":" + _lvy);
		}
		public function back(down:Boolean, _x:Number, _y:Number, _r:Number, _lvx:Number, _lvy:Number):void{
			_x = Math.round(_x * 100) / 100;
			_y = Math.round(_y * 100) / 100;
			_r = Math.round(_r * 100) / 100;
			_lvx = Math.round(_lvx * 100) / 100;
			_lvy = Math.round(_lvy * 100) / 100;
			GameApplication.app.callsmanager.call(ProtocolValues.GAME_BACK, null, gameworld.roomID, down, _x, _y, _r, _lvx + ":" + _lvy);
		}
		public function brake(down:Boolean, _x:Number, _y:Number, _r:Number, _lvx:Number, _lvy:Number):void{
			_x = Math.round(_x * 100) / 100;
			_y = Math.round(_y * 100) / 100;
			_r = Math.round(_r * 100) / 100;
			_lvx = Math.round(_lvx * 100) / 100;
			_lvy = Math.round(_lvy * 100) / 100;
			GameApplication.app.callsmanager.call(ProtocolValues.GAME_BRAKE, null, gameworld.roomID, down, _x, _y, _r, _lvx + ":" + _lvy);
		}
		
		public function sensorStart():void{
			GameApplication.app.callsmanager.call(ProtocolValues.GAME_SENSOR_START, null, gameworld.roomID);
		}
		
		public function sensorFinish():void{
			if(GameApplication.app.models.gameModel.gameType == GameType.TEST_TUTORIAL){
				GameApplication.app.gamemanager.gameworld.keyBoardReaction = false;
				GameApplication.app.gamemanager.testMode = false;
				exitGame();
				GameApplication.app.popuper.show(new PopUpTutorialThird());
			}else if(GameApplication.app.models.gameModel.gameType == GameType.SIMPLE ||
						GameApplication.app.models.gameModel.gameType == GameType.BET){
				GameApplication.app.callsmanager.call(ProtocolValues.GAME_SENSOR_FINISH, null, gameworld.roomID);
			}
		}
		
		public function sensorAdditionalZone():void{
			GameApplication.app.callsmanager.call(ProtocolValues.GAME_SENSOR_ADDITIONAL_ZONE, null, gameworld.roomID);
		}
		
		public function userout():void{
		}
		
		public function userexit():void{
			GameApplication.app.callsmanager.call(ProtocolValues.GAME_USER_EXIT, null, gameworld.roomID);
		}
		
		public function endTestGame():void{
			exitGame();			
		}
	}
}