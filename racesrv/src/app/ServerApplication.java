package app;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.SocketChannel;
import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.apache.commons.dbcp.ConnectionFactory;
import org.apache.commons.dbcp.DriverManagerConnectionFactory;
import org.apache.commons.dbcp.PoolableConnectionFactory;
import org.apache.commons.dbcp.PoolingDataSource;
import org.apache.commons.pool.impl.GenericObjectPool;

import app.admin.AdministratorManager;
import app.clan.ClanManager;
import app.clan.ClanRole;
import app.clan.ClanUserInfo;
import app.db.DataBaseConfig;
import app.game.GameManager;
import app.logger.MyLogger;
import app.quests.QuestsManager;
import app.room.Room;
import app.room.common.CommonRoom;
import app.shop.ShopManager;
import app.user.UserConnection;
import app.user.UserLoginMode;
import app.user.UserRole;
import app.user.chage.ChangeResult;
import app.user.info.UserInfoManager;
import app.utils.authorization.Authorization;
import app.utils.jsonobjectbuilder.JSONObjectBuilder;
import app.utils.jsonutil.JSONUtil;
import app.utils.protocol.ProtocolKeys;
import app.utils.protocol.ProtocolValues;
import app.utils.sex.Sex;
import app.utils.thread.ThreadCommand;
import app.utils.thread.ThreadGameCommand;
import app.utils.thread.ThreadMainCommand;
import atg.taglib.json.util.JSONArray;
import atg.taglib.json.util.JSONObject;

public class ServerApplication{
	public static ServerApplication application;
	
	public MyLogger logger;
	public MyLogger optionLogger;
	
	public HashMap<String, Room> rooms;
	public CommonRoom commonroom;
	public Room modsroom;
	
	public UserInfoManager userinfomanager;
	public GameManager gamemanager;
	public ShopManager shopmanager;
	public ClanManager clanmanager;
	public AdministratorManager adminmanager;
	public QuestsManager questsmanager;
	
	public ExecutorService mainexecutor;
	public ExecutorService gameexecutor;
	public ExecutorService executor;
	public ExecutorService loginexecutor;
	public ExecutorService startchangeinfoexecutor;
	public ExecutorService timerexecutor;
	
	public Map<SocketChannel, String> readBuffers;
	public Map<SocketChannel, ByteBuffer> writeBuffers;
	
	public PoolingDataSource sqlpool;
	
	public Selector selector;
	
	public ServerApplication(Selector s){
		selector = s;
		
		application = this;
		
		logger = new MyLogger(Config.logPath(), "ServerApplication");
		logger.log("Start Application...");
		
		optionLogger = new MyLogger(Config.optionLogPath(), "ServerApplication");
		optionLogger.log("Start Option Log...");
		
		gameexecutor = Executors.newFixedThreadPool(2);
		mainexecutor = Executors.newFixedThreadPool(2);
		executor = Executors.newFixedThreadPool(15);
		loginexecutor = Executors.newFixedThreadPool(10);
		startchangeinfoexecutor = Executors.newFixedThreadPool(5);
		timerexecutor = Executors.newFixedThreadPool(6);
		
		readBuffers = new ConcurrentHashMap<SocketChannel, String>();
		writeBuffers = new ConcurrentHashMap<SocketChannel, ByteBuffer>();
		
		rooms = new HashMap<String, Room>();
		commonroom = new CommonRoom(1, "Общий чат");
		rooms.put(Integer.toString(commonroom.id), commonroom);
		
		modsroom = new Room(3, "Модераторы");
		rooms.put(Integer.toString(modsroom.id), modsroom);
		
		try {
			Driver driver = (Driver) Class.forName("com.mysql.jdbc.Driver").newInstance();
    		DriverManager.registerDriver(driver);
    		logger.log("Loading JDBC Driver ok");
		} catch (Throwable  e) {
			logger.error(e.getStackTrace().toString());
		}
		
		setupDataSource();
		
		gamemanager = new GameManager();
		clanmanager = new ClanManager();
		userinfomanager = new UserInfoManager();
		shopmanager = new ShopManager();
		adminmanager = new AdministratorManager();
		questsmanager = new QuestsManager();
	}
	
	public void setupDataSource(){
		GenericObjectPool<Connection> connectionPool = new GenericObjectPool<Connection>();
		connectionPool.setMaxActive(200);
		ConnectionFactory connectionFactory = new DriverManagerConnectionFactory(DataBaseConfig.connectionUrl(), DataBaseConfig.dblogin(), DataBaseConfig.dbpassward());
		PoolableConnectionFactory poolableConnectionFactory = new PoolableConnectionFactory(connectionFactory, connectionPool, null, null, false, true);
		if(poolableConnectionFactory != null){
		}
		sqlpool = new PoolingDataSource(connectionPool);
	}
	
