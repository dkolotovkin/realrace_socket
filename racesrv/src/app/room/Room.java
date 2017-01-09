package app.room;

import java.nio.channels.SocketChannel;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import app.Config;
import app.logger.MyLogger;
import app.message.Message;
import app.message.MessageType;
import app.message.ban.BanMessage;
import app.message.present.MessagePresent;
import app.message.simple.MessageSimple;
import app.user.ChatInfo;
import app.user.User;
import app.user.UserConnection;
import app.utils.ban.BanType;
import app.utils.jsonobjectbuilder.JSONObjectBuilder;
import app.utils.protocol.ProtocolValues;
import atg.taglib.json.util.JSONObject;

public class Room {
	public MyLogger logger = new MyLogger(Config.logPath(), Room.class.getName());
	
	public int id;
	public String title;
	public Map<String, UserConnection> users;
	public Map<SocketChannel, String> userConnectionIDtoID;
	public Map<String, String> userSocialIDtoID;
	public List<Message> messages;
	
	public Room(int id, String title){
		this.id = id;
		this.title = title;
		
		users = new ConcurrentHashMap<String, UserConnection>();
		userConnectionIDtoID = new ConcurrentHashMap<SocketChannel, String>();
		userSocialIDtoID = new ConcurrentHashMap<String, String>();
		messages = new ArrayList<Message>();
	}
	
