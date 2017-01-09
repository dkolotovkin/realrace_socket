package app.game;

import java.nio.channels.SocketChannel;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import app.Config;
import app.ServerApplication;
import app.room.Room;
import app.room.game.GameRoom;
import app.room.gamebet.GameBetRoom;
import app.room.gamebet.GameBetRoomInfo;
import app.shop.car.CarModel;
import app.user.UserConnection;
import app.utils.gameaction.GameActionType;
import app.utils.gameaction.start.GameActionStartRequestCode;
import app.utils.jsonobjectbuilder.JSONObjectBuilder;
import app.utils.jsonutil.JSONUtil;
import app.utils.map.DistrictModel;
import app.utils.map.MapsModel;
import app.utils.protocol.ProtocolKeys;
import app.utils.random.RoomRandom;
import atg.taglib.json.util.JSONObject;

public class GameManager{
	public static Map<String, String> maps;
	public static Map<String, Integer> mapslaps;
	public static Map<String, String> mapscreators;
	public static Map<String, GameRoom> gamerooms;
	
	public static GameRoom district1Game;
	public static GameRoom district2Game;
	public static GameRoom district3Game;
	public static GameRoom district4Game;
	public static GameRoom district5Game;
	
	public MapsModel mapsModel;
	
	public GameManager(){
		gamerooms = new ConcurrentHashMap<String, GameRoom>();
		mapsModel = new MapsModel();
	}
	
	/*
	 * ОБЫЧНАЯ ИГРА
	 * 
	 */
	