	public boolean onDisconnect(SocketChannel connection) throws IOException {
		if(connection != null){
			readBuffers.remove(connection);
			writeBuffers.remove(connection);
			
	    	UserConnection user = commonroom.getUserByConnection(connection);
	    	userinfomanager.removeUserByConnection(connection);
	    	if(user != null) userinfomanager.updateUser(user.user);
	    	user = null;
    	}
        return true;
    }
	
	public boolean onData(SocketChannel connection) throws Exception
    {
		ByteBuffer buffer = ByteBuffer.allocate(1024 * 15);		
		buffer.clear();
		int size = 0;
		
		try {
			size = connection.read(buffer);
		}catch (IOException e) {
			try {
				if(connection.socket().isConnected()){
					connection.socket().close();
				}
			}catch (IOException ex){
				logger.log("close socket exception: " + ex.toString());
			}
			return false;
		}
		
		byte[] bytesAnswer = buffer.array();
		buffer.flip();
		
		if (buffer.limit() == 0){
		  return false;
		}
		
        try{        	            
            String data = new String(bytesAnswer, 0, size);
            if(data.indexOf(Config.policyHead()) == 0){            	
    	        byte [] sendbytes = Config.policyContent().getBytes(Config.characterEncoding());
    	        ByteBuffer sendBuffer = ByteBuffer.allocate(sendbytes.length);
    	        sendBuffer.put(sendbytes);
    	        sendBuffer.flip();
    			
    			connection.write(sendBuffer);
    			
    	        return true;
            }
            boolean endSeparator = data.endsWith(Config.lineSeparator());
            String strBuffer = readBuffers.get(connection);
            String[] datas = data.split(Config.lineSeparator());
            
			for(int i = 0; i < datas.length; i++){
				if(strBuffer != null){
					strBuffer += datas[i];
				}else{
					strBuffer = datas[i];
				}
				if((i + 1) < datas.length || endSeparator){
					processData(connection, strBuffer);
					strBuffer = "";
				}
			}
			readBuffers.put(connection, strBuffer);
        }
        catch(Exception e){
        	logger.log("onData error " + e.toString());
        }
        return true;
    }
	