	public void addUser(UserConnection u){
		if (u != null && u.connection != null && u.connection.isConnected()){
			if(users.get(Integer.toString(u.user.id)) == null){
				users.put(Integer.toString(u.user.id), u);	
				userConnectionIDtoID.put(u.connection, Integer.toString(u.user.id));			
				userSocialIDtoID.put(u.user.idSocial, Integer.toString(u.user.id));	
			}		
			
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageStatus(MessageType.USER_IN, this, ChatInfo.createFromUser(u.user));
			List<ChatInfo> usersinroom = new ArrayList<ChatInfo>();
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				usersinroom.add(ChatInfo.createFromUser(user.getValue().user));
				if(user.getValue().user.id != u.user.id){
					if(user.getValue().connection.isConnected()){
						user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
					}					
				}
			}			
			set = null;
			
			jsonMessage = null;
			jsonMessage = JSONObjectBuilder.createObjMessageStatus(MessageType.USER_IN, this, ChatInfo.createFromUser(u.user), messages, usersinroom);
			
			u.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			
			usersinroom = null;
			jsonMessage = null;			
		}
	}
	
	public void addUserWithoutMessage(UserConnection u){
		if (u != null && u.connection != null && u.connection.isConnected()){
			if(users.get(Integer.toString(u.user.id)) == null){
				users.put(Integer.toString(u.user.id), u);	
				userConnectionIDtoID.put(u.connection, Integer.toString(u.user.id));			
				userSocialIDtoID.put(u.user.idSocial, Integer.toString(u.user.id));	
			}
		}
	}
	
	public void removeUserByConnection(SocketChannel connection){
		String userID = userConnectionIDtoID.get(connection);
		if (userID != null && userID != "null"){
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageOutStatus(MessageType.USER_OUT, this, users.get(userID).user.id);
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			}
			set = null;
			
			if(users.get(userID) != null) userSocialIDtoID.remove(users.get(userID).user.idSocial);
			userConnectionIDtoID.remove(connection);
			users.remove(userID);			
			
			jsonMessage = null;
		}
	}
	
	public UserConnection getUserByConnection(SocketChannel connection){
		String userID = userConnectionIDtoID.get(connection);
		if (userID != null && userID != "null"){
			return users.get(userID);
		}
		return null;
	}
	
	public UserConnection getUserBySocialID(String socialID){
		String userID = userSocialIDtoID.get(socialID);
		if (userID != null && userID != "null"){
			return users.get(userID);
		}
		return null;
	}
	
	public void sendMessage(String mtext, SocketChannel initiatorConnection, String receiverID){
		String userID = userConnectionIDtoID.get(initiatorConnection);
		if (userID != null && userID != "null" && users.get(userID) != null && BanType.noBan(users.get(userID).user.bantype) &&
				users.get(userID).user.id > 0 && users.get(userID).user.level >= Config.levelFromChatEnabled()){
			
			User receiverUser = null;
			User initiator = users.get(userID).user;
			if(initiator != null && initiator.money > 0){
				UserConnection receiverUserConnetion = users.get(receiverID);			
				if (receiverUserConnetion != null){
					receiverUser = receiverUserConnetion.user;
				}
				
				MessageSimple message = new MessageSimple(MessageType.MESSAGE, this.id, mtext, initiator, receiverUser);
				JSONObject jsonMessage = null;
				if(receiverUser != null){
					jsonMessage = JSONObjectBuilder.createObjMessageSimple(MessageType.MESSAGE, this.id, mtext, initiator.id, receiverUser.id);
				}else{
					jsonMessage = JSONObjectBuilder.createObjMessageSimple(MessageType.MESSAGE, this.id, mtext, initiator.id, 0);
				}
				
				Set<Entry<String, UserConnection>> set = users.entrySet();
				for (Map.Entry<String, UserConnection> user:set){
					if(initiator.id != user.getValue().user.id){ 
						user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
					}
				}
				set = null;
				
				if(this.id == 1){
					initiator.money = Math.max(0, initiator.money - 1);
				}
				
				messages.add(message);
				if (messages.size() > Config.maxMessageCountInRoom()){
					messages.remove(0);
				}
				receiverUserConnetion = null;
				jsonMessage = null;
				message = null;
			}			
			receiverUser = null;
			initiator = null;
		}
	}
	
	public void sendMessagePresent(int prototypeID, int price, int pricereal, SocketChannel initiatorConnection, String receiverID){
		String userID = userConnectionIDtoID.get(initiatorConnection);		
		if (userID != null && userID != "null" && BanType.noBan(users.get(userID).user.bantype)){
			
			User receiverUser = null;
			UserConnection receiverUserConnetion = users.get(receiverID);			
			if (receiverUserConnetion != null){
				receiverUser = receiverUserConnetion.user;
			}
			
			int fromUserId = 0;
			if(users.get(userID).user != null) fromUserId = users.get(userID).user.id;
			int toUserId = 0;
			if(receiverUser != null) toUserId = receiverUser.id;
			
			MessagePresent message = new MessagePresent(MessageType.PRESENT, this.id, prototypeID, price, pricereal, users.get(userID).user, receiverUser);
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessagePresent(MessageType.PRESENT, this.id, prototypeID, price, pricereal, fromUserId, toUserId);			
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			}
			set = null;
			
			messages.add(message);
			if (messages.size() > Config.maxMessageCountInRoom()){
				messages.remove(0);
			}			
			
			receiverUserConnetion = null;
			receiverUser = null;
			message = null;
			jsonMessage = null;
		}
	}
	
	public void sendBanMessage(int bannedId, SocketChannel connection, byte type){
		UserConnection initiator = getUserByConnection(connection);
		UserConnection banned = users.get(Integer.toString(bannedId));
		if (initiator != null){
			
			BanMessage message = null;
			
			int fromUserId = 0;
			if(initiator != null && initiator.user != null) fromUserId = initiator.user.id;
			int toUserId = 0;
			User bannedUser = null;
			if(banned != null && banned.user != null){
				toUserId = banned.user.id;
				bannedUser = banned.user;
			}
			
			message = new BanMessage(MessageType.BAN, this.id, initiator.user, bannedUser, type);
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageBan(MessageType.BAN, this.id, fromUserId, toUserId, type);			
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			}
			set = null;
			
			messages.add(message);
			if (messages.size() > Config.maxMessageCountInRoom()){
				messages.remove(0);
			}
			jsonMessage = null; 
			message = null;
		}
		initiator = null;
		banned = null;
	}
	
	public void sendSystemMessage(String text){		
		MessageSimple message = new MessageSimple(MessageType.SYSTEM, this.id, text, null, null);
		JSONObject jsonMessage = JSONObjectBuilder.createObjMessageSimple(MessageType.SYSTEM, this.id, text, 0, 0);		
		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){
			user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
		}	
		
		messages.add(message);
		if (messages.size() > Config.maxMessageCountInRoom()){
			messages.remove(0);
		}
		
		jsonMessage = null;
		set = null;
		message = null;
	}
	
	public void sendSystemMessage(UserConnection user, String text){
		JSONObject jsonMessage = JSONObjectBuilder.createObjMessageSimple(MessageType.SYSTEM, this.id, text, 0, 0);
		user.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
		jsonMessage = null;
	}
	
	public void sendBanOutMessage(int userID){
		UserConnection initiator = users.get(Integer.toString(userID));
		if (initiator != null){
			
			int fromUserId = 0;
			if(initiator.user != null) fromUserId = initiator.user.id;
			
			BanMessage message = new BanMessage(MessageType.BAN_OUT, this.id, initiator.user, null, (byte)0);
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageBan(MessageType.BAN_OUT, this.id, fromUserId, 0, (byte)0);			
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			}
			set = null;
			
			messages.add(message);
			if (messages.size() > Config.maxMessageCountInRoom()){
				messages.remove(0);
			}
			jsonMessage = null;
			message = null;
		}
		initiator = null;		
	}
	
	public void sendPrivateMessage(String mtext, SocketChannel initiatorConnection, String receiverID, int proomID){
		String userID = userConnectionIDtoID.get(initiatorConnection);		
		if (userID != null && userID != "null" && BanType.noBan(users.get(userID).user.bantype) && users.get(userID).user.id > 0 && users.get(userID).user.level >= Config.levelFromChatEnabled()){			
			User receiverUser = null;
			UserConnection receiverUserConnetion = users.get(receiverID);			
			if (receiverUserConnetion != null){
				receiverUser = receiverUserConnetion.user;				
			}
			
			int fromId = 0;
			if(users.get(userID).user != null) fromId = users.get(userID).user.id;
			int toId = 0;
			if(receiverUser != null) toId = receiverUser.id;
			
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageSimple(MessageType.PRIVATE, proomID, mtext, fromId, toId);
			
			if(receiverUserConnetion != null){
				receiverUserConnetion.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			}
			receiverUserConnetion = null;
			receiverUser = null;
			jsonMessage = null;
		}
	}
	
	public void changeUserInfoByID(int userID, byte param, int value1, int value2){
		if (users.get(Integer.toString(userID)) != null){
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageChangeInfo(MessageType.CHANGEINFO, this.id, param, value1, value2);
			
			try{
				UserConnection user = users.get(Integer.toString(userID));
				user.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);					
				user = null;
			}catch(Throwable e){
				logger.log(e.toString());
			}
			jsonMessage = null;
		}
	}
	
	public void changeUserInfoByID(int userID, byte param, int value1, int value2, int value3){
		if (users.get(Integer.toString(userID)) != null){
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageChangeInfo3(MessageType.CHANGEINFO, this.id, param, value1, value2, value3);			
			
			try{
				UserConnection user = users.get(Integer.toString(userID));
				user.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
				user = null;
			}catch(Throwable e){
				logger.log(e.toString());
			}
			jsonMessage = null;
		}
	}	
	
	public void roomClear(){		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageOutStatus(MessageType.USER_OUT, this, user.getValue().user.id);
			
			user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			jsonMessage = null;
		}
		set = null;
		
		users.clear();
		userConnectionIDtoID.clear();
		userSocialIDtoID.clear();
		messages.clear();
		logger = null;
	}
}