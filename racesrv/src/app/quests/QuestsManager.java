package app.quests;

import java.nio.channels.SocketChannel;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import app.ServerApplication;
import app.shop.itemprototype.ItemPrototype;
import app.user.User;
import app.user.UserConnection;
import app.utils.jsonobjectbuilder.JSONObjectBuilder;
import app.utils.jsonutil.JSONUtil;
import app.utils.protocol.ProtocolKeys;
import atg.taglib.json.util.JSONObject;

public class QuestsManager {
	public Map<Integer, QuestGroup> groups;
	public Map<Integer, Quest> quests;
	
	public QuestsManager(){
		groups = new ConcurrentHashMap<Integer, QuestGroup>();
		quests = new ConcurrentHashMap<Integer, Quest>();
		
		/*
		 *  Example
		 */
		
		addGroup(1, "Группа 1");
		addGroup(2, "Группа 2");
		
		addQuest(101, 1, 5, "Получить 5 уровень", 1, 95);
		addQuest(102, 1, 10, "Получить 10 уровень", 1, 78);
		
		addQuest(201, 2, 1, "Подари 30 подарков", 30, 62);
	}
	
	private void addGroup(int groupId, String groupTitle){
		QuestGroup group = new QuestGroup();
		group.id = groupId;
		group.title = groupTitle;
		groups.put(groupId, group);
	}
	
	private void addQuest(int questId, int groupId, int minLevel, String questDescription, int value, int prize){
		Quest quest = new Quest();
		quest.id = questId;
		quest.groupId = groupId;
		quest.minLevel = minLevel;
		quest.description = questDescription;
		quest.value = value;
		quest.prize = prize;
		quests.put(questId, quest);
	}
	
