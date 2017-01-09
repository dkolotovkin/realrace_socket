package app.room.common;

import java.nio.channels.SocketChannel;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import app.Config;
import app.ServerApplication;
import app.message.MessageType;
import app.message.ban.BanMessage;
import app.message.present.MessagePresent;
import app.message.simple.MessageSimple;
import app.room.Room;
import app.user.ChatInfo;
import app.user.User;
import app.user.UserConnection;
import app.user.UserForTop;
import app.user.UserLoginMode;
import app.user.UserRole;
import app.user.VipType;
import app.utils.ban.BanType;
import app.utils.changeinfo.ChangeInfoParams;
import app.utils.jsonobjectbuilder.JSONObjectBuilder;
import app.utils.protocol.ProtocolValues;
import app.utils.thread.timer.ThreadOn2MinuteCommand;
import app.utils.thread.timer.ThreadOn30SecondCommand;
import app.utils.thread.timer.ThreadOn5MinuteCommand;
import app.utils.thread.timer.ThreadOnEveryDayCommand;
import app.utils.thread.timer.ThreadOnEveryHourCommand;
import atg.taglib.json.util.JSONObject;

public class CommonRoom extends Room {
	public Timer servertimer;
	public int update5minute = 0;
	public int update2minute = 0;
	public int update30second = 0;
	public int lastprizehour = 0;
	public Date date;
	public int maxDebugDeltaTime = 0;
	
	public Map<Integer, Integer> userstimeonline;
	
	public CommonRoom(int id, String title){
		super(id, title);
		userstimeonline = new ConcurrentHashMap<Integer, Integer>();
		servertimer = new Timer();
		servertimer.schedule(new ServerTimerTask(), 10 * 1000, 10 * 1000);
	}
	
	@Override
	public void addUser(UserConnection u){
		u.user.incommonroom = true;
		
		if (u != null && u.connection != null && u.connection.isConnected()){
			if(users.get(Integer.toString(u.user.id)) == null){
				users.put(Integer.toString(u.user.id), u);	
				userConnectionIDtoID.put(u.connection, Integer.toString(u.user.id));			
				userSocialIDtoID.put(u.user.idSocial, Integer.toString(u.user.id));	
			}
			
			JSONObject jsonMessage = null;
			jsonMessage = JSONObjectBuilder.createObjMessageStatus(MessageType.USER_IN, this, ChatInfo.createFromUser(u.user), messages);
			
			u.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			
			jsonMessage = null;
		}
		
		date = new Date();
		int currenttime = (int)(date.getTime() / 1000);
		if(userstimeonline.get(u.user.id) != null) userstimeonline.remove(u.user.id);
		userstimeonline.put(u.user.id, currenttime);
	}
	
	@Override
	public void sendMessage(String mtext, SocketChannel initiatorConnection, String receiverID){
		String userID = userConnectionIDtoID.get(initiatorConnection);	
		if (userID != null && userID != "null" && users.get(userID) != null && BanType.noBan(users.get(userID).user.bantype)
				&& users.get(userID).user.id > 0 && users.get(userID).user.level >= Config.levelFromChatEnabled()){
			
			User receiverUser = null;
			UserConnection initiator = users.get(userID);
			if(initiator != null && initiator.user != null && initiator.user.money > 0){
				UserConnection receiverUserConnetion = users.get(receiverID);			
				if (receiverUserConnetion != null){
					receiverUser = receiverUserConnetion.user;
				}
				
				if(receiverUserConnetion != null || new Integer(receiverID) == 0){
					MessageSimple message = new MessageSimple(MessageType.MESSAGE, this.id, mtext, initiator.user, receiverUser);				
					JSONObject jsonMessage = JSONObjectBuilder.createObjMessageSimple(MessageType.MESSAGE, this.id, mtext, initiator.user, receiverUser);
					
					Set<Entry<String, UserConnection>> set = users.entrySet();
					for (Map.Entry<String, UserConnection> user:set){
						if(initiator.user.id != user.getValue().user.id){							
							if(user.getValue().user.level <= 5){
								if(user.getValue().user.incommonroom || user.getValue().user.role > 0){
									user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
								}
							}else if(user.getValue().user.level <= 15){
								if(user.getValue().user.incommonroom || user.getValue().user.role > 0){
									user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
								}else{
									if(new Integer(receiverID) == user.getValue().user.id){
										user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
									}
								}
							}else{
								user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
							}
						}
					}
					set = null;
					
					if(this.id == 1 && initiator.user.loginMode != UserLoginMode.SITE && initiator.user.vip != VipType.VIP_GOLD){
						initiator.user.money = Math.max(0, initiator.user.money - 1);
					}
					
					messages.add(message);
					if (messages.size() > Config.maxMessageCountInRoom()){
						messages.remove(0);
					}
					receiverUserConnetion = null;
					jsonMessage = null;
					message = null;
				}else{
					JSONObject jsonMessage = JSONObjectBuilder.createObjMessageSimple(MessageType.USER_NOT_FIND, this.id, "Пользователь вышел из игры", null, null);
					initiator.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
				}
			}
			receiverUser = null;
			initiator = null;
		}
	}
	