	public boolean processData(SocketChannel connection, String data){
		try{
			if(!JSONUtil.isJSON(data)){
				return false;
			}
			
            JSONObject jsonObj = new JSONObject(data);
            int command = jsonObj.getInt(ProtocolKeys.COMMAND);
            
            if(	command == ProtocolValues.SEND_MESSAGE ||            	
                command == ProtocolValues.GET_TOP_USERS ||
                command == ProtocolValues.GET_TOP_HOUR_USERS ||
                command == ProtocolValues.GET_TOP_DAY_USERS ||
                command == ProtocolValues.GET_TOP_POPULAR_USERS ||
                command == ProtocolValues.GET_CHEATER_LIST ||
                command == ProtocolValues.REMOVE_FROM_CHEATER_LIST ||
                command == ProtocolValues.BLOCK_CHEATER ||
                command == ProtocolValues.BAN ||
                command == ProtocolValues.GET_ONLINE_TIME_MONEY_INFO ||
                command == ProtocolValues.GET_ONLINE_TIME_MONEY ||
                command == ProtocolValues.IS_BAD_PLAYER ||
                command == ProtocolValues.USER_IN_COMMON_ROOM ||
                command == ProtocolValues.USER_IN_MODS_ROOM ||                
                command == ProtocolValues.ADMIN_SEND_NOTIFICATION ||
                command == ProtocolValues.GET_INVITED_USERS ||
                command == ProtocolValues.USER_IN_CLAN_ROOM ||                
                command == ProtocolValues.USER_OUT_CLAN_ROOM ||
                command == ProtocolValues.SET_ACTIVE_CAR)
            {
            	mainexecutor.execute(new ThreadMainCommand(command, connection, jsonObj));
            }else
        	if(	command == ProtocolValues.GAME_GO_TO_LEFT ||
                command == ProtocolValues.GAME_GO_TO_RIGHT ||
               	command == ProtocolValues.GAME_FORWARD ||
               	command == ProtocolValues.GAME_BACK ||
               	command == ProtocolValues.GAME_BRAKE ||
               	command == ProtocolValues.GAME_BET ||
               	command == ProtocolValues.GAME_GET_BET_GAMES_INFO ||
               	command == ProtocolValues.GAME_CREATE_BET_GAME ||
               	command == ProtocolValues.GAME_ADD_TO_BET_GAME ||
               	command == ProtocolValues.GAME_START_REQUEST ||
               	command == ProtocolValues.GAME_USER_EXIT ||
               	command == ProtocolValues.GAME_SENSOR_START ||
               	command == ProtocolValues.GAME_SENSOR_FINISH ||
               	command == ProtocolValues.GAME_SENSOR_ADDITIONAL_ZONE)
            {
        		gameexecutor.execute(new ThreadGameCommand(command, connection, jsonObj));
            }
        	else if(command == ProtocolValues.ADMIN_SHOW_INFO ||
               	command == ProtocolValues.ADMIN_UPDATE_ALL_USERS_PARAMS ||
               	command == ProtocolValues.ADMIN_SET_MODERATOR ||
               	command == ProtocolValues.ADMIN_DELETE_MODERATOR ||
               	command == ProtocolValues.ADMIN_DELETE_USER ||
               	command == ProtocolValues.ADMIN_SET_PARAM ||
               	command == ProtocolValues.ADMIN_SET_NAME_PARAM ||
               	command == ProtocolValues.CHANGE_INFO ||
               	command == ProtocolValues.ADD_TO_FRIEND ||
               	command == ProtocolValues.ADD_TO_ENEMY ||
               	command == ProtocolValues.REMOVE_FRIEND ||
               	command == ProtocolValues.REMOVE_ENEMY ||
               	command == ProtocolValues.UPDATE_USER ||
               	command == ProtocolValues.SEND_MAIL ||
               	command == ProtocolValues.REMOVE_MAIL_MESSAGE ||
               	command == ProtocolValues.GET_POSTS ||
               	command == ProtocolValues.GET_FRIENDS ||
               	command == ProtocolValues.GET_ENEMIES ||
               	command == ProtocolValues.GET_MAIL_MESSAGES ||
               	command == ProtocolValues.GET_FRIENDS_BONUS ||               	
               	command == ProtocolValues.GET_USER_INFO_BY_ID ||
                command == ProtocolValues.SHOP_GET_USER_ITEMS ||
                command == ProtocolValues.SHOP_GET_ITEM_PROTOTYPES ||
                command == ProtocolValues.SHOP_GET_PRESENTS_PRICE ||
                command == ProtocolValues.SHOP_SALE_ALL_PRESENTS ||
                command == ProtocolValues.SHOP_GET_PRICE_BAN_OFF ||
                command == ProtocolValues.SHOP_BUY_PRESENT ||
                command == ProtocolValues.SHOP_BUY_LINK ||
                command == ProtocolValues.SHOP_BUY_VIP_STATUS ||
                command == ProtocolValues.SHOP_BUY_CAR ||
                command == ProtocolValues.SHOP_RENT_CAR ||
                command == ProtocolValues.SHOP_BUY_CAR_COLOR ||
                command == ProtocolValues.SHOP_REPAIR_CAR ||
                command == ProtocolValues.SHOP_BUY_BAN_OFF ||
                command == ProtocolValues.SHOP_EXCHANGE_MONEY ||
                command == ProtocolValues.SHOP_SALE_ITEM ||
                command == ProtocolValues.CLAN_GET_CLANS_INFO ||
            	command == ProtocolValues.CLAN_GET_CLAN_ALL_INFO ||
            	command == ProtocolValues.CLAN_GET_CLAN_USERS ||
            	command == ProtocolValues.CLAN_GET_MONEY ||
            	command == ProtocolValues.CLAN_CREATE_CLAN ||
            	command == ProtocolValues.CLAN_INVITE_USER ||
            	command == ProtocolValues.CLAN_INVITE_ACCEPT ||
            	command == ProtocolValues.CLAN_KICK ||
            	command == ProtocolValues.CLAN_SET_ROLE ||
            	command == ProtocolValues.CLAN_LEAVE ||
            	command == ProtocolValues.CLAN_RESET ||
            	command == ProtocolValues.CLAN_DESTROY ||
            	command == ProtocolValues.CLAN_BUY_EXPERIENCE ||
            	command == ProtocolValues.CLAN_UPDATE_ADVERT ||
            	command == ProtocolValues.GET_DAILY_BONUS ||
            	command == ProtocolValues.QUEST_GET ||
            	command == ProtocolValues.QUEST_PASS ||
            	command == ProtocolValues.QUEST_CANCEL ||
            	command == ProtocolValues.QUEST_GET_CURRENT_VALUE ||
            	command == ProtocolValues.SOCIAL_POST ||
            	command == ProtocolValues.GET_ONLINE_USERS)
            {
        		executor.execute(new ThreadCommand(command, connection, jsonObj));
            }
        	else if(command == ProtocolValues.LOGIN ||
                    command == ProtocolValues.LOGIN_SITE ||
                    command == ProtocolValues.UPDATE_PARAMS)
            {
        		loginexecutor.execute(new ThreadCommand(command, connection, jsonObj));
            }
        	else if(command == ProtocolValues.START_CHANGE_INFO)
            {
        		startchangeinfoexecutor.execute(new ThreadCommand(command, connection, jsonObj));
            }
        }
        catch(Exception e){
        	logger.log("process data error: " + e.toString());
        } 
        return true;
	}
	
