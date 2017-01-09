package app.room.game;

import java.nio.channels.SocketChannel;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import app.Config;
import app.ServerApplication;
import app.clan.ClanDeposit;
import app.clan.ClanRole;
import app.message.MessageType;
import app.room.Room;
import app.user.GameInfo;
import app.user.UserConnection;
import app.user.UserGameStatus;
import app.user.VipType;
import app.utils.changeinfo.ChangeInfoParams;
import app.utils.extraction.ExtractionData;
import app.utils.gameaction.GameActionSubType;
import app.utils.gameaction.GameActionType;
import app.utils.gameaction.start.GameActionStart;
import app.utils.gameaction.start.GameType;
import app.utils.jsonobjectbuilder.JSONObjectBuilder;
import app.utils.map.DistrictModel;
import app.utils.protocol.ProtocolValues;
import atg.taglib.json.util.JSONObject;

public class GameRoom extends Room {
	public Map<String, UserConnection> waitusers;
	public Map<String, UserConnection> exitusers;
	public Map<Integer, Integer> finishedTimes;
	public Map<Integer, String> usersActions;
	public Map<Integer, Integer> usersLaps;
	public List<UserConnection> finishedusers;	
	private Map<Integer, ClanDeposit> clandeposits;
	
	public Timer timer;
	public int startCount = 0;
	public Date startTime;
	public boolean gameisover = false;
	public boolean gamestart = false;
	public GameRoom link;
	
	public int durationtime;
	public int roundtime = 0;
	public int roundlaps = 0;
	public int passedtime = 0;
	public int districtID = 0;
	
	public GameRoom(int id, String title, int districtID){
		super(id, title);
		
		this.districtID = districtID;
		
		link = this;
		finishedusers = new ArrayList<UserConnection>();
		exitusers = new ConcurrentHashMap<String, UserConnection>();
		waitusers = new ConcurrentHashMap<String, UserConnection>();
		finishedTimes = new ConcurrentHashMap<Integer, Integer>();
		usersActions = new ConcurrentHashMap<Integer, String>();
		usersLaps = new ConcurrentHashMap<Integer, Integer>();
		clandeposits = new ConcurrentHashMap<Integer, ClanDeposit>();
		
		durationtime = Config.waitTimeToStart();
		setTimerToStart();
	}
	
	public void setTimerToStart(){
		timer = new Timer();
		timer.schedule(new TimerToStart(), 1000, 1000);
	}
	
	public Boolean addwaituser(UserConnection u){	
		if(waitusers.size() < Config.maxUsersInGame()){
			if (waitusers.get(Integer.toString(u.user.id)) == null){
				waitusers.remove(Integer.toString(u.user.id));
			}
			
			waitusers.put(Integer.toString(u.user.id), u);	
			if (waitusers.size() == Config.maxUsersInGame()){
				startGame();
			}
		}else{
			return false;
		}
		return true;
	}
	
