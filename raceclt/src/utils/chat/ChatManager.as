package utils.chat
{
	import application.GameApplication;
	import application.components.popup.claninviteme.PopUpClanInviteMe;
	import application.components.popup.moneyPrize.PopUpMoneyPrize;
	import application.components.popup.help.tutorial.fist.PopUpTutorialFirst;
	import application.components.popup.newlevel.PopUpNewLevel;
	
	import flash.events.EventDispatcher;
	
	import utils.chat.message.MessageType;
	import utils.chat.room.Room;
	import utils.protocol.ProtocolKeys;
	import utils.user.ClanUserRole;
	import utils.user.User;

	public class ChatManager extends EventDispatcher
	{		
		public var commonroom:Room;
		
		public function ChatManager()
		{
		}
		
		public function exitGame():void{
			GameApplication.app.gameContainer.chat.closeRooms();
			commonroom = null;
			GameApplication.app.gameContainer.chat.activeRoom = null;
		}
		
		public function processMassage(message:Object):void{
			var room:Room = GameApplication.app.gameContainer.chat.getRoom(message[ProtocolKeys.ROOM_ID]);			
			if (message[ProtocolKeys.TYPE] == MessageType.USER_IN){
				if (message[ProtocolKeys.INITIATOR][ProtocolKeys.ID] == GameApplication.app.userinfomanager.myuser.id){	
					room = new Room(message[ProtocolKeys.ROOM_ID], message[ProtocolKeys.ROOM_TITLE], message[ProtocolKeys.USERS], message[ProtocolKeys.MESSAGES]);
					GameApplication.app.gameContainer.chat.addRoom(room);
					if(commonroom == null && message[ProtocolKeys.ROOM_ID] == Room.COMMON){
						commonroom = room;
					}
					GameApplication.app.gameContainer.chat.activeRoom = room;
				}else{					
					if (room) {
						room.addUser(message[ProtocolKeys.INITIATOR]);
					} else {
						//Alert.show("Пользователь вошел в несуществующую комнату!", "Ошибка");
					}					
				}
			}else if (message[ProtocolKeys.TYPE] == MessageType.USER_OUT){
				if (message[ProtocolKeys.INITIATOR_ID] == GameApplication.app.userinfomanager.myuser.id){
					if(room){						
						GameApplication.app.gameContainer.chat.removeRoom(room);					
					}
				}else{
					if (room) {
						room.removeUser(message[ProtocolKeys.INITIATOR_ID]);
					} else {
						//Alert.show("Пользователь вышел из несуществующей комнаты!", "Ошибка");
					}					
				}
			}else if (message[ProtocolKeys.TYPE] == MessageType.MESSAGE || message[ProtocolKeys.TYPE] == MessageType.BAN || message[ProtocolKeys.TYPE] == MessageType.BAN_OUT || message[ProtocolKeys.TYPE] == MessageType.SYSTEM || message[ProtocolKeys.TYPE] == MessageType.PRESENT) {
				if(room){
					room.addMessage(message, true);
				}else{					
					var proom : Room = GameApplication.app.gameContainer.chat.getRoom(message[ProtocolKeys.ROOM_ID]);
					if(proom){
						proom.addMessage(message, true);
					}else{
						//Alert.show("Нет комнаты " + message[roomId] + ". Cообщиете об ошибке разработчикам!", "Ошибка");
					}
				}
			}else if (message[ProtocolKeys.TYPE] == MessageType.PRIVATE){
				if(!GameApplication.app.models.settings.privateMessagesVisible){
					return;
				}
				GameApplication.app.gameContainer.chat.addPrivateMessage(message);
			}else if (message[ProtocolKeys.TYPE] == MessageType.CHANGEINFO) {					
				GameApplication.app.userinfomanager.changeMyParams(message);
			}else if (message[ProtocolKeys.TYPE] == MessageType.CLAN_INVITE){
				GameApplication.app.popuper.show(new PopUpClanInviteMe(message[ProtocolKeys.CLAN_INFO][ProtocolKeys.OWNER_TITLE], message[ProtocolKeys.CLAN_INFO][ProtocolKeys.TITLE]));
			}else if (message[ProtocolKeys.TYPE] == MessageType.CLAN_KICK){
				GameApplication.app.userinfomanager.myuser.claninfo.clanid = 0;
				GameApplication.app.userinfomanager.myuser.claninfo.clandeposite = 0;
				GameApplication.app.userinfomanager.myuser.claninfo.clandepositm = 0;
				GameApplication.app.userinfomanager.myuser.claninfo.clanrole = ClanUserRole.NO_ROLE;
				GameApplication.app.popuper.showInfoPopUp("Вас выгнали из клуба.");
			}else if (message[ProtocolKeys.TYPE] == MessageType.NEW_LEVEL) {				
				GameApplication.app.popuper.show(new PopUpNewLevel(message[ProtocolKeys.LEVEL], message[ProtocolKeys.PRIZE]));
			}else if (message[ProtocolKeys.TYPE] == MessageType.BEST_HOUR) {				
				GameApplication.app.popuper.show(new PopUpMoneyPrize(message[ProtocolKeys.PRIZE], "Вы лучший игрок за час!", true));
			}else if (message[ProtocolKeys.TYPE] == MessageType.BEST_DAY){
				GameApplication.app.popuper.show(new PopUpMoneyPrize(message[ProtocolKeys.PRIZE], "Вы лучший игрок за день!", true));
			}else if (message[ProtocolKeys.TYPE] == MessageType.START_INFO) {
				GameApplication.app.popuper.show(new PopUpTutorialFirst());
			}else if (message[ProtocolKeys.TYPE] == MessageType.USER_NOT_FIND) {
				if(room){
					room.addMessage(message, true);
				}
			}else if (message[ProtocolKeys.TYPE] == MessageType.ONLINE_COUNT) {
				GameApplication.app.models.onlineUsersCount = int(message[ProtocolKeys.COUNT]);
			}
		}
	}
}