	public void sendResult(SocketChannel connection, int callBackId, boolean value){
		if(connection != null && connection.isConnected()){
			JSONObject jobj = new JSONObject();
			try{
				jobj.put(ProtocolKeys.COMMAND, ProtocolValues.CALLBACK);
				jobj.put(ProtocolKeys.CALLBACKID, callBackId);
				jobj.put(ProtocolKeys.VALUE, value);
		        
		        byte [] sendbytes = (jobj.toString() + Config.lineSeparator()).getBytes(Config.characterEncoding());
		        
		        send(connection, sendbytes);
			}catch(Exception e){
				logger.log("sendResult <boolean> error " + e.toString());
	        }
		}		
	}
	
	public void sendResult(SocketChannel connection, int callBackId, int value){
		if(connection != null && connection.isConnected()){
			JSONObject jobj = new JSONObject();
			try{
				jobj.put(ProtocolKeys.COMMAND, ProtocolValues.CALLBACK);
				jobj.put(ProtocolKeys.CALLBACKID, callBackId);
				jobj.put(ProtocolKeys.VALUE, value);
				
		        byte [] sendbytes = (jobj.toString() + Config.lineSeparator()).getBytes(Config.characterEncoding());
		        
		        send(connection, sendbytes);
			}catch(Exception e){
				logger.log("sendResult <int> error " + e.toString());
	        }
		}		
	}
	
	public void sendResult(SocketChannel connection, int callBackId, String key, JSONArray jarr){
		if(connection != null && connection.isConnected()){
			if(jarr != null){
				JSONObject jobj = new JSONObject();
				try{
					jobj.put(ProtocolKeys.COMMAND, ProtocolValues.CALLBACK);
					jobj.put(ProtocolKeys.CALLBACKID, callBackId);
					jobj.put(key, jarr);
					
			        byte [] sendbytes = (jobj.toString() + Config.lineSeparator()).getBytes(Config.characterEncoding());
			        
			        send(connection, sendbytes);
				}catch(Exception e){
					logger.log("sendResult <JSONArray> error " + e.toString());
		        }
			}
		}				
	}
	
	public void sendResult(SocketChannel connection, int callBackId, JSONObject jobj){
		if(connection != null && connection.isConnected()){
			if(jobj != null){
				try{
					jobj.put(ProtocolKeys.COMMAND, ProtocolValues.CALLBACK);
					jobj.put(ProtocolKeys.CALLBACKID, callBackId);
					
			        byte [] sendbytes = (jobj.toString() + Config.lineSeparator()).getBytes(Config.characterEncoding());
			        
			        send(connection, sendbytes);
				}catch(Exception e){
					logger.log("sendResult <JSONObject> error " + e.toString());
		        }
			}
		}				
	}
	
	public boolean send(SocketChannel connection, byte [] sendbytes){
		try{
			if(sendbytes != null && sendbytes.length > 0){
				ByteBuffer connectionBuffer = writeBuffers.get(connection);				
				writeBuffers.remove(connection);
				
				ByteBuffer sendBuffer;
				if(connectionBuffer != null && connectionBuffer.array() != null && connectionBuffer.array().length > 0){
					sendBuffer = ByteBuffer.allocate(connectionBuffer.array().length + sendbytes.length);
					sendBuffer.put(connectionBuffer.array());
				}else{
					sendBuffer = ByteBuffer.allocate(sendbytes.length);
				}
				sendBuffer.put(sendbytes);
				sendBuffer.flip();
				
		        int sendedBytes = connection.write(sendBuffer);
		        if(sendedBytes < sendBuffer.array().length){
		        	connection.register(selector, SelectionKey.OP_WRITE);		        	
		        	
		        	ByteBuffer newConnectionBuffer = ByteBuffer.allocate(sendBuffer.array().length - sendedBytes);
		        	newConnectionBuffer.put(sendBuffer.array(), sendedBytes, sendBuffer.array().length - sendedBytes);
		        	newConnectionBuffer.flip();
		        	
		        	writeBuffers.put(connection, newConnectionBuffer);
		        	return false;
		        }
		        
		        if(connectionBuffer != null){
		        	connectionBuffer.clear();
		        }
		        sendBuffer.clear();
			}
		}catch(Exception e){
//			logger.log("send data error " + e.toString());
        }
		return true;
	}
	