	@Override
	public void sendMessagePresent(int prototypeID, int price, int pricereal, SocketChannel initiatorConnection, String receiverID){
		String userID = userConnectionIDtoID.get(initiatorConnection);		
		if (userID != null && userID != "null" && BanType.noBan(users.get(userID).user.bantype)){
			
			User receiverUser = null;
			UserConnection receiverUserConnetion = users.get(receiverID);			
			if (receiverUserConnetion != null){
				receiverUser = receiverUserConnetion.user;
			}
			
			MessagePresent message = new MessagePresent(MessageType.PRESENT, this.id, prototypeID, price, pricereal, users.get(userID).user, receiverUser);
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessagePresent(MessageType.PRESENT, this.id, prototypeID, price, pricereal, users.get(userID).user, receiverUser);			
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				if(user.getValue().user.incommonroom || user.getValue().user.role > 0){
					user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
				}else{
					if(new Integer(receiverID) == user.getValue().user.id || new Integer(userID) == user.getValue().user.id){
						user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
					}
				}
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
	
	@Override
	public void sendBanMessage(int bannedId, SocketChannel connection, byte type){
		UserConnection initiator = getUserByConnection(connection);
		UserConnection banned = users.get(Integer.toString(bannedId));
		if (initiator != null){
			
			BanMessage message = null;
			
			User bannedUser = null;
			if(banned != null) bannedUser = banned.user;
			
			message = new BanMessage(MessageType.BAN, this.id, initiator.user, bannedUser, type);
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageBan(MessageType.BAN, this.id, initiator.user, bannedUser, type);			
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				if(user.getValue().user.incommonroom || user.getValue().user.role > 0){
					user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
				}else{
					if(UserRole.isAdministrator(user.getValue().user.role) || UserRole.isAdministratorMain(user.getValue().user.role) || UserRole.isModerator(user.getValue().user.role) ||
						bannedId == user.getValue().user.id || initiator.user.id == user.getValue().user.id){
						user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
					}
				}
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
	
	@Override
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
	
	public void sendOnlineCountMessage(){
		JSONObject jsonMessage = JSONObjectBuilder.createObjMessageOnlineCount(MessageType.ONLINE_COUNT, this.id, users.size());		
		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){
			user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
		}
		
		jsonMessage = null;
		set = null;
	}
	
	@Override
	public void sendBanOutMessage(int userID){
		UserConnection initiator = users.get(Integer.toString(userID));
		if (initiator != null){
			BanMessage message = new BanMessage(MessageType.BAN_OUT, this.id, initiator.user, null, (byte)0);
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageBan(MessageType.BAN_OUT, this.id, initiator.user, null, (byte)0);			
			
			Set<Entry<String, UserConnection>> set = users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				if(user.getValue().user.incommonroom || user.getValue().user.role > 0){
					user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
				}else{
					if(userID == user.getValue().user.id){
						user.getValue().call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
					}
				}
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
	
	@Override
	public void sendPrivateMessage(String mtext, SocketChannel initiatorConnection, String receiverID, int proomID){
		String userID = userConnectionIDtoID.get(initiatorConnection);		
		if (userID != null && userID != "null" && BanType.noBan(users.get(userID).user.bantype) && users.get(userID).user.id > 0 && users.get(userID).user.level >= Config.levelFromChatEnabled()){			
			User receiverUser = null;
			UserConnection receiverUserConnetion = users.get(receiverID);			
			if (receiverUserConnetion != null){
				receiverUser = receiverUserConnetion.user;				
			}
			
			int fromUserId = 0;
			if(users.get(userID).user != null) fromUserId = users.get(userID).user.id;
			
			JSONObject jsonMessage = null;
			
			if(receiverUserConnetion != null){
				if(receiverUserConnetion.user.enemies.get(fromUserId) == null){
					jsonMessage = JSONObjectBuilder.createObjMessageSimple(MessageType.PRIVATE, proomID, mtext, users.get(userID).user, receiverUser);
					receiverUserConnetion.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
				}
			}else{
				jsonMessage = JSONObjectBuilder.createObjMessageSimple(MessageType.USER_NOT_FIND, -(new Integer(receiverID)), "Пользователь вышел из игры", 0, 0);
				users.get(userID).call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			}
			receiverUserConnetion = null;
			receiverUser = null;
			jsonMessage = null;
		}
	}
	
	@Override
	public void removeUserByConnection(SocketChannel connection){
		userstimeonline.remove(new Integer(userConnectionIDtoID.get(connection)));
		
		String userID = userConnectionIDtoID.get(connection);
		if (userID != null && userID != "null"){
			JSONObject jsonMessage = JSONObjectBuilder.createObjMessageOutStatus(MessageType.USER_OUT, this, users.get(userID).user.id);
			
			UserConnection initiator = users.get(userID);
			if(initiator != null && initiator.connection.isConnected()){
				initiator.call(ProtocolValues.PROCESS_MESSAGE, jsonMessage);
			}
			
			if(initiator != null){
				userSocialIDtoID.remove(initiator.user.idSocial);
			}
			userConnectionIDtoID.remove(connection);
			users.remove(userID);			
			
			jsonMessage = null;
		}
	}
	
	@Override
	public void roomClear(){
		super.roomClear();
		if (servertimer != null){
			servertimer.cancel();
		}
		servertimer = null;
    }

	public void showStartInfo(UserConnection u){
		if(u.user.level < 2){			
			u.call(ProtocolValues.PROCESS_MESSAGE, JSONObjectBuilder.createObjMessageSimple(MessageType.START_INFO, this.id, "", u.user.id, 0));
		}
	}
	
	public void updateBan(UserConnection u, int currenttime){		
		int timepassed = currenttime - u.user.setbanat;
		boolean passed = false;
		
		int duration = 0;		
		if (BanType.by5Minut(u.user.bantype)){
			duration = 5 * 60;
			if (timepassed >= duration) passed = true;
		}else if (BanType.by15Minut(u.user.bantype)){
			duration = 15 * 60;
			if (timepassed >= duration) passed = true;
		}else if (BanType.by30Minut(u.user.bantype)){
			duration = 30 * 60;
			if (timepassed >= duration) passed = true;
		}else if (BanType.byHour(u.user.bantype)){
			duration = 60 * 60;
			if (timepassed >= duration) passed = true;
		}else if (BanType.byDay(u.user.bantype)){
			duration = 60 * 60 * 24;
			if (timepassed >= duration) passed = true;
		}else if (BanType.byWeek(u.user.bantype)){
			duration = 60 * 60 * 24 * 7;
			if (timepassed >= duration) passed = true;
		}
		
		if (!BanType.noBan(u.user.bantype) && u.user.changebanat != 0){
			int banexperience = (int) Math.floor((float)(Math.min(currenttime, u.user.setbanat + duration) - u.user.changebanat) / 60) * Config.valueExperienceUpdateInBan();
			int banpopular = (int) Math.floor((float)(Math.min(currenttime, u.user.setbanat + duration) - u.user.changebanat) / 60) * Config.valuePopularUpdateInBan();
			
			if (banexperience > 0 || banpopular > 0){
				u.user.updateExpAndPopul(u.user.experience - banexperience, u.user.popular - banpopular, currenttime);
				u.user.changebanat = currenttime;				
				changeUserInfoByID(u.user.id, ChangeInfoParams.USER_EXPERIENCE_AND_POPULAR, u.user.experience, u.user.popular);
			}
		}
		
		if(passed == true){
			u.user.bantype = BanType.NO_BAN;
			u.user.setbanat = 0;
			ServerApplication.application.userinfomanager.banoff(u.user.id, u.user.ip);
		}
	}
	
	public int updateVip(UserConnection u, int currenttime){	
		int viptime = 0;
		int timepassed = currenttime - u.user.setvipat;
		boolean passed = false;
		int day = 60 * 60 * 24;
		
		if(u.user.vip != VipType.NONE){
			if (timepassed >= day * 5) passed = true;
			viptime = day * 5 - timepassed;
			
			if(passed == true){
				u.user.vip = VipType.NONE;
				u.user.setvipat = 0;
				ServerApplication.application.userinfomanager.vipoff(u.user.id);
			}
		}		
		viptime = Math.max(0, viptime);
		return viptime;
	}
	
	public void updateTransactionsVK(){		
		Connection _sqlconnection = null;		
		PreparedStatement updatetransaction = null;
		PreparedStatement select = null;
		ResultSet selectRes = null;
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			select = _sqlconnection.prepareStatement("SELECT * FROM transactionvk WHERE status=0");
			selectRes = select.executeQuery();
    		while(selectRes.next()){
    			int other_price = selectRes.getInt("otherprice");
    			
    			int money = 0;	
    			if(other_price >= 1 && other_price < 5){
    				money += 40;
    			}else if(other_price >= 5 && other_price < 15){
    				money += 250;
    			}else if(other_price >= 15 && other_price < 30){
    				money += 850;
    			}else if(other_price >= 30 && other_price < 100){
    				money += 2000;
    			}else if(other_price >= 100 && other_price < 200){
    				money += 7000;
    			}else if(other_price >= 200){
    				money += 15000;
    			}
    			
    			int actionMoney = 0;
    			if(ServerApplication.application.userinfomanager != null && ServerApplication.application.userinfomanager.options != null && ServerApplication.application.userinfomanager.options.action > 0){
    				actionMoney = (int) Math.floor((double) money * ((double) ServerApplication.application.userinfomanager.options.action / 100));
    			}
    			
    			UserConnection user = getUserBySocialID(selectRes.getString("uidsocial")); 				
				if(user != null && user.user != null){
					ServerApplication.application.userinfomanager.addMoneyReal(user.user.id, money + actionMoney, user);
					user = null;
					
					updatetransaction = _sqlconnection.prepareStatement("UPDATE transactionvk SET status=1 WHERE id=?");
					updatetransaction.setInt(1, selectRes.getInt("id"));
					updatetransaction.executeUpdate();
					
				}
    		}
		} catch (SQLException e) {
			logger.error(e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (select != null) select.close(); 
		    	if (selectRes != null) selectRes.close();		    	
		    	if (updatetransaction != null) updatetransaction.close();
		    	_sqlconnection = null;
		    	select = null;
		    	selectRes = null;		    	
		    	updatetransaction = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void updateTransactionsMM(){
		Connection _sqlconnection = null;		
		PreparedStatement updatetransaction = null;
		PreparedStatement select = null;
		ResultSet selectRes = null;		
		
		try {			
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			select = _sqlconnection.prepareStatement("SELECT * FROM transactionmm WHERE status=?");
			select.setInt(1, 0);
			selectRes = select.executeQuery();
    		while(selectRes.next()){
    			int other_price = selectRes.getInt("otherprice");
    			int transactionid = selectRes.getInt("id");
    			int userid = selectRes.getInt("userid");
    			
    			int money = 0;	
    			if(other_price >= 10 && other_price < 25){
    				money += 60;
    			}else if(other_price >= 25 && other_price < 80){
    				money += 200;
    			}else if(other_price >= 80 && other_price < 120){
    				money += 700;
    			}else if(other_price >= 120 && other_price < 400){
    				money += 1300;
    			}else if(other_price >= 400 && other_price < 1000){
    				money += 4500;
    			}else if(other_price >= 1000){
    				money += 12000;
    			}
    			
    			int actionMoney = 0;
    			if(ServerApplication.application.userinfomanager != null && ServerApplication.application.userinfomanager.options != null && ServerApplication.application.userinfomanager.options.action > 0){
    				actionMoney = (int) Math.floor((double) money * ((double) ServerApplication.application.userinfomanager.options.action / 100));
    			}
    			
    			UserConnection user = users.get(Integer.toString(userid));
    			
    			if(user != null){
	    			ServerApplication.application.userinfomanager.addMoneyReal(userid, money + actionMoney, user);
					user = null;
					
					updatetransaction = _sqlconnection.prepareStatement("UPDATE transactionmm SET status=1 WHERE id=?");
					updatetransaction.setInt(1, transactionid);
					updatetransaction.executeUpdate();
    			}
    		}
		} catch (SQLException e) {
			logger.error(e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (select != null) select.close(); 
		    	if (selectRes != null) selectRes.close();		    	
		    	if (updatetransaction != null) updatetransaction.close();
		    	_sqlconnection = null;
		    	select = null;
		    	selectRes = null;		    	
		    	updatetransaction = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void updateTransactionsOD(){		
		Connection _sqlconnection = null;		
		PreparedStatement updatetransaction = null;
		PreparedStatement select = null;
		ResultSet selectRes = null;		
		
		try {			
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();			
			select = _sqlconnection.prepareStatement("SELECT * FROM transactionod WHERE status=?");
			select.setInt(1, 0);
			selectRes = select.executeQuery();
    		while(selectRes.next()){    			
    			int price = selectRes.getInt("price");    			
    			//String uidsocial = selectRes.getString("uidsocial");
    			int transactionid = selectRes.getInt("id");
    			int userid = selectRes.getInt("userid");
    			
    			int money = 0;	
    			if(price >= 10 && price < 25){
    				money += 60;
    			}else if(price >= 25 && price < 80){
    				money += 200;
    			}else if(price >= 80 && price < 120){
    				money += 700;
    			}else if(price >= 120 && price < 400){
    				money += 1300;
    			}else if(price >= 400 && price < 1000){
    				money += 4500;
    			}else if(price >= 1000){
    				money += 12000;
    			}
    			
    			int actionMoney = 0;
    			if(ServerApplication.application.userinfomanager != null && ServerApplication.application.userinfomanager.options != null && ServerApplication.application.userinfomanager.options.action > 0){
    				actionMoney = (int) Math.floor((double) money * ((double) ServerApplication.application.userinfomanager.options.action / 100));
    			}
    			
    			UserConnection user = ServerApplication.application.commonroom.users.get(Integer.toString(userid));
    			
    			if(user != null && money > 0){
	    			ServerApplication.application.userinfomanager.addMoneyReal(userid, money + actionMoney, user);
					user = null;
					
					updatetransaction = _sqlconnection.prepareStatement("UPDATE transactionod SET status=1 WHERE id=?");
					updatetransaction.setInt(1, transactionid);
					updatetransaction.executeUpdate();
    			}
    		}
		} catch (SQLException e) {
			logger.error(e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (select != null) select.close(); 
		    	if (selectRes != null) selectRes.close();		    	
		    	if (updatetransaction != null) updatetransaction.close();
		    	_sqlconnection = null;
		    	select = null;
		    	selectRes = null;		    	
		    	updatetransaction = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void updateTransactionsSite(){		
		Connection _sqlconnection = null;		
		PreparedStatement updatetransaction = null;
		PreparedStatement select = null;
		ResultSet selectRes = null;		
		
		try {			
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();			
			select = _sqlconnection.prepareStatement("SELECT * FROM transactionsite WHERE status=?");
			select.setInt(1, 0);
			selectRes = select.executeQuery();
    		while(selectRes.next()){    			
    			int price = selectRes.getInt("price");
    			int transactionid = selectRes.getInt("id");
    			int userid = selectRes.getInt("userid");
    			
    			int money = 0;
    			if(price == 20){
    				money += 200;
    			}else if(price == 70){
    				money += 800;
    			}else if(price == 100){
    				money += 1300;
    			}else if(price == 350){
    				money += 4600;
    			}else if(price == 1000){
    				money += 14000;
    			}else if(price == 3000){
    				money += 46000;
    			}else if(price == 3000){
    				money += 46000;
    			}else if(price == 5000){
    				money += 80000;
    			}else if(price == 10000){
    				money += 170000;
    			}
    			
    			int actionMoney = 0;
    			if(ServerApplication.application.userinfomanager != null && ServerApplication.application.userinfomanager.options != null && ServerApplication.application.userinfomanager.options.action > 0){
    				actionMoney = (int) Math.floor((double) money * ((double) ServerApplication.application.userinfomanager.options.action / 100));
    			}
    			
    			UserConnection user = ServerApplication.application.commonroom.users.get(Integer.toString(userid));
    			
    			if(user != null && money > 0){
	    			ServerApplication.application.userinfomanager.addMoneyReal(userid, money + actionMoney, user);
					user = null;
					
					updatetransaction = _sqlconnection.prepareStatement("UPDATE transactionsite SET status=1 WHERE id=?");
					updatetransaction.setInt(1, transactionid);
					updatetransaction.executeUpdate();
    			}
    		}
		} catch (SQLException e) {
			logger.error(e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (select != null) select.close(); 
		    	if (selectRes != null) selectRes.close();		    	
		    	if (updatetransaction != null) updatetransaction.close();
		    	_sqlconnection = null;
		    	select = null;
		    	selectRes = null;		    	
		    	updatetransaction = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void updateClansMoney(){
		Connection _sqlconnection = null;		
		PreparedStatement updateclan = null;
		PreparedStatement select = null;
		ResultSet selectRes = null;
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();			
			select = _sqlconnection.prepareStatement("SELECT * FROM clan WHERE money>0");	
			selectRes = select.executeQuery();
    		while(selectRes.next()){
    			UserConnection user = ServerApplication.application.commonroom.users.get(Integer.toString(selectRes.getInt("ownerid")));
    			if(user != null){
	    			ServerApplication.application.userinfomanager.addMoney(selectRes.getInt("ownerid"), selectRes.getInt("money"), user);
	    			
	    			updateclan = _sqlconnection.prepareStatement("UPDATE clan SET money=0 WHERE ownerid=?");
					updateclan.setInt(1, selectRes.getInt("ownerid"));
					updateclan.executeUpdate();
    			}
    			user = null;
    		}
		} catch (SQLException e) {
			logger.error(e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (select != null) select.close(); 
		    	if (selectRes != null) selectRes.close();		    	
		    	if (updateclan != null) updateclan.close();
		    	_sqlconnection = null;
		    	select = null;
		    	selectRes = null;		    	
		    	updateclan = null;
		    }
		    catch (SQLException sqlx) {
		    }
		}
	}
	
	public void sendHourPrize(){
		Connection _sqlconnection = null;
		PreparedStatement insertitem = null;
		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){
			if(user.getValue().user.exphour > ServerApplication.application.userinfomanager.minExperienceOfTopHourUser){
				ServerApplication.application.userinfomanager.updateUser(user.getValue().user);
			}
		}
		ServerApplication.application.userinfomanager.updateTopHourUsers();
		
		UserForTop usertop;
		for(int i = 0; i < 5; i++){
			usertop = ServerApplication.application.userinfomanager.topHourUsers.get(i);
			if(usertop != null && usertop.exphour > 0){
				try {
					_sqlconnection = ServerApplication.application.sqlpool.getConnection();
					
					insertitem = _sqlconnection.prepareStatement("INSERT INTO usersextractions (userid, type, money) VALUES(?,?,?)");
					insertitem.setInt(1, usertop.id);
					insertitem.setInt(2, MessageType.BEST_HOUR);
					insertitem.setInt(3, Config.exphourprizes.get(i));
					insertitem.executeUpdate();
				} catch (SQLException e) {		
					logger.error(" error exp hour" + e.toString());
				}
				finally
				{
				    try{	    	
				    	if (insertitem != null) insertitem.close();		    	
				    	if (_sqlconnection != null) _sqlconnection.close();
				    	insertitem = null;		    	
				    	_sqlconnection = null;
				    }
				    catch (SQLException sqlx) {		     
				    }
				}						
				sendSystemMessage("Лучший игрок за час. "  + (i + 1) + " место : " + usertop.title + ". Приз - " + Config.exphourprizes.get(i) + " золотых монет.");
			}
		}
		sendSystemMessage("Призы за час будут зачислены на счет победителей в течение 2 минут.");		
		usertop = null;
		setNullExpHour();
	}
	
	private void setNullExpHour(){		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){			
			user.getValue().user.exphour = 0;
		}
		
		Connection _sqlconnection = null;				
		PreparedStatement uppdate = null;
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();			
			uppdate = _sqlconnection.prepareStatement("UPDATE user SET exphour=?");
			uppdate.setInt(1, 0);
			uppdate.executeUpdate();
		} catch (SQLException e) {
			logger.error(e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();		    	
		    	if (uppdate != null) uppdate.close();		    	
		    	_sqlconnection = null;
		    	uppdate = null;		    	
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void sendDayPrize(){
		Connection _sqlconnection = null;
		PreparedStatement insertitem = null;
		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){
			if(user.getValue().user.expday > ServerApplication.application.userinfomanager.minExperienceOfTopDayUser){
				ServerApplication.application.userinfomanager.updateUser(user.getValue().user);
			}
		}
		ServerApplication.application.userinfomanager.updateTopDayUsers();		
		
		UserForTop usertop;
		for(int i = 0; i < 5; i++){
			usertop = ServerApplication.application.userinfomanager.topDayUsers.get(i);
			if(usertop != null && usertop.expday > 0){
				try {
					_sqlconnection = ServerApplication.application.sqlpool.getConnection();
					
					insertitem = _sqlconnection.prepareStatement("INSERT INTO usersextractions (userid, type, money) VALUES(?,?,?)");
					insertitem.setInt(1, usertop.id);
					insertitem.setInt(2, MessageType.BEST_DAY);
					insertitem.setInt(3, Config.expdayprizes.get(i));
					insertitem.executeUpdate();
				} catch (SQLException e) {		
					logger.error(" error exp day" + e.toString());
				}
				finally
				{
				    try{	    	
				    	if (insertitem != null) insertitem.close();		    	
				    	if (_sqlconnection != null) _sqlconnection.close();
				    	insertitem = null;		    	
				    	_sqlconnection = null;
				    }
				    catch (SQLException sqlx) {		     
				    }
				}
				sendSystemMessage("Лучший игрок за день. "  + (i + 1) + " место : " + usertop.title + ". Приз - " + Config.expdayprizes.get(i) + " реалов.");				
			}
		}
		sendSystemMessage("Призы за день будут зачислены на счет победителей в течение 2 минут.");		
		usertop = null;
		setNullExpDay();
	}
	
	private void setNullExpDay(){		
		Set<Entry<String, UserConnection>> set = users.entrySet();
		for (Map.Entry<String, UserConnection> user:set){			
			user.getValue().user.expday = 0;
		}
		
		Connection _sqlconnection = null;				
		PreparedStatement uppdate = null;
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();			
			uppdate = _sqlconnection.prepareStatement("UPDATE user SET expday=?");
			uppdate.setInt(1, 0);
			uppdate.executeUpdate();
		} catch (SQLException e) {
			logger.error(e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();		    	
		    	if (uppdate != null) uppdate.close();		    	
		    	_sqlconnection = null;
		    	uppdate = null;		    	
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void updateUsersExtractions(){
		Connection _sqlconnection = null;
		ResultSet selectRes = null;
		PreparedStatement select = null;
		PreparedStatement delete = null;
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();			
			select = _sqlconnection.prepareStatement("SELECT * FROM usersextractions");	
			
			selectRes = select.executeQuery();    		
			while(selectRes.next()){				
				int eid = selectRes.getInt("id");
				int userid = selectRes.getInt("userid");
				int money = selectRes.getInt("money");
				int type = selectRes.getInt("type");
				
				UserConnection user = users.get(Integer.toString(userid));
				if(user != null){					
					if(type == MessageType.BEST_DAY){
						ServerApplication.application.userinfomanager.addMoneyReal(userid, money, user);
						user.call(ProtocolValues.PROCESS_MESSAGE, JSONObjectBuilder.createObjMessageAuctionPrize(MessageType.BEST_DAY, this.id, money));
					}else if(type == MessageType.BEST_HOUR){
						ServerApplication.application.userinfomanager.addMoneyReal(userid, money, user);
						user.call(ProtocolValues.PROCESS_MESSAGE, JSONObjectBuilder.createObjMessageAuctionPrize(MessageType.BEST_HOUR, this.id, money));
					}else if(type == MessageType.KING_BET){
						ServerApplication.application.userinfomanager.addMoney(userid, money, user);
						user.call(ProtocolValues.PROCESS_MESSAGE, JSONObjectBuilder.createObjMessageAuctionPrize(MessageType.KING_BET, this.id, money));
					}else if(type == MessageType.QUEEN_BET){
						ServerApplication.application.userinfomanager.addMoney(userid, money, user);
						user.call(ProtocolValues.PROCESS_MESSAGE, JSONObjectBuilder.createObjMessageAuctionPrize(MessageType.QUEEN_BET, this.id, money));
					}else if(type == MessageType.KING){
						user.user.updatePopular(user.user.popular + money);
						ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_POPULAR, user.user.money, user.user.popular);
						user.call(ProtocolValues.PROCESS_MESSAGE, JSONObjectBuilder.createObjMessageAuctionPrize(MessageType.KING, this.id, money));
					}else if(type == MessageType.QUEEN){
						user.user.updatePopular(user.user.popular + money);
						ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_POPULAR, user.user.money, user.user.popular);
						user.call(ProtocolValues.PROCESS_MESSAGE, JSONObjectBuilder.createObjMessageAuctionPrize(MessageType.QUEEN, this.id, money));
					}else if(type == MessageType.FRIEND_BONUS){
						ServerApplication.application.userinfomanager.addMoney(userid, money, user);
						sendSystemMessage(user, "Приглашенный вами игрок получил новый уровень. Вам зачислен бонус: " + money + " евро.");
					}
					
					delete = _sqlconnection.prepareStatement("DELETE FROM usersextractions WHERE id=?");
					delete.setInt(1, eid);
					delete.executeUpdate();
				}
    		}	
		} catch (SQLException e) {		
			logger.error(" error exp day" + e.toString());
		}
		finally
		{
		    try{	    	
		    	if (select != null) select.close();		    	
		    	if (selectRes != null) selectRes.close();
		    	if (delete != null) delete.close();
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	select = null;	
		    	delete = null;
		    	selectRes = null;
		    	_sqlconnection = null;
		    }
		    catch (SQLException sqlx) {
		    }
		}
	}
	
	public void updateClans(){
		Connection _sqlconnection = null;
		PreparedStatement update = null;
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			update = _sqlconnection.prepareStatement("UPDATE clan SET expday=?");
			update.setInt(1, 0);
			update.executeUpdate();		
		} catch (SQLException e) {
			logger.error("updateClans error" + e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (update != null) update.close();
		    	_sqlconnection = null;
		    	update = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	class ServerTimerTask extends TimerTask{
        public void run(){
        	update30second++;
        	update2minute++;
        	update5minute++;
        	try{
	        	date = new Date();
				int currenttime = (int)(date.getTime() / 1000);
				
				int second = 1;
				int minute = second * 60;
				int hour = minute * 60;
				int hoursInDay = 24;
				
				int currenthour = (int) Math.floor((float) currenttime / hour);
				int currentminute = (int) Math.floor((float) (currenttime - currenthour * hour) / minute);
				
				if(((currenthour + 6) % hoursInDay == 0) && (currentminute == 0) && lastprizehour != currenthour){			//everyday in 22-00
					lastprizehour = currenthour;
					ServerApplication.application.timerexecutor.execute(new ThreadOnEveryDayCommand());
				}else if(currentminute == 0 && lastprizehour != currenthour){												//every hour
					lastprizehour = currenthour;
					ServerApplication.application.timerexecutor.execute(new ThreadOnEveryHourCommand());
				}
				
				if (update30second >= 3){
					update30second = 0;
					ServerApplication.application.timerexecutor.execute(new ThreadOn30SecondCommand(currenttime));
    			}
				
				if (update2minute >= 6 * 2 + 1){
					update2minute = 0;
					ServerApplication.application.timerexecutor.execute(new ThreadOn2MinuteCommand(currenttime));
				}
				
				if (update5minute >= 6 * 5 + 3){
					update5minute = 0;
					ServerApplication.application.timerexecutor.execute(new ThreadOn5MinuteCommand());
    			}
        	}catch(Throwable e){
        		ServerApplication.application.logger.log("Throwable commonRoom: " + e.toString() + " : " + e.getStackTrace().toString());
        	}
         }  
     }
}
