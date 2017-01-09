package app.room.gamebet;

import java.nio.channels.SocketChannel;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import app.Config;
import app.ServerApplication;
import app.room.game.GameRoom;
import app.user.UserConnection;
import app.user.UserGameStatus;
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

public class GameBetRoom extends GameRoom {
	
	public int bet;
	public int bank;
	public String passward;
	
	public GameBetRoom(int id, String title, int bet, String passward){
		super(id, title, 0);
		this.bet = bet;
		this.passward = passward;
		bank = 0;
		
		this.districtID = DistrictModel.DISTRICT5;
		
		durationtime = Config.waitTimeToStartBet();
	}	
	
	@Override
	public void removeUserByConnection(SocketChannel connection){
		if(!gameisover){
			UserConnection user = getUserByConnection(connection);			
			if (user != null){
				user.user.incommonroom = true;
				
				if (waitusers.size() > 0 && waitusers.get(Integer.toString(user.user.id)) != null){
					if(bank >= bet){
						bank -= bet;
						user.user.updateMoney(user.user.money + bet);
					}
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
						}
					}else{					
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
	public Boolean addwaituser(UserConnection u){
		if(waitusers.size() < Config.maxUsersInGame()){
			if (waitusers.get(Integer.toString(u.user.id)) == null){
				waitusers.put(Integer.toString(u.user.id), u);
				
				u.user.updateMoney(u.user.money - bet);
				bank += bet;
				
				ServerApplication.application.commonroom.changeUserInfoByID(u.user.id, ChangeInfoParams.USER_MONEY, u.user.money, 0);
			}else{
				return false;
			}
		}else{
			return false;
		}
		return true;
	}
	
	@Override
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
	
	@Override
	public void startGame(){
		timer.cancel();		
		
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
			action.gametype = GameType.BET;
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
				
				user.getValue().user.updateMoney( user.getValue().user.money + bet);
				ServerApplication.application.commonroom.changeUserInfoByID(user.getValue().user.id, ChangeInfoParams.USER_MONEY, user.getValue().user.money, 0);				
			}
			setWait = null;
			a = null;
			
			roomClear();
			ServerApplication.application.gamemanager.removeGameRoom(this);			
		}		
	}
	
	@Override
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
				jsonAction = JSONObjectBuilder.createObjGameActionFinish(GameActionType.FINISH_BET, this.id, -1);
				user.getValue().user.incommonroom = true;
				user.getValue().call(ProtocolValues.PROCESS_GAME_ACTION, jsonAction);
			}
		}
		set = null;		
		jsonAction = null;
		
		roomClear();
		ServerApplication.application.gamemanager.removeGameRoom(this);
	}
	
	@Override
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
						
					endGame();
				}
				initiatorConn.call(ProtocolValues.PROCESS_GAME_ACTION, JSONObjectBuilder.createObjGameAction(GameActionType.NEW_LAP, this.id));
			}
			initiatorConn = null;
		}
	}
	
	@Override
	public void calculateAndSendUserPrize(UserConnection user, int userPlace){
		ExtractionData extraction = new ExtractionData(0, 0);
		
		if(user != null){
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
			
			int komission = (int)Math.ceil(((float) bank * 0.12));
			extraction.money = bank - komission;
			
			user.user.updateMoney(user.user.money + extraction.money);
			
			changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY, user.user.money, 0);
			
			user.call(ProtocolValues.PROCESS_GAME_ACTION, JSONObjectBuilder.createObjGameActionFinishExtraction(GameActionType.FINISH_EXTRACTION, this.id, extraction, (byte)userPlace));
			extraction = null;
		}
	}
}