	public boolean sendBuffer(SocketChannel connection){
		try{
			ByteBuffer connectionBuffer = writeBuffers.get(connection);				
			writeBuffers.remove(connection);
			
			ByteBuffer sendBuffer;
			if(connectionBuffer != null && connectionBuffer.array() != null && connectionBuffer.array().length > 0){
				sendBuffer = ByteBuffer.allocate(connectionBuffer.array().length);
				sendBuffer.put(connectionBuffer.array());
			}else{
				return true;
			}
			sendBuffer.flip();
			
	        int sendedBytes = connection.write(sendBuffer);
	        if(sendedBytes < sendBuffer.array().length){
	        	
	        	ByteBuffer newConnectionBuffer = ByteBuffer.allocate(sendBuffer.array().length - sendedBytes);
        		newConnectionBuffer.put(sendBuffer.array(), sendedBytes, sendBuffer.array().length - sendedBytes);		        	
        		newConnectionBuffer.flip();
	        	
	        	writeBuffers.put(connection, newConnectionBuffer);	        	
	        	
	        	return false;
	        }
	        
	        if(connectionBuffer != null){
        		connectionBuffer.clear();
        	}
	        sendBuffer.clear();
		}catch(Exception e){
//			logger.log("send data error " + e.toString());
        }
		return true;
	}
	