	public void getQuest(SocketChannel connection, JSONObject params){
    	int qid =  JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	int result = 0;
    	
    	UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
    	if(user != null && user.connection.isConnected()){
    		Date date = new Date();
			int currenttime = (int)(date.getTime() / 1000);
			int timepassed = currenttime - user.user.getQuestTime;
			date = null;
			
			int hour8 = 60 * 60 * 8;
    		
    		Quest existQuest = quests.get(qid);
    		if(existQuest != null && user.user.currentQuest == null && timepassed > hour8){
    			UserQuest quest = addAndUpdateQuest(user, qid);
    			
    			Connection _sqlconnection = null;
    			PreparedStatement selectQuest = null;
    			ResultSet selectQuestRes = null;
    			PreparedStatement updateQuest = null;
    			PreparedStatement insertQuest = null;
    			
    			try {
    				_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    				selectQuest = _sqlconnection.prepareStatement("SELECT * FROM quests WHERE uid=? AND qid=?");    				
    				selectQuest.setInt(1, user.user.id);
    				selectQuest.setInt(2, qid);
    				selectQuestRes = selectQuest.executeQuery(); 		
    				
    				if(selectQuestRes.next()){
    					if(selectQuestRes.getInt("status") == UserQuestStatus.IN_WAIT){
    						updateQuest = _sqlconnection.prepareStatement("UPDATE quests SET status=?, value=? WHERE uid=? AND qid=?");
    						updateQuest.setInt(1, UserQuestStatus.PERFORMED);
    						updateQuest.setInt(2, quest.value);
    						updateQuest.setInt(3, user.user.id);
    						updateQuest.setInt(4, qid);
        					if (updateQuest.executeUpdate() > 0){
        						user.user.quests.put(qid, quest);
        						user.user.currentQuest = quest;
        						user.user.updateGetQuestTime();
        						
        						result = qid;
        					}
    					}
    				}else{
    					insertQuest = _sqlconnection.prepareStatement("INSERT INTO quests (uid, qid, status, value) VALUES(?,?,?,?)");
    					insertQuest.setInt(1, user.user.id);
    					insertQuest.setInt(2, qid);
    					insertQuest.setInt(3, UserQuestStatus.PERFORMED);
    					insertQuest.setInt(4, quest.value);
		    			if (insertQuest.executeUpdate() > 0){
		    				user.user.quests.put(qid, quest);
    						user.user.currentQuest = quest;
    						user.user.updateGetQuestTime();
    						
    						result = qid;
		    			}
    				}
    			}catch (SQLException e) {
    				ServerApplication.application.logger.error("QM get quest error " + e.toString());
    			}
    			finally
    			{
    			    try{
    			    	if (_sqlconnection != null) _sqlconnection.close(); 
    			    	if (selectQuest != null) selectQuest.close(); 
    			    	if (selectQuestRes != null) selectQuestRes.close();		    	
    			    	if (updateQuest != null) updateQuest.close();	 
    			    	if (insertQuest != null) insertQuest.close();
    			    	_sqlconnection = null;
    			    	selectQuest = null;
    			    	selectQuestRes = null;
    			    	updateQuest = null;
    			    	insertQuest = null;
    			    }
    			    catch (SQLException sqlx) {		     
    			    }
    			    user = null;
    			}
    		}
    	}
    	
    	ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), result);
	}
	
	private UserQuest addAndUpdateQuest(UserConnection user, int qid){
		UserQuest quest = new UserQuest();
		quest.status = UserQuestStatus.PERFORMED;
		quest.value = 0;
		quest.staticData = ServerApplication.application.questsmanager.quests.get(qid);
		
		if(qid == 101){
			if(user.user.level >= 5){
				quest.value = 1;
			}
		}else if(qid == 102){
			if(user.user.level >= 10){
				quest.value = 1;
			}
		}
		return quest;
	}
	
	public void passQuest(SocketChannel connection, JSONObject params){
		boolean result = false;
		
    	UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
    	if(user != null && user.connection.isConnected()){
    		if(user.user.currentQuest != null){
    			if(user.user.currentQuest.value >= user.user.currentQuest.staticData.value){
    				Connection _sqlconnection = null;
    				PreparedStatement updateQuests = null; 
    				
    				try {
    					_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    					updateQuests = _sqlconnection.prepareStatement("UPDATE quests SET status=?, value=? WHERE uid=? AND qid=?");
    					updateQuests.setInt(1, UserQuestStatus.COMLETED);
    					updateQuests.setInt(2, user.user.currentQuest.staticData.value);
    					updateQuests.setInt(3, user.user.id);
    					updateQuests.setInt(4, user.user.currentQuest.staticData.id);
    					if (updateQuests.executeUpdate() > 0){
    						result = true;
    						
    						addPrize(user, user.user.currentQuest.staticData.prize);
    						
    						Set<Entry<Integer, UserQuest>> set = user.user.quests.entrySet();
    						for (Map.Entry<Integer, UserQuest> quest:set){
    							if(quest.getValue() != null && quest.getValue().staticData != null){
    								if(quest.getValue().status == UserQuestStatus.PERFORMED){
    									quest.getValue().status = UserQuestStatus.COMLETED;
    								}
    							}
    						}
    						set = null;
    						
    			    		if(user.user.currentQuest != null){
    			    			user.user.currentQuest = null;
    			    		}
    					}
    				}catch(SQLException e) {
    					ServerApplication.application.logger.error("QM5" + e.toString());
    				}
    				finally
    				{
    				    try{
    				    	if (_sqlconnection != null) _sqlconnection.close(); 
    				    	if (updateQuests != null) updateQuests.close();
    				    	_sqlconnection = null;
    				    	updateQuests = null;
    				    }
    				    catch (SQLException sqlx) {		     
    				    }
    				}
    			}
    		}
    	}
    	
    	user = null;
    	ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), result);
	}
	
	private void addPrize(UserConnection user, int prize){
		ItemPrototype prototype = ServerApplication.application.shopmanager.itemprototypes.get(prize);
		if(prototype != null){
			addPresent(user, prototype);
		}
	}
	
	private void addPresent(UserConnection user, ItemPrototype p){
		Connection _sqlconnection = null;		
		PreparedStatement insertitem = null;		
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			
			insertitem = _sqlconnection.prepareStatement("INSERT INTO usersitems (iduser, idpresenter, idprototype, count) VALUES(?,?,?,?)");
			insertitem.setInt(1, user.user.id);
			insertitem.setInt(2, user.user.id);
			insertitem.setInt(3, p.id);
			insertitem.setInt(4, p.count);
			insertitem.executeUpdate();
			
			user = null;	
		} catch (SQLException e) {
			ServerApplication.application.logger.error("QM add present error " + e.toString());
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
	}
	
	public void cancelQuest(SocketChannel connection, JSONObject params){
		boolean result = false;
		
    	UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
    	if(user != null && user.connection.isConnected()){
    		Connection _sqlconnection = null;
			PreparedStatement updateQuests = null;    		
    		
			try {
				_sqlconnection = ServerApplication.application.sqlpool.getConnection();
				updateQuests = _sqlconnection.prepareStatement("UPDATE quests SET status=? WHERE uid=? AND status=?");
				updateQuests.setInt(1, UserQuestStatus.IN_WAIT);
				updateQuests.setInt(2, user.user.id);
				updateQuests.setInt(3, UserQuestStatus.PERFORMED);
				updateQuests.executeUpdate();
			}catch(SQLException e){
				ServerApplication.application.logger.error("QM5" + e.toString());
			}
			finally
			{
			    try{
			    	if (_sqlconnection != null) _sqlconnection.close(); 
			    	if (updateQuests != null) updateQuests.close();
			    	_sqlconnection = null;
			    	updateQuests = null;
			    }
			    catch (SQLException sqlx) {		     
			    }
			}
			
    		
    		Set<Entry<Integer, UserQuest>> set = user.user.quests.entrySet();
			for (Map.Entry<Integer, UserQuest> quest:set){
				if(quest.getValue() != null && quest.getValue().staticData != null){
					if(quest.getValue().status == UserQuestStatus.PERFORMED){
						user.user.quests.remove(quest.getKey());
					}
				}
			}
			set = null;
			
    		if(user.user.currentQuest != null){
    			user.user.currentQuest = null;
    		}
    		
    		result = true;
    	}
    	user = null;
    	ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), result);
	}
	
	public void getCurrentQuestValue(SocketChannel connection, JSONObject params){
		int result = 0;
		int time = 0;
		
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
    	if(user != null && user.connection.isConnected()){
    		if(user.user.currentQuest != null){
    			result = user.user.currentQuest.value;
    		}
    		
    		Date date = new Date();
    		int currenttime = (int)(date.getTime() / 1000);
    		int timepassed = currenttime - user.user.getQuestTime;
    		date = null;
    		
    		int hour8 = 60 * 60 * 8;
    		time = Math.max(0, hour8 - timepassed);
    	}
    	
    	ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjCurrentQuestInfo(result, time));
	}
	
	public void chackAndUpdateUserCurrentQuest(User user, int questId){
		if(user.currentQuest != null && user.currentQuest.staticData.id == questId){
			if(questId == 101){	
				if(user.level >= 5 && user.currentQuest.value < user.currentQuest.staticData.value){
					user.currentQuest.value = 1;
					user.currentQuest.change = true;
				}
			}else if(questId == 102){
				if(user.level >= 10 && user.currentQuest.value < user.currentQuest.staticData.value){
					user.currentQuest.value = 1;
					user.currentQuest.change = true;
				}
			}
		}
	}
}