	public void gameStartRequest(SocketChannel connection, JSONObject params){
		int carId = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
		int districtId = JSONUtil.getInt(params, ProtocolKeys.PARAM2);
		
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		int startRequesCode = GameActionStartRequestCode.UNDEFINED;
		boolean added = false;
		
		if(user != null && !checkUserInGame(user.user.id)){
			CarModel userCar = user.user.cars.get(carId);
			if(userCar != null){
				if(userCar.rented == 0 || userCar.checkRentedTime()){
					user.user.activeCar = userCar;
					if(userCar.durability > 0){
						if(districtId == DistrictModel.DISTRICT1){
							if(userCar.prototype.carClass == 1 || userCar.prototype.carClass == 2){
								if(district1Game == null){
									district1Game = new GameRoom(RoomRandom.getRoomID(), "Игра", districtId);
									gamerooms.put(Integer.toString(district1Game.id), district1Game);
									added = district1Game.addwaituser(user);				
								}else{
									added = district1Game.addwaituser(user);
								}
							}else{
								startRequesCode = GameActionStartRequestCode.ERROR_DISTRICT;
							}
						}else if(districtId == DistrictModel.DISTRICT2){
							if(userCar.prototype.carClass == 3 || userCar.prototype.carClass == 4){
								if(district2Game == null){
									district2Game = new GameRoom(RoomRandom.getRoomID(), "Игра", districtId);
									gamerooms.put(Integer.toString(district2Game.id), district2Game);
									added = district2Game.addwaituser(user);				
								}else{
									added = district2Game.addwaituser(user);
								}
							}else{
								startRequesCode = GameActionStartRequestCode.ERROR_DISTRICT;
							}
						}else if(districtId == DistrictModel.DISTRICT3){
						}else if(districtId == DistrictModel.DISTRICT4){
							if(district4Game == null){
								district4Game = new GameRoom(RoomRandom.getRoomID(), "Игра", districtId);
								gamerooms.put(Integer.toString(district4Game.id), district4Game);
								added = district4Game.addwaituser(user);				
							}else{
								added = district4Game.addwaituser(user);
							}
						}else if(districtId == DistrictModel.DISTRICT5){
						}else{
							startRequesCode = GameActionStartRequestCode.ERROR_DISTRICT_UNDEFINED;
						}
					}else{
						startRequesCode = GameActionStartRequestCode.ERROR_CAR_DURABILITY;
					}
				}else{
					startRequesCode = GameActionStartRequestCode.UNDEFINED;
				}
			}else{
				startRequesCode = GameActionStartRequestCode.ERROR_CAR_UNDEFINED;
			}
			userCar = null;
		}	
		user = null;

		if(added){
			startRequesCode = GameActionStartRequestCode.OK;
		}
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjGameActionWaitStart(GameActionType.WAIT_START, 0, Config.waitTimeToStart(), startRequesCode));
		return;
	}
	
	/*
	 * ИГРА НА ДЕНЬГИ
	 */

	public void gameCreateBetGame(SocketChannel connection, JSONObject params){
		int bet = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
		String pass = JSONUtil.getString(params, ProtocolKeys.PARAM2);
		if(pass == null)
			pass = "";
		
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		boolean added = false;
		int startRequesCode = GameActionStartRequestCode.UNDEFINED;
		
		if(user.user.money >= bet && bet > 0){
			GameBetRoom room = new GameBetRoom(RoomRandom.getRoomID(), "Игра", bet, pass);				
			gamerooms.put(Integer.toString(room.id), room);
			added = room.addwaituser(user);
		}else{
			startRequesCode = GameActionStartRequestCode.ERROR_NOT_ENOUGH_MONEY;
			added = false;
		}
		user = null;
		
		if(added){
			startRequesCode = GameActionStartRequestCode.OK;
		}
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjGameActionWaitStart(GameActionType.WAIT_START, 0, Config.waitTimeToStartBet(), startRequesCode));
		return;
	}

	public void gameAddToBetGame(SocketChannel connection, JSONObject params){
		int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
		String pass = JSONUtil.getString(params, ProtocolKeys.PARAM2);
		if(pass == null) pass = "";
		
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);		
		boolean added = false;
		int startRequesCode = GameActionStartRequestCode.UNDEFINED;
		
		int waittime = Config.waitTimeToStartBet();
		if(user != null){
			GameRoom gbr = gamerooms.get(Integer.toString(roomID));
			if (gbr != null && (gbr instanceof GameBetRoom)){
				if(user.user.money >= ((GameBetRoom) gbr).bet){
					if(!((GameBetRoom) gbr).passward.equals(pass)){
						startRequesCode = GameActionStartRequestCode.ERROR_BAD_PASSWARD;
						added = false;
					}else{
						waittime = ((GameBetRoom) gbr).durationtime - ((GameBetRoom) gbr).passedtime;
						if(waittime > 5 && !gbr.gamestart){
							added = gbr.addwaituser(ServerApplication.application.commonroom.getUserByConnection(connection));
							if (!added){
								startRequesCode = GameActionStartRequestCode.ERROR_NO_SEATS;
								added = false;
							}
						}else{
							startRequesCode = GameActionStartRequestCode.ERROR_NO_ROOM;
							added = false;
						}
					}					
				}else{
					startRequesCode = GameActionStartRequestCode.ERROR_NOT_ENOUGH_MONEY;
					added = false;
				}
			}else{
				startRequesCode = GameActionStartRequestCode.ERROR_NO_ROOM;
				added = false;
			}		
		}
		user = null;
		
		if(added){
			startRequesCode = GameActionStartRequestCode.OK;
		}
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjGameActionWaitStart(GameActionType.WAIT_START, 0, waittime, startRequesCode));
		return;
	}

	public void gameGetBetGamesInfo(SocketChannel connection, JSONObject params){
		List<GameBetRoomInfo> rooms = new ArrayList<GameBetRoomInfo>();
		Set<Entry<String, GameRoom>> setroom = gamerooms.entrySet();
		for (Map.Entry<String, GameRoom> room:setroom){
			GameRoom gr = room.getValue();
			if(gr instanceof GameBetRoom){
				
				List<String> gameusers = new ArrayList<String>();
				Set<Entry<String, UserConnection>> set = gr.waitusers.entrySet();
				for (Map.Entry<String, UserConnection> user:set){
					gameusers.add(user.getValue().user.title);
				}	
				set = null;
				
				boolean rlocked = false;
				if(((GameBetRoom) gr).passward != null && ((GameBetRoom) gr).passward.length() > 0){
					rlocked = true;
				}
				
				rooms.add(new GameBetRoomInfo(((GameBetRoom)gr).id, ((GameBetRoom)gr).bet, ((GameBetRoom)gr).durationtime - ((GameBetRoom)gr).passedtime, rlocked, ((GameBetRoom)gr).waitusers.size() < Config.maxUsersInGame(), gameusers));
				gameusers = null;
			}
			gr = null;
		}
		setroom = null;

		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), ProtocolKeys.ROOMS, JSONObjectBuilder.createObjGameBetRoomInfoList(rooms));
		return;
	}
	
	public boolean checkUserInGame(int userid){
		Set<Entry<String, GameRoom>> set = gamerooms.entrySet();
		for (Map.Entry<String, GameRoom> room:set){
			if(room.getValue().waitusers.get(Integer.toString(userid)) != null) return true;
		}
		return false;
	}
	
	public void clearNewGameRoomByLevel(int districtId){
		if(districtId == 1){
			district1Game = null;
		}else if(districtId == 2){
			district2Game = null;
		}else if(districtId == 3){
			district3Game = null;
		}else if(districtId == 4){
			district4Game = null;
		}else if(districtId == 5){
			district5Game = null;
		}
	}	
	
	public void removeGameRoom(Room room){
		gamerooms.remove(Integer.toString(room.id));
    }
	
	public void gameLeft(SocketChannel connection, JSONObject params){
    	int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	boolean down = JSONUtil.getBoolean(params, ProtocolKeys.PARAM2);
    	double userx = JSONUtil.getDouble(params, ProtocolKeys.PARAM3);
    	double usery = JSONUtil.getDouble(params, ProtocolKeys.PARAM4);
    	double rotation = JSONUtil.getDouble(params, ProtocolKeys.PARAM5);
    	String linerVelocity = JSONUtil.getString(params, ProtocolKeys.PARAM6);
    	
		GameRoom gameroom = gamerooms.get(Integer.toString(roomID));
		if (gameroom != null){
			gameroom.left(connection, down, userx, usery, rotation, linerVelocity);
		}
		gameroom = null;
	}
	
	public void gameRight(SocketChannel connection, JSONObject params){
    	int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	boolean down = JSONUtil.getBoolean(params, ProtocolKeys.PARAM2);
    	double userx = JSONUtil.getDouble(params, ProtocolKeys.PARAM3);
    	double usery = JSONUtil.getDouble(params, ProtocolKeys.PARAM4);
    	double rotation = JSONUtil.getDouble(params, ProtocolKeys.PARAM5);
    	String linerVelocity = JSONUtil.getString(params, ProtocolKeys.PARAM6);
    	
		GameRoom gameroom = gamerooms.get(Integer.toString(roomID));
		if (gameroom != null){
			gameroom.right(connection, down, userx, usery, rotation, linerVelocity);
		}
		gameroom = null;
	}	
	
	public void gameForward(SocketChannel connection, JSONObject params){
    	int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	boolean down = JSONUtil.getBoolean(params, ProtocolKeys.PARAM2);
    	double userx = JSONUtil.getDouble(params, ProtocolKeys.PARAM3);
    	double usery = JSONUtil.getDouble(params, ProtocolKeys.PARAM4);
    	double rotation = JSONUtil.getDouble(params, ProtocolKeys.PARAM5);
    	String linerVelocity = JSONUtil.getString(params, ProtocolKeys.PARAM6);
    	
		GameRoom gameroom = gamerooms.get(Integer.toString(roomID));
		if (gameroom != null){
			gameroom.forward(connection, down, userx, usery, rotation, linerVelocity);
		}
		gameroom = null;
	}
	
	public void gameBack(SocketChannel connection, JSONObject params){
    	int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	boolean down = JSONUtil.getBoolean(params, ProtocolKeys.PARAM2);
    	double userx = JSONUtil.getDouble(params, ProtocolKeys.PARAM3);
    	double usery = JSONUtil.getDouble(params, ProtocolKeys.PARAM4);
    	double rotation = JSONUtil.getDouble(params, ProtocolKeys.PARAM5);
    	String linerVelocity = JSONUtil.getString(params, ProtocolKeys.PARAM6);
    	
		GameRoom gameroom = gamerooms.get(Integer.toString(roomID));
		if (gameroom != null){
			gameroom.back(connection, down, userx, usery, rotation, linerVelocity);
		}
		gameroom = null;
	}
	
	public void gameBrake(SocketChannel connection, JSONObject params){
    	int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	boolean down = JSONUtil.getBoolean(params, ProtocolKeys.PARAM2);
    	double userx = JSONUtil.getDouble(params, ProtocolKeys.PARAM3);
    	double usery = JSONUtil.getDouble(params, ProtocolKeys.PARAM4);
    	double rotation = JSONUtil.getDouble(params, ProtocolKeys.PARAM5);
    	String linerVelocity = JSONUtil.getString(params, ProtocolKeys.PARAM6);
    	
		GameRoom gameroom = gamerooms.get(Integer.toString(roomID));
		if (gameroom != null){
			gameroom.brake(connection, down, userx, usery, rotation, linerVelocity);
		}
		gameroom = null;
	}
	
	public void gameSensorStart(SocketChannel connection, JSONObject params){
		int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
		GameRoom gameroom = gamerooms.get(Integer.toString(roomID));;
		if (gameroom != null){
			gameroom.sensorStart(connection);
		}
		gameroom = null;
	}
	
	public void gameSensorFinish(SocketChannel connection, JSONObject params){
		int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
		GameRoom gameroom = gamerooms.get(Integer.toString(roomID));;
		if (gameroom != null){
			gameroom.sensorFinish(connection);
		}
		gameroom = null;
	}
	
	public void gameSensorAdditionalZone(SocketChannel connection, JSONObject params){
		int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
		GameRoom gameroom = gamerooms.get(Integer.toString(roomID));;
		if (gameroom != null){
			gameroom.sensorAdditionalZone(connection);
		}
		gameroom = null;
	}
	
	public void gameUserExit(SocketChannel connection, JSONObject params){
    	int roomID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
		GameRoom gameroom = gamerooms.get(Integer.toString(roomID));;
		if (gameroom != null){
			gameroom.userExit(connection);
		}
		gameroom = null;
	}
}