    public void logIn(SocketChannel connection, JSONObject params){
    	String socialid = JSONUtil.getString(params, ProtocolKeys.PARAM1);
    	String passward = JSONUtil.getString(params, ProtocolKeys.PARAM2);
    	String authkey = JSONUtil.getString(params, ProtocolKeys.PARAM3);
    	String vid = JSONUtil.getString(params, ProtocolKeys.PARAM4);
    	int mode = JSONUtil.getInt(params, ProtocolKeys.PARAM5);
    	String appID = JSONUtil.getString(params, ProtocolKeys.PARAM6);
    	int version = JSONUtil.getInt(params, ProtocolKeys.PARAM7);
    	
    	try{
    		if(version == Config.currentVersion()){    			
		    	if (Authorization.check(authkey, vid, mode, appID) == true && connection.isConnected() == true){		    		
		    		UserConnection user = commonroom.getUserBySocialID(socialid);
		    		if(user != null){
		    			onDisconnect(user.connection);
		    			
			    		if(user.connection.isConnected() == true){
			    			user.connection.close();		    			
			    		}
			    		user = null;
		    		}
		    		
		    		if(userinfomanager.clientConnect(connection, socialid, passward, connection.socket().getInetAddress().getHostAddress(), null, UserLoginMode.UNDEFINED)){
		    			sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
		    			
		    			return;
		    		}else{
		    			logger.log("connection not be connect: " + socialid);
		    		}
		    	}else{
		    		logger.log("Authorization bad: " + socialid);
		    	}
    		}
    		sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), false);
    		connection.close();    	
    		connection = null;
    	}catch(Throwable e){
    	}
    }
    
    public void loginSite(SocketChannel connection, JSONObject params){
    	String login = JSONUtil.getString(params, ProtocolKeys.PARAM1);
    	String confirmationid = JSONUtil.getString(params, ProtocolKeys.PARAM2);
    	int version = JSONUtil.getInt(params, ProtocolKeys.PARAM3);
    	int playmode = JSONUtil.getInt(params, ProtocolKeys.PARAM4);
    	
    	try{
    		if(version == Config.currentVersion()){
    			if(playmode == 1){
    				UserConnection guest = new UserConnection(userinfomanager.guestIdsCounter--, "guest", "", Sex.MALE, "Гость", 0, 0, 0, 0, 1,	0, 0, 0,(byte) 0, 0, 0, "", new ClanUserInfo(0, "", 0, 0,(byte) 0, 0), 0, 0, 0, connection);
    				guest.call(ProtocolValues.INIT_PERS_PARAMS, JSONObjectBuilder.createObjInitUser(guest.user, 0, 0, ServerApplication.application.userinfomanager.popularparts, ServerApplication.application.userinfomanager.populartitles, commonroom.users.size()));    				
    				ServerApplication.application.commonroom.addUserWithoutMessage(guest);
    				
    				sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
    				return;
    			}else{
    				UserConnection user = commonroom.getUserBySocialID(login);
    	    		if(user != null){
    	    			onDisconnect(user.connection);
    	    			
    		    		if(user.connection.isConnected() == true){
    		    			user.connection.close();			    			
    		    		}
    		    		user = null;
    	    		}
    	    		
    	    		if(userinfomanager.clientConnect(connection, login, null, connection.socket().getInetAddress().getHostAddress(), confirmationid, UserLoginMode.SITE)){
    	    			sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
    	    			return;
    	    		}else{
    	    			logger.log("connection not be connect: " + login);
    	    		}
    			}
    		}
    		sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), false);
    		connection.close();    	
    		connection = null; 
    	}catch(Throwable e){
    	}
    }
    
    public void createRoomById(int roomId, String roomTitle){
    	Room room = new Room(roomId, roomTitle);
		rooms.put(Integer.toString(room.id), room);
    }
    
    public void removeUserFromRoom(UserConnection user, int roomId){
    	if(user != null && user.connection.isConnected()){
    		Room room = rooms.get(new Integer(roomId).toString());
    		if (room != null){
    			room.removeUserByConnection(user.connection);
    		}
    	}
    }
    
    public void removeRoom(int roomId){
    	Room room = rooms.get(new Integer(roomId).toString());
		if (room != null){
			room.roomClear();
			rooms.remove(new Integer(roomId).toString());
		}
    }
    
    public void getFriendsBonus(SocketChannel connection, JSONObject params){
    	String vid = JSONUtil.getString(params, ProtocolKeys.PARAM1);
    	int mode = JSONUtil.getInt(params, ProtocolKeys.PARAM2);
    	int appID = JSONUtil.getInt(params, ProtocolKeys.PARAM3);
    	String sessionKey = JSONUtil.getString(params, ProtocolKeys.PARAM4);
    	
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), userinfomanager.getFriendsBonus(commonroom.getUserByConnection(connection), vid, mode, appID, sessionKey));    	
    }
    
    public void updateUser(SocketChannel connection, JSONObject params){
    	UserConnection user = commonroom.getUserByConnection(connection);
    	if(user != null) userinfomanager.updateUser(user.user);
    	user = null;
    }
    
    public void updateParams(SocketChannel connection, JSONObject params){
    	UserConnection user = commonroom.getUserByConnection(connection);
    	userinfomanager.updateParams(user, JSONUtil.getString(params, ProtocolKeys.PARAM1));
    }
    
    public void sendMessage(SocketChannel connection, JSONObject params){
    	String mtext = JSONUtil.getString(params, ProtocolKeys.PARAM1);
    	String receiverID = JSONUtil.getString(params, ProtocolKeys.PARAM2);
    	String roomID = JSONUtil.getString(params, ProtocolKeys.PARAM3);
    	 	
    	Room room = rooms.get(roomID);
    	if (room != null){    		
    		room.sendMessage(mtext, connection, receiverID);
    	}else{    		
    		Room gameroom = GameManager.gamerooms.get(roomID);
    		
    		if (gameroom != null){    			
    			gameroom.sendMessage(mtext, connection, receiverID);
    		}else{
    			commonroom.sendPrivateMessage(mtext, connection, receiverID, new Integer(roomID));
    		}
    		gameroom = null;
    	}
    	room = null;    	
    }
    
    public void sendMail(SocketChannel connection, JSONObject params){
    	int uid =  JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	String message = JSONUtil.getString(params, ProtocolKeys.PARAM2);
    	
    	//return BuyResult
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(userinfomanager.sendMail(commonroom.getUserByConnection(connection), uid, message)));    	
    }
    
    public void getMailMessages(SocketChannel connection, JSONObject params){
    	int offset = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
    	UserConnection user = commonroom.getUserByConnection(connection);
    	if(user != null && user.connection != null && user.connection.isConnected()){
    		user.call(ProtocolValues.PROCESS_MAIL_MESSAGES, ProtocolKeys.MESSAGES, 
					JSONObjectBuilder.createObjUsersMailMessage(userinfomanager.getMailMessages(user.user.id, offset)));
    		
    		user = null;
    	}
    }
    
    public void removeMailMessage(SocketChannel connection, JSONObject params){
    	int mid = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	userinfomanager.removeMailMessage(mid);
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), mid);
    }
    
    public void isBadPlayer(SocketChannel connection, JSONObject params){
    	UserConnection u = commonroom.getUserByConnection(connection);
    	if(u != null){
    		try{
    			u.connection.close();    			
    		}catch(Throwable e){
        	}
    	}
    }
    
    public void changeInfo(SocketChannel connection, JSONObject params){
    	String title = JSONUtil.getString(params, ProtocolKeys.PARAM1);
    	int sex = JSONUtil.getInt(params, ProtocolKeys.PARAM2);
    	
    	ChangeResult result = new ChangeResult();
    	result = userinfomanager.changeInfo(title, sex, connection, result, false);
    	
    	//return ChangeResult 
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjChangeResult(result));
    }
    
    public void addToFriend(SocketChannel connection, JSONObject params){
    	int uid = commonroom.getUserByConnection(connection).user.id;
    	int fid = JSONUtil.getInt(params, ProtocolKeys.PARAM1);    	
    	String note = JSONUtil.getString(params, ProtocolKeys.PARAM2);
    	if(note != null){
    		if(note.length() > 30){
    			note = note.substring(0, Math.min(Math.max(0, note.length() - 1), 30));
    		}
    	}else{
    		note = "";
    	}
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), userinfomanager.addToFriend(uid, fid, note));
    }
    
    public void addToEnemy(SocketChannel connection, JSONObject params){
    	int eid = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	UserConnection u = commonroom.getUserByConnection(connection); 
    	
    	if(u != null && u.user.enemies.size() < 100){
    		if(u.user.enemies.get(eid) == null){
    			u.user.enemies.put(eid, eid);    			
    		}
    		userinfomanager.addToEnemy(u.user.id, eid);
    		sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
    	}else{
    		sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), false);
    	}
    }
    
    public void removeFriend(SocketChannel connection, JSONObject params){
    	int userid = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	userinfomanager.removeFriend(commonroom.getUserByConnection(connection).user.id, userid);
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), userid);
    }
    
    public void removeEnemy(SocketChannel connection, JSONObject params){
    	int eid = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	UserConnection u = commonroom.getUserByConnection(connection);
    	
    	if(u != null){
    		u.user.enemies.remove(eid);
    		userinfomanager.removeEnemy(commonroom.getUserByConnection(connection).user.id, eid);
    		sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), eid);    		
    	}    	
    }
    
    public void getPosts(SocketChannel connection, JSONObject params){
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createAdminAndModeratorUsers(userinfomanager.adminUsers, userinfomanager.moderatorUsers));
    }
    
    public void getFiends(SocketChannel connection, JSONObject params){
    	int offset = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
    	UserConnection user = commonroom.getUserByConnection(connection);
    	if(user != null && user.connection != null && user.connection.isConnected()){
    		user.call(ProtocolValues.PROCESS_FRIENDS, ProtocolKeys.USERS, 
					JSONObjectBuilder.createObjUsersFriend(userinfomanager.getFiends(user.user.id, offset)));
    		user = null;
    	}
    }
    
    public void getEnemies(SocketChannel connection, JSONObject params){
    	int offset = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
    	UserConnection user = commonroom.getUserByConnection(connection);
    	if(user != null && user.connection != null && user.connection.isConnected()){
    		user.call(ProtocolValues.PROCESS_ENEMIES, ProtocolKeys.USERS, 
					JSONObjectBuilder.createObjUsersFriend(userinfomanager.getEnemies(user.user.id, offset)));
    		user = null;
    	}
    }
    
    public void gettopusers(SocketChannel connection, JSONObject params){
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), ProtocolKeys.USERS, userinfomanager.topUsersJSON);    	
    }
    
    public void gettophourusers(SocketChannel connection, JSONObject params){
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), ProtocolKeys.USERS, userinfomanager.topHourUsersJSON);    	
    }
    
    public void gettopdayusers(SocketChannel connection, JSONObject params){
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), ProtocolKeys.USERS, userinfomanager.topDayUsersJSON);    	
    }
    
    public void gettoppopularusers(SocketChannel connection, JSONObject params){
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), ProtocolKeys.USERS, userinfomanager.topPopularUsersJSON);    	
    }
    
    public void getcheterlist(SocketChannel connection, JSONObject params){
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), ProtocolKeys.USERS, JSONObjectBuilder.createObjCheaterList(userinfomanager.cheaterList));    	
    }
    
    public void ban(SocketChannel connection, JSONObject params){
    	int userID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	byte type = (byte) JSONUtil.getInt(params, ProtocolKeys.PARAM2);
    	boolean byip = JSONUtil.getBoolean(params, ProtocolKeys.PARAM3);
    	
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), userinfomanager.ban(userID, connection, type, byip));
    }
    
    public void getUserInfoByID(SocketChannel connection, JSONObject params){
    	int userID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	UserConnection user = commonroom.users.get(Integer.toString(userID));
    	UserConnection initiator = ServerApplication.application.commonroom.getUserByConnection(connection);
    	if (user != null && initiator != null){
    		Date date = new Date();
			int currenttime = (int)(date.getTime() / 1000);	
			date = null;			
    		
			int viptime = ServerApplication.application.commonroom.updateVip(user, currenttime);
			boolean selfInfo = (initiator.user.id == user.user.id);
			
			sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjUserInfo(user.user, viptime, selfInfo));    		
    	}else{
    		UserConnection u = userinfomanager.getOfflineUser(userID);
    		if(u != null){
    			sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjUserInfo(u.user, 0, true));
    		}
    	}
    }
    
    public void userInClanRoom(SocketChannel connection, JSONObject params){
    	UserConnection user = commonroom.getUserByConnection(connection);
    	if(user != null && user.connection.isConnected() && user.user.claninfo.clanid > 0 &&
    		(user.user.claninfo.clanrole == ClanRole.NO_ROLE || 
    		user.user.claninfo.clanrole == ClanRole.ROLE1 || user.user.claninfo.clanrole == ClanRole.ROLE2 ||
    		user.user.claninfo.clanrole == ClanRole.ROLE3 || user.user.claninfo.clanrole == ClanRole.ROLE4 ||
    		user.user.claninfo.clanrole == ClanRole.ROLE5 || user.user.claninfo.clanrole == ClanRole.OWNER)){
    		Room room = rooms.get(new Integer(user.user.claninfo.clanid * 10).toString());
    		if (room != null){
    			room.addUser(user);
    		}
    		
    	}
    	user = null;
    }    
    public void userOutClanRoom(SocketChannel connection, JSONObject params){
    	UserConnection user = commonroom.getUserByConnection(connection);
    	if(user != null && user.connection.isConnected() && user.user.claninfo.clanid > 0 &&
    		(user.user.claninfo.clanrole == ClanRole.NO_ROLE ||
    		user.user.claninfo.clanrole == ClanRole.ROLE1 || user.user.claninfo.clanrole == ClanRole.ROLE2 ||
    		user.user.claninfo.clanrole == ClanRole.ROLE3 || user.user.claninfo.clanrole == ClanRole.ROLE4 ||
    		user.user.claninfo.clanrole == ClanRole.ROLE5 || user.user.claninfo.clanrole == ClanRole.OWNER)){
    		Room room = rooms.get(new Integer(user.user.claninfo.clanid * 10).toString());
    		if (room != null){    		
    			room.removeUserByConnection(connection);
    		}
    	}
    	user = null;
    }
    
    public void userInCommonRoom(SocketChannel connection, JSONObject params){
    	UserConnection user = commonroom.getUserByConnection(connection);
    	commonroom.addUser(user);  
    	
    	if(!user.user.incommonroom){
    	}
    	
    	user = null;
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
    }
    
    public void userInModsRoom(SocketChannel connection, JSONObject params){
    	UserConnection user = commonroom.getUserByConnection(connection);
    	if(UserRole.isModerator(user.user.role) || UserRole.isAdministrator(user.user.role) || UserRole.isAdministratorMain(user.user.role)){
			if(modsroom.getUserByConnection(connection) == null){
				modsroom.addUser(user);				
			}
		}
    	user = null;
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
    }
    
    public void getOnlineTimeMoneyInfo(SocketChannel connection, JSONObject params){
    	UserConnection initiator = ServerApplication.application.commonroom.getUserByConnection(connection);
    	
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), userinfomanager.getOnlineTimeMoneyInfo(initiator));
	}
    public void getOnlineTimeMoney(SocketChannel connection, JSONObject params){	
    	UserConnection initiator = ServerApplication.application.commonroom.getUserByConnection(connection);
    	userinfomanager.getOnlineTimeMoney(initiator);
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
    }
    public void getDailyBonus(SocketChannel connection, JSONObject params){
    	UserConnection initiator = ServerApplication.application.commonroom.getUserByConnection(connection);
    	sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), userinfomanager.getDailyBonus(initiator));
    }
    
    public void printStackTrace(String srt){
		StringWriter sw = new StringWriter();
	    PrintWriter pw = new PrintWriter(sw, true);
	    new Error().printStackTrace(pw);
	    pw.flush();
	    sw.flush();
		optionLogger.log(srt + " " + sw.toString());
	}
}