	public void startGame(){
		timer.cancel();
		ServerApplication.application.gamemanager.clearNewGameRoomByLevel(districtID);
		
		if (waitusers.size() >= Config.minUsersInGame()){
			Set<Entry<String, UserConnection>> setWait = waitusers.entrySet();
			for (Map.Entry<String, UserConnection> user:setWait){
				user.getValue().user.gameStatus = UserGameStatus.FINISH_ON;
				usersLaps.put(user.getValue().user.id, 0);
				
				addUser(user.getValue());
			}
			setWait = null;
			
			gamestart = true;
			waitusers.clear();
			startCount = users.size();
			
			GameActionStart action = createGameActionStart();		
			action.gametype = GameType.SIMPLE;
			roundtime = action.map.time;
			roundlaps = action.map.laps;
			
			JSONObject jsonAction = JSONObjectBuilder.createObjGameActionStart(action);
			setTimerToEnd();
			
			startTime = new Date();

			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				user.getValue().user.incommonroom = false;
				usersActions.put(user.getValue().user.id, "");
				
				if(user.getValue().user.activeCar != null){
					if(user.getValue().user.activeCar.rented == 0){
						user.getValue().user.activeCar.durability--;
						user.getValue().user.activeCar.changed = true;
					}
				}
				
				user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);
			}
			set = null;
			action = null;
			jsonAction = null;
		}else{
			JSONObject a = JSONObjectBuilder.createObjGameAction(GameActionType.NOT_ENOUGH_USERS, this.id);
			Set<Entry<String, UserConnection>> setWait = waitusers.entrySet();
			for (Map.Entry<String, UserConnection> user:setWait){
				user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, a);					
			}
			setWait = null;
			a = null;
			
			roomClear();
			ServerApplication.application.gamemanager.removeGameRoom(this);			
		}		
	}
	
	public void on5SecondPassed(){
		JSONObject jsonAction = null;
		jsonAction = JSONObjectBuilder.createObjGameAction(GameActionType.PASSED_5_SECOND, this.id);
				
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){
			if(user.getValue().connection.isConnected()){
				user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);
			}
		}
		set = null;
		jsonAction = null;
	}
	
	
	public void setTimerToEnd(){
		passedtime = 0;
		timer = new Timer();
		timer.schedule(new TimerToEnd(), 1000, 1000);
	}
	
	public void endGame(){
		if (timer != null){
			timer.cancel();
		}
		timer = null;		
		gameisover = true;
		
		JSONObject jsonAction;
		
		for(int i = 0; i < finishedusers.size(); i++){
			UserConnection fuser = null;
			if(i < finishedusers.size()){
				fuser = finishedusers.get(i);
			}
			if(fuser != null){
				jsonAction = JSONObjectBuilder.createObjGameActionFinish(GameActionType.FINISH, this.id, i + 1);
				fuser.user.incommonroom = true;
				fuser.call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);
				
				if (fuser != null && fuser.connection.isConnected()){
					removeUserByConnection(fuser.connection);
				}
				fuser = null;
			}
		}
		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){
			if (exitusers.get(Integer.toString(user.getValue().user.id)) == null){
				user.getValue().user.updateExperience(user.getValue().user.experience - 2);
				changeUserInfoByID(user.getValue().user.id, ChangeInfoParams.USER_EXPERIENCE, user.getValue().user.experience, 0);
				
				jsonAction = JSONObjectBuilder.createObjGameActionFinish(GameActionType.FINISH, this.id, -1);
				user.getValue().user.incommonroom = true;
				user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);
			}
		}
		set = null;		
		jsonAction = null;
		
		ServerApplication.application.clanmanager.updateClanDeposits(clandeposits);
		clandeposits.clear();
		clandeposits = null;
		
		roomClear();
		ServerApplication.application.gamemanager.removeGameRoom(this);
	}
	
	public void calculateAndSendUserPrize(UserConnection user, int userPlace){
		double districtK = 1;
		if(districtID == DistrictModel.DISTRICT1){
			districtK = 0.8;
		}else if(districtID == DistrictModel.DISTRICT2){
			districtK = 1.6;
		}else if(districtID == DistrictModel.DISTRICT4){
			districtK = 1;
		}
		double koef = (double) districtK * startCount / Config.maxUsersInGame();
		
		int currentMoneyPrize = Config.moneyPrize() - (userPlace - 1) * 5;
		int currentExperiencePrize = (int) Math.round((double) 10 * koef - (userPlace - 1) * Config.experiencePrizeDelta());
		
		ExtractionData extraction = new ExtractionData(0, 0);
		
		if(user != null){
			if(userPlace < 4){
				if(finishedTimes.get(user.user.id) <= 5){
					ServerApplication.application.userinfomanager.addToCheaterList(user, 1);
					return;
				} 
				String fuserActions = usersActions.get(user.user.id);
				if(fuserActions != null && fuserActions.length()  > 0){
					if(fuserActions.equals(user.user.previosWinGameActions)){
						ServerApplication.application.userinfomanager.addToCheaterList(user, 2);
						return;
					}
					user.user.previosWinGameActions = fuserActions;
				}else{
					ServerApplication.application.userinfomanager.addToCheaterList(user, 3);
					return;
				}
			}
			
			if (currentExperiencePrize > 0){					
				extraction.experience = currentExperiencePrize;
				
				int moneyPrize = 0;					
				int experiencebonus = 0;
				int cexperiencebonus = 0;				
				
				if(user.user.vip == VipType.VIP_BRONZE){
					experiencebonus += 2;
					cexperiencebonus += 0;
				}else if(user.user.vip == VipType.VIP_SILVER){
					experiencebonus += 3;
					cexperiencebonus += 1;
				}else if(user.user.vip == VipType.VIP_GOLD){
					experiencebonus += 4;
					cexperiencebonus += 1;
				}
				extraction.experiencebonus = experiencebonus;
				extraction.cexperiencebonus = cexperiencebonus;
				
				user.user.updateExperience(user.user.experience + extraction.experience + extraction.experiencebonus);
				
				double koefMoney = (double) userPlace / startCount;
				if (Math.round((double) (100 * koefMoney)) <= Config.percentMoneyUsers() && currentMoneyPrize > 0){
					moneyPrize = currentMoneyPrize;
					
					if(user.user.claninfo.clanid > 0 && user.user.claninfo.clanrole != ClanRole.INVITED){
						extraction.cexperience = 1;
						if (clandeposits.get(user.user.claninfo.clanid) == null){
							ClanDeposit deposit = new ClanDeposit();
							deposit.depositm += 1;
							deposit.deposite += (1 + extraction.cexperiencebonus);
							clandeposits.put(user.user.claninfo.clanid, deposit);
							deposit = null;
						}else{
							clandeposits.get(user.user.claninfo.clanid).depositm += 1;
							clandeposits.get(user.user.claninfo.clanid).deposite += (1 + extraction.cexperiencebonus);
						}
						user.user.updateMoney(user.user.money + moneyPrize + extraction.moneybonus, 1, (1 + extraction.cexperiencebonus));										
					}else{
						user.user.updateMoney(user.user.money + moneyPrize + extraction.moneybonus);
					}
				}
				extraction.money = moneyPrize;
				changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_EXPERIENCE, user.user.money, user.user.experience);
			}
			
			user.call(ProtocolValues.PROCESS_GAME_ACTION, JSONObjectBuilder.createObjGameActionFinishExtraction(GameActionType.FINISH_EXTRACTION, this.id, extraction, (byte)userPlace));
			extraction = null;
		}
	}
	
	public GameActionStart createGameActionStart(){
		List<Integer> gameusers = new ArrayList<Integer>();
		List<Integer> userscars = new ArrayList<Integer>();
		List<Integer> carscolors = new ArrayList<Integer>();
		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){
			gameusers.add(user.getValue().user.id);
			
			if(user.getValue().user.activeCar != null){
				userscars.add(user.getValue().user.activeCar.prototype.id);
				carscolors.add(user.getValue().user.activeCar.color);
			}
		}
		
        GameActionStart action = new GameActionStart(GameActionType.START, this.id);
        
        action.map = ServerApplication.application.gamemanager.mapsModel.getRandomMap();
        action.districtID = districtID;
        action.users = gameusers;
        action.usersCars = userscars;
        action.carsColors = carscolors;
        action.gametype = GameType.SIMPLE;
                     
        gameusers = null;
        userscars = null;
        carscolors = null;
        
        return action;
	}
	
	@Override
	public void removeUserByConnection(SocketChannel connection){
		if(!gameisover){
			UserConnection user = getUserByConnection(connection);			
			if (user != null){
				user.user.incommonroom = true;
				
				if (waitusers.size() > 0){
					waitusers.remove(Integer.toString(user.user.id));
				}else{
					boolean infinish = false;
					for( int i = 0; i < finishedusers.size(); i ++){
						if (finishedusers.get(i).user.id == user.user.id){
							infinish = true;
						}
					}
					if (!infinish){
						if (exitusers.get(Integer.toString(user.user.id)) == null){
							exitusers.put(Integer.toString(user.user.id), user);
							
							user.user.updateExperience(user.user.experience - 2);
							if(user.connection != null && user.connection.isConnected()){
								changeUserInfoByID(user.user.id, ChangeInfoParams.USER_EXPERIENCE, user.user.experience, 0);
							}
						}
					}
					
					if (finishedusers.size() + exitusers.size() == users.size()){
						endGame();
					}
				}
			}
			user = null;
		}else{
			super.removeUserByConnection(connection);
		}		
    }	
	
	@Override
	public UserConnection getUserByConnection(SocketChannel connection){
		String userID = userConnectionIDtoID.get(connection);
		if (userID != null && userID != "null"){
			return users.get(userID);
		}else{
			Set<Entry<String, UserConnection>> setWait = waitusers.entrySet();
			for (Map.Entry<String, UserConnection> user:setWait){				
				if(user.getValue().connection == connection){
					return user.getValue();
				}				
			}
			setWait = null;
		}
		return null;
	}
	
	@Override
	public void roomClear(){
		waitusers.clear();
		finishedusers.clear();
		exitusers.clear();
		usersActions.clear();
		usersLaps.clear();
		finishedTimes.clear();
		link = null;
		if(timer != null){
			timer.cancel();
		}
		timer = null;
		
		super.roomClear();
    }
	
	@Override
	public void addUser(UserConnection u){
		users.put(Integer.toString(u.user.id), u);
		if (u.connection != null && u.connection.isConnected()){
			userConnectionIDtoID.put(u.connection, Integer.toString(u.user.id));
		}
		userSocialIDtoID.put(u.user.idSocial, Integer.toString(u.user.id));
		
		JSONObject jsonMessage = JSONObjectBuilder.createObjMessageStatusGame(MessageType.USER_IN, this, GameInfo.createFromUser(u.user));
		List<GameInfo> usersinroom = new ArrayList<GameInfo>();
		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){
			usersinroom.add(GameInfo.createFromUser(user.getValue().user));
			if(user.getValue().user.id != u.user.id){
				user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);					
			}
		}
		
		jsonMessage = null;
		jsonMessage = JSONObjectBuilder.createObjMessageStatusGame(MessageType.USER_IN, this, GameInfo.createFromUser(u.user), messages, usersinroom);
		
		u.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
		
		usersinroom = null;
		jsonMessage = null;
	}
	
	class TimerToStart extends TimerTask{
        public void run(){        	
        	passedtime++;
        	if (passedtime >= durationtime){
        		startGame();
        	}
         }  
     }
	class TimerToEnd extends TimerTask{
        public void run(){
        	passedtime++;
        	if (passedtime == 5){
        		on5SecondPassed();
        	}
        	if (passedtime >= roundtime){
        		endGame();
        	}
        }
    }
	
	/*
	 * ОБРАБОТЧИКИ ПОЛЬЗОВАТЯЕЛЬСКИХ СОБЫТИЙ
	 */
	public void left(SocketChannel connection, Boolean down, double userx, double usery, double rotation, String linerVelocity){
		UserConnection initiator = getUserByConnection(connection);
		if(initiator != null){
			String initiatorActions = usersActions.get(initiator.user.id);
			if(initiatorActions != null && initiatorActions.length() < 100){
				initiatorActions += GameActionSubType.GOTOLEFT;
				usersActions.put(initiator.user.id, initiatorActions);
			}
			
			JSONObject jsonAction = JSONObjectBuilder.createObjGameActionMotion(GameActionType.ACTION, this.id, GameActionSubType.GOTOLEFT, initiator.user.id, down, userx, usery, rotation, linerVelocity);
		
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				if(user.getValue().user.id != initiator.user.id){
					user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);					
				}
			}
			set = null;
			initiator = null;
			jsonAction = null;
		}
	}
	
	public void right(SocketChannel connection, Boolean down, double userx, double usery, double rotation, String linerVelocity){
		UserConnection initiator = getUserByConnection(connection);
		if(initiator != null){
			String initiatorActions = usersActions.get(initiator.user.id);
			if(initiatorActions != null && initiatorActions.length() < 100){
				initiatorActions += GameActionSubType.GOTORIGHT;
				usersActions.put(initiator.user.id, initiatorActions);
			}
			
			JSONObject jsonAction = JSONObjectBuilder.createObjGameActionMotion(GameActionType.ACTION, this.id, GameActionSubType.GOTORIGHT, initiator.user.id, down, userx, usery, rotation, linerVelocity);		
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				if(user.getValue().user.id != initiator.user.id){
					user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);
				}
			}
			set = null;
			initiator = null;
			jsonAction = null;
		}
	}
	
	public void forward(SocketChannel connection, Boolean down, double userx, double usery, double rotation, String linerVelocity){
		UserConnection initiator = getUserByConnection(connection);
		if(initiator != null){
			String initiatorActions = usersActions.get(initiator.user.id);
			if(initiatorActions != null && initiatorActions.length() < 100){
				initiatorActions += GameActionSubType.FORWARD;
				usersActions.put(initiator.user.id, initiatorActions);
			}
			
			JSONObject jsonAction = JSONObjectBuilder.createObjGameActionMotion(GameActionType.ACTION, this.id, GameActionSubType.FORWARD, initiator.user.id, down, userx, usery, rotation, linerVelocity);		
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				if(user.getValue().user.id != initiator.user.id){
					user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);					
				}
			}
			set = null;			
			initiator = null;
			jsonAction = null;
		}
	}
	
	public void back(SocketChannel connection, Boolean down, double userx, double usery, double rotation, String linerVelocity){
		UserConnection initiator = getUserByConnection(connection);
		if(initiator != null){
			String initiatorActions = usersActions.get(initiator.user.id);
			if(initiatorActions != null && initiatorActions.length() < 100){
				initiatorActions += GameActionSubType.BACK;
				usersActions.put(initiator.user.id, initiatorActions);
			}
			
			JSONObject jsonAction = JSONObjectBuilder.createObjGameActionMotion(GameActionType.ACTION, this.id, GameActionSubType.BACK, initiator.user.id, down, userx, usery, rotation, linerVelocity);		
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				if(user.getValue().user.id != initiator.user.id){
					user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);					
				}
			}
			set = null;			
			initiator = null;
			jsonAction = null;
		}
	}
	
	public void brake(SocketChannel connection, Boolean down, double userx, double usery, double rotation, String linerVelocity){
		UserConnection initiator = getUserByConnection(connection);
		if(initiator != null){
			String initiatorActions = usersActions.get(initiator.user.id);
			if(initiatorActions != null && initiatorActions.length() < 100){
				initiatorActions += GameActionSubType.BRAKE;
				usersActions.put(initiator.user.id, initiatorActions);
			}
			
			JSONObject jsonAction = JSONObjectBuilder.createObjGameActionMotion(GameActionType.ACTION, this.id, GameActionSubType.BRAKE, initiator.user.id, down, userx, usery, rotation, linerVelocity);		
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				if(user.getValue().user.id != initiator.user.id){
					user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);					
				}
			}
			set = null;			
			initiator = null;
			jsonAction = null;
		}
	}
	
	public void sensorStart(SocketChannel connection){
		UserConnection initiatorConn = getUserByConnection(connection);
		if (initiatorConn != null){
			if(initiatorConn.user.gameStatus == UserGameStatus.FINISH_ON){
				initiatorConn.user.gameStatus = UserGameStatus.START_ON;
			}
			initiatorConn = null;
		}
	}
	
	public void sensorAdditionalZone(SocketChannel connection){
		UserConnection initiatorConn = getUserByConnection(connection);
		if (initiatorConn != null){
			if(initiatorConn.user.gameStatus == UserGameStatus.START_ON){
				initiatorConn.user.gameStatus = UserGameStatus.ADDITIONAL_ZONE_ON;
			}else{
				initiatorConn.call(ProtocolValues.PROCESS_GAME_ACTION, JSONObjectBuilder.createObjGameAction(GameActionType.RETURN_TO_START, this.id));
			}
			initiatorConn = null;
		}
	}
	
	public void sensorFinish(SocketChannel connection){
		UserConnection initiatorConn = getUserByConnection(connection);
		if (initiatorConn != null){
			if(initiatorConn.user.gameStatus == UserGameStatus.ADDITIONAL_ZONE_ON){
				initiatorConn.user.gameStatus = UserGameStatus.FINISH_ON;
				
				int laps = usersLaps.get(initiatorConn.user.id) + 1;
				usersLaps.put(initiatorConn.user.id, laps);
				
				if(laps >= roundlaps)
				{
					finishedTimes.put(initiatorConn.user.id, passedtime);
					finishedusers.add(initiatorConn);
					
					JSONObject jsonAction = JSONObjectBuilder.createObjGameActionEvent(GameActionType.ACTION, this.id, GameActionSubType.FINISH, initiatorConn.user.id, initiatorConn.user.title, (byte)finishedusers.size());
					
					Set<Entry<String, UserConnection>> set = users.entrySet();
					for (Map.Entry<String, UserConnection> user:set){
						user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);
					}
					set = null;
					jsonAction = null;
					
					calculateAndSendUserPrize(initiatorConn, finishedusers.size());
						
					if (finishedusers.size() + exitusers.size() == users.size()){					
						endGame();
					}
				}
				initiatorConn.call(ProtocolValues.PROCESS_GAME_ACTION, JSONObjectBuilder.createObjGameAction(GameActionType.NEW_LAP, this.id));
			}
			initiatorConn = null;
		}
	}
	
	public void userExit(SocketChannel connection){
		removeUserByConnection(connection);
	}
}
