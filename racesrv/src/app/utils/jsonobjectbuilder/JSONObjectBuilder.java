package app.utils.jsonobjectbuilder;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import app.Config;
import app.ServerApplication;
import app.clan.ClanAllInfo;
import app.clan.ClanInfo;
import app.clan.CreateClanResult;
import app.clan.UserOfClan;
import app.message.Message;
import app.message.ban.BanMessage;
import app.message.present.MessagePresent;
import app.message.simple.MessageSimple;
import app.quests.UserQuest;
import app.room.Room;
import app.room.gamebet.BetInfo;
import app.room.gamebet.GameBetRoomInfo;
import app.shop.buyMoneyResult.BuyMoneyResult;
import app.shop.buyresult.BuyResult;
import app.shop.car.CarModel;
import app.shop.car.CarPrototypeModel;
import app.shop.item.Item;
import app.shop.item.ItemPresent;
import app.shop.itemprototype.ItemPrototype;
import app.shop.useresult.UseResult;
import app.user.ChatInfo;
import app.user.GameInfo;
import app.user.User;
import app.user.UserConnection;
import app.user.UserForTop;
import app.user.UserFriend;
import app.user.UserMailMessage;
import app.user.chage.ChangeResult;
import app.utils.extraction.ExtractionData;
import app.utils.gameaction.GameAction;
import app.utils.gameaction.start.GameActionStart;
import app.utils.map.MapModel;
import app.utils.protocol.ProtocolKeys;
import atg.taglib.json.util.JSONArray;
import atg.taglib.json.util.JSONObject;

public class JSONObjectBuilder {
	
	public static JSONObject createObjGameAction(byte type, int roomID){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.TYPE, new Integer(type));
			retObj.put(ProtocolKeys.ROOM_ID, new Integer(roomID));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjGameAction(GameAction ga){		
		return createObjGameAction(ga.type, ga.roomId);
	}
	
	public static JSONObject createObjGameActionEvent(byte type, int roomID, byte subtype, int initiatorID, String initiatorTitle, byte position){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.TYPE, new Integer(type));
			retObj.put(ProtocolKeys.ROOM_ID, new Integer(roomID));
			retObj.put(ProtocolKeys.SUBTYPE, new Integer(subtype));
			retObj.put(ProtocolKeys.INITIATOR_ID, new Integer(initiatorID));
			if(initiatorTitle == null){
				retObj.put(ProtocolKeys.INITIATOR_TITLE, "");
			}else{
				retObj.put(ProtocolKeys.INITIATOR_TITLE, initiatorTitle);
			}
			retObj.put(ProtocolKeys.POSITION, new Integer(position));
			
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjGameActionMotion(byte type, int roomID, byte subtype, int initiatorID, Boolean down, double userx, double usery, double rotation, String linerVelocity){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.TYPE, new Integer(type));
			retObj.put(ProtocolKeys.ROOM_ID, new Integer(roomID));
			retObj.put(ProtocolKeys.SUBTYPE, new Integer(subtype));
			retObj.put(ProtocolKeys.INITIATOR_ID, new Integer(initiatorID));
			retObj.put(ProtocolKeys.DOWN, down);
			
			retObj.put(ProtocolKeys.USERX, new Double(userx));
			retObj.put(ProtocolKeys.USERY, new Double(usery));
			retObj.put(ProtocolKeys.ROTATION, new Double(rotation));
			if(linerVelocity == null){
				retObj.put(ProtocolKeys.LINER_VELOCITY, "0:0");
			}else{
				retObj.put(ProtocolKeys.LINER_VELOCITY, linerVelocity);
			}
			
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjGameActionStart(GameActionStart action){		
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.TYPE, new Integer(action.type));
			retObj.put(ProtocolKeys.ROOM_ID, new Integer(action.roomId));
			retObj.put(ProtocolKeys.GAME_TYPE, new Integer(action.gametype));
			retObj.put(ProtocolKeys.DISTRICT, new Integer(action.districtID));
			
			if(action.map != null){
				retObj.put(ProtocolKeys.MAP, createObjMapModel(action.map));
			}
			
			JSONArray retArray;
			
			if(action.users != null &&  action.users.size() > 0){
				retArray = new JSONArray();
				for(int i = 0; i < action.users.size(); i++){
					retArray.add(action.users.get(i));
				}
				retObj.put(ProtocolKeys.USERS, retArray);
			}
			
			if(action.usersCars != null &&  action.usersCars.size() > 0){
				retArray = new JSONArray();
				for(int i = 0; i < action.usersCars.size(); i++){
					retArray.add(action.usersCars.get(i));
				}
				retObj.put(ProtocolKeys.CARS, retArray);
			}
		
			if(action.carsColors != null &&  action.carsColors.size() > 0){
				retArray = new JSONArray();
				for(int i = 0; i < action.carsColors.size(); i++){
					retArray.add(action.carsColors.get(i));
				}
				retObj.put(ProtocolKeys.COLORS, retArray);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMapModel(MapModel map){		
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ID, new Integer(map.id));
			retObj.put(ProtocolKeys.LAPS, new Integer(map.laps));
			retObj.put(ProtocolKeys.TIME, new Integer(map.time));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjGameActionFinishExtraction(byte type, int roomID, ExtractionData extraction, byte position){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.TYPE, new Integer(type));
			retObj.put(ProtocolKeys.ROOM_ID, new Integer(roomID));
			retObj.put(ProtocolKeys.POSITION, new Integer(position));
			
			if(extraction != null){
				JSONObject ext = new JSONObject();
				ext.put(ProtocolKeys.EXPERIENCE, new Integer(extraction.experience));
				ext.put(ProtocolKeys.CEXPERIENCE, new Integer(extraction.cexperience));
				ext.put(ProtocolKeys.MONEY, new Integer(extraction.money));
				ext.put(ProtocolKeys.EXPERIENCE_BONUS, new Integer(extraction.experiencebonus));
				ext.put(ProtocolKeys.CEXPERIENCE_BONUS, new Integer(extraction.cexperiencebonus));
				ext.put(ProtocolKeys.MONEY_BONUS, new Integer(extraction.moneybonus));
				
				retObj.put(ProtocolKeys.EXTRACTION, ext);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjGameActionFinish(byte type, int roomID, int position){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.TYPE, new Integer(type));
			retObj.put(ProtocolKeys.ROOM_ID, new Integer(roomID));
			retObj.put(ProtocolKeys.POSITION, new Integer(position));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}

	public static JSONObject createObjGameActionWaitStart(byte type, int roomID, int waittime){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.TYPE, new Integer(type));
			retObj.put(ProtocolKeys.ROOM_ID, new Integer(roomID));
			retObj.put(ProtocolKeys.WAIT_TIME, new Integer(waittime));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjGameActionWaitStart(byte type, int roomID, int waittime, int code){
		JSONObject retObj = createObjGameActionWaitStart(type, roomID, waittime);
		try{			
			retObj.put(ProtocolKeys.CODE, code);
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjBetInfo(BetInfo bi){				
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.USER_ID, new Integer(bi.userid));
			retObj.put(ProtocolKeys.BET, new Integer(bi.bet));
			retObj.put(ProtocolKeys.BET_USER_ID, new Integer(bi.betuserid));				
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONArray createObjGameBetRoomInfoList(List<GameBetRoomInfo> gbri){
		JSONArray retArray = new JSONArray();
		try{
			if(gbri != null &&  gbri.size() > 0){
				for(int i = 0; i < gbri.size(); i++){
					retArray.add(createObjGameBetRoomInfo(gbri.get(i)));
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retArray;
	}
	
	public static JSONObject createObjGameBetRoomInfo(GameBetRoomInfo gbri){		
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ID, new Integer(gbri.id));
			retObj.put(ProtocolKeys.BET, new Integer(gbri.bet));
			retObj.put(ProtocolKeys.TIME, new Integer(gbri.time));
			retObj.put(ProtocolKeys.RLOCKED, gbri.rlocked);
			retObj.put(ProtocolKeys.ISSEATS, gbri.isseats);
			
			if(gbri.users != null &&  gbri.users.size() > 0){
				JSONArray retArray = new JSONArray();
				for(int i = 0; i < gbri.users.size(); i++){
					retArray.add(gbri.users.get(i));
				}
			retObj.put(ProtocolKeys.USERS, retArray);
		}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessage(byte type, int roomId){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.TYPE, new Integer(type));
			retObj.put(ProtocolKeys.ROOM_ID, new Integer(roomId));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageOnlineCount(byte type, int roomId, int count){		
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			retObj.put(ProtocolKeys.COUNT, new Integer(count));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}

	public static JSONObject createObjMessageSimple(byte type, int roomId, String text, int fromId, int toId){		
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			retObj.put(ProtocolKeys.FROM_ID, new Integer(fromId));
			retObj.put(ProtocolKeys.TO_ID, new Integer(toId));
			if(text == null){
				retObj.put(ProtocolKeys.TEXT, "");
			}else{
				retObj.put(ProtocolKeys.TEXT, text);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageSimple(byte type, int roomId, String text, User fromUser, User toUser){		
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			if(fromUser != null){
				retObj.put(ProtocolKeys.FROM, createObjChatUserInfo(ChatInfo.createFromUser(fromUser)));
			}
			if(toUser != null){
				retObj.put(ProtocolKeys.TO, createObjChatUserInfo(ChatInfo.createFromUser(toUser)));				
			}
			if(text == null){
				retObj.put(ProtocolKeys.TEXT, "");
			}else{
				retObj.put(ProtocolKeys.TEXT, text);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageChangeInfo(byte type, int roomId, byte param, int value1, int value2){
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			retObj.put(ProtocolKeys.PARAM, new Integer(param));
			retObj.put(ProtocolKeys.VALUE1, new Integer(value1));
			retObj.put(ProtocolKeys.VALUE2, new Integer(value2));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageChangeInfo3(byte type, int roomId, byte param, int value1, int value2, int value3){
		JSONObject retObj = createObjMessageChangeInfo(type, roomId, param, value1, value2);
		try{
			retObj.put(ProtocolKeys.VALUE3, new Integer(value3));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}

	public static JSONObject createObjMessageBan(byte type, int roomId, int fromId, int toId, byte bantype){		
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			retObj.put(ProtocolKeys.FROM_ID, new Integer(fromId));			
			retObj.put(ProtocolKeys.TO_ID, new Integer(toId));
			retObj.put(ProtocolKeys.BANTYPE, new Integer(bantype));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageBan(byte type, int roomId, User fromUser, User toUser, byte bantype){		
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			if(fromUser != null){
				retObj.put(ProtocolKeys.FROM, createObjChatUserInfo(ChatInfo.createFromUser(fromUser)));
			}
			if(toUser != null){
				retObj.put(ProtocolKeys.TO, createObjChatUserInfo(ChatInfo.createFromUser(toUser)));
			}
			retObj.put(ProtocolKeys.BANTYPE, new Integer(bantype));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessagePresent(byte type, int roomId, int prototypeid, int price, int pricereal, int fromId, int toId){
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			retObj.put(ProtocolKeys.PROTOTYPE_ID, new Integer(prototypeid));
			retObj.put(ProtocolKeys.PRICE, new Integer(price));
			retObj.put(ProtocolKeys.PRICE_REAL, new Integer(pricereal));
			retObj.put(ProtocolKeys.FROM_ID, new Integer(fromId));
			retObj.put(ProtocolKeys.TO_ID, new Integer(toId));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessagePresent(byte type, int roomId, int prototypeid, int price, int pricereal, User fromUser, User toUser){
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			retObj.put(ProtocolKeys.PROTOTYPE_ID, new Integer(prototypeid));
			retObj.put(ProtocolKeys.PRICE, new Integer(price));
			retObj.put(ProtocolKeys.PRICE_REAL, new Integer(pricereal));
			if(fromUser != null){
				retObj.put(ProtocolKeys.FROM, createObjChatUserInfo(ChatInfo.createFromUser(fromUser)));
			}
			if(toUser != null){
				retObj.put(ProtocolKeys.TO, createObjChatUserInfo(ChatInfo.createFromUser(toUser)));
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageOutStatus(byte type, Room room, int initiatorId){		
		JSONObject retObj = createObjMessage(type, room.id);
		try{
			retObj.put(ProtocolKeys.INITIATOR_ID, new Integer(initiatorId));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjChatUserInfo(ChatInfo chatuserInfo){		
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ID, new Integer(chatuserInfo.id));
			retObj.put(ProtocolKeys.LEVEL, new Integer(chatuserInfo.level));
			retObj.put(ProtocolKeys.SEX, new Integer(chatuserInfo.sex));
			retObj.put(ProtocolKeys.ROLE, new Integer(chatuserInfo.role));
			retObj.put(ProtocolKeys.POPULAR, new Integer(chatuserInfo.popular));
			if(chatuserInfo.title == null){
				retObj.put(ProtocolKeys.TITLE, "");
			}else{
				retObj.put(ProtocolKeys.TITLE, chatuserInfo.title);
			}
			if(chatuserInfo.idSocial == null){
				retObj.put(ProtocolKeys.ID_SOCIAL, "");
			}else{
				retObj.put(ProtocolKeys.ID_SOCIAL, chatuserInfo.idSocial);
			}
			if(chatuserInfo.url == null){
				retObj.put(ProtocolKeys.URL, "");
			}else{
				retObj.put(ProtocolKeys.URL, chatuserInfo.url);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageStatus(byte type, Room room, ChatInfo initiator){
		JSONObject retObj = createObjMessage(type, room.id);
		try{
			if(room.title == null){
				retObj.put(ProtocolKeys.ROOM_TITLE, "");
			}else{
				retObj.put(ProtocolKeys.ROOM_TITLE, room.title);
			}
			
			if(initiator != null){				
				retObj.put(ProtocolKeys.INITIATOR, createObjChatUserInfo(initiator));
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageStatus(byte type, Room room, ChatInfo initiator, List<Message> messages, List<ChatInfo> usersinroom){
		JSONObject retObj = createObjMessageStatus(type, room, initiator);
		try{
			JSONArray retArray = new JSONArray();
			Message m;
			if(messages != null && messages.size() > 0){
				for(int i = 0; i < messages.size(); i++){
					m = messages.get(i);
					if(m != null){
							JSONObject msg = new JSONObject();
							
							int fromUserId = 0;
							int toUserId = 0;
							
							if(m instanceof MessageSimple){
								if(((MessageSimple)m).fromUser != null){
									fromUserId = ((MessageSimple)m).fromUser.id;
								}
								if(((MessageSimple)m).toUser != null){
									toUserId = ((MessageSimple)m).toUser.id;
								}
								msg = createObjMessageSimple(((MessageSimple)m).type, ((MessageSimple)m).roomId, ((MessageSimple)m).text, fromUserId, toUserId);
							}else if(m instanceof MessagePresent){
								if(((MessagePresent)m).fromUser != null){
									fromUserId = ((MessagePresent)m).fromUser.id;
								}
								if(((MessagePresent)m).toUser != null){
									toUserId = ((MessagePresent)m).toUser.id;
								}
								msg = createObjMessagePresent(((MessagePresent)m).type, ((MessagePresent)m).roomId, ((MessagePresent)m).prototypeid, ((MessagePresent)m).prototypeprice, ((MessagePresent)m).prototypepricereal, fromUserId, toUserId);
							}else if(m instanceof BanMessage){
								if(((BanMessage)m).fromUser != null){
									fromUserId = ((BanMessage)m).fromUser.id;
								}
								if(((BanMessage)m).toUser != null){
									toUserId = ((BanMessage)m).toUser.id;
								}
								msg = createObjMessageBan(((BanMessage)m).type, ((BanMessage)m).roomId, fromUserId, toUserId, ((BanMessage)m).bantype);
							}else{
								msg = createObjMessage(m.type, m.roomId);
							}
						retArray.add(msg);
					}
				}
				retObj.put(ProtocolKeys.MESSAGES, retArray);
			}
			
			retArray = new JSONArray();
			ChatInfo ci;
			if(usersinroom != null && usersinroom.size() > 0){
				for(int i = 0; i < usersinroom.size(); i++){
					ci = usersinroom.get(i);
					if(ci != null){							
						retArray.add(createObjChatUserInfo(ci));
					}
				}
				retObj.put(ProtocolKeys.USERS, retArray);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjOnlineUsers(List<ChatInfo> users){
		JSONObject retObj = new JSONObject();
		try{
			JSONArray retArray = new JSONArray();
			
			ChatInfo ci;
			if(users != null && users.size() > 0){
				for(int i = 0; i < users.size(); i++){
					ci = users.get(i);
					if(ci != null){							
						retArray.add(createObjChatUserInfo(ci));
					}
				}
				retObj.put(ProtocolKeys.USERS, retArray);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageStatus(byte type, Room room, ChatInfo initiator, List<Message> messages){
		JSONObject retObj = createObjMessageStatus(type, room, initiator);
		try{
			JSONArray retArray = new JSONArray();
			Message m;
			if(messages != null && messages.size() > 0){
				for(int i = 0; i < messages.size(); i++){
					m = messages.get(i);
					if(m != null){
							JSONObject msg = new JSONObject();
							if(m instanceof MessageSimple){
								msg = createObjMessageSimple(((MessageSimple)m).type, ((MessageSimple)m).roomId, ((MessageSimple)m).text, ((MessageSimple)m).fromUser, ((MessageSimple)m).toUser);
							}else if(m instanceof MessagePresent){
								msg = createObjMessagePresent(((MessagePresent)m).type, ((MessagePresent)m).roomId, ((MessagePresent)m).prototypeid, ((MessagePresent)m).prototypeprice, ((MessagePresent)m).prototypepricereal, ((MessagePresent)m).fromUser, ((MessagePresent)m).toUser);
							}else if(m instanceof BanMessage){
								msg = createObjMessageBan(((BanMessage)m).type, ((BanMessage)m).roomId, ((BanMessage)m).fromUser, ((BanMessage)m).toUser, ((BanMessage)m).bantype);
							}else{
								msg = createObjMessage(m.type, m.roomId);
							}
						retArray.add(msg);
					}
				}
				retObj.put(ProtocolKeys.MESSAGES, retArray);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageBetGameRequest(byte type, int roomId, int userid){
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			retObj.put(ProtocolKeys.USER_ID, new Integer(userid));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjGameUserInfo(GameInfo gameuserInfo){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ID, new Integer(gameuserInfo.id));
			retObj.put(ProtocolKeys.LEVEL, new Integer(gameuserInfo.level));
			retObj.put(ProtocolKeys.SEX, new Integer(gameuserInfo.sex));
			if(gameuserInfo.title == null){
				retObj.put(ProtocolKeys.TITLE, "");
			}else{
				retObj.put(ProtocolKeys.TITLE, gameuserInfo.title);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageStatusGame(byte type, Room room, GameInfo initiator){
		JSONObject retObj = createObjMessage(type, room.id);
		try{
			if(room.title == null){
				retObj.put(ProtocolKeys.ROOM_TITLE, "");
			}else{
				retObj.put(ProtocolKeys.ROOM_TITLE, room.title);
			}
			
			if(initiator != null){				
				retObj.put(ProtocolKeys.INITIATOR, createObjGameUserInfo(initiator));
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageStatusGame(byte type, Room room, GameInfo initiator, List<Message> messages, List<GameInfo> usersinroom){
		JSONObject retObj = createObjMessageStatusGame(type, room, initiator);
		try{
			JSONArray retArray = new JSONArray();
			Message m;
			if(messages != null && messages.size() > 0){
				for(int i = 0; i < messages.size(); i++){
					m = messages.get(i);
					if(m != null){
							JSONObject msg = new JSONObject();
							
							int fromUserId = 0;
							int toUserId = 0;
							
							if(m instanceof MessageSimple){
								if(((MessageSimple)m).fromUser != null){
									fromUserId = ((MessageSimple)m).fromUser.id;
								}
								if(((MessageSimple)m).toUser != null){
									toUserId = ((MessageSimple)m).toUser.id;
								}
								msg = createObjMessageSimple(((MessageSimple)m).type, ((MessageSimple)m).roomId, ((MessageSimple)m).text, fromUserId, toUserId);
							}else if(m instanceof MessagePresent){
								if(((MessagePresent)m).fromUser != null){
									fromUserId = ((MessagePresent)m).fromUser.id;
								}
								if(((MessagePresent)m).toUser != null){
									toUserId = ((MessagePresent)m).toUser.id;
								}
								msg = createObjMessagePresent(((MessagePresent)m).type, ((MessagePresent)m).roomId, ((MessagePresent)m).prototypeid, ((MessagePresent)m).prototypeprice, ((MessagePresent)m).prototypepricereal, fromUserId, toUserId);
							}else if(m instanceof BanMessage){
								if(((BanMessage)m).fromUser != null){
									fromUserId = ((BanMessage)m).fromUser.id;
								}
								if(((BanMessage)m).toUser != null){
									toUserId = ((BanMessage)m).toUser.id;
								}
								msg = createObjMessageBan(((BanMessage)m).type, ((BanMessage)m).roomId, fromUserId, toUserId, ((BanMessage)m).bantype);
							}else{
								msg = createObjMessage(m.type, m.roomId);
							}
						retArray.add(msg);
					}
				}
				retObj.put(ProtocolKeys.MESSAGES, retArray);
			}
			
			retArray = new JSONArray();
			GameInfo gi;
			if(usersinroom != null && usersinroom.size() > 0){
				for(int i = 0; i < usersinroom.size(); i++){
					gi = usersinroom.get(i);
					if(gi != null){														
						retArray.add(createObjGameUserInfo(gi));
					}
				}
				retObj.put(ProtocolKeys.USERS, retArray);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageAuctionPrize(byte type, int roomId, int prize){
		JSONObject retObj = createObjMessage(type, roomId);
		try{
			retObj.put(ProtocolKeys.PRIZE, new Integer(prize));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageNewLevel(byte type, int roomID, int level, int prize){
		JSONObject retObj = createObjMessage(type, roomID);
		try{
			retObj.put(ProtocolKeys.LEVEL, new Integer(level));
			retObj.put(ProtocolKeys.PRIZE, new Integer(prize));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjMessageClanInvite(byte type, int roomID, ClanInfo ci){
		JSONObject retObj = createObjMessage(type, roomID);
		try{			
			if(ci != null){
				retObj.put(ProtocolKeys.CLAN_INFO, createObjClanInfo(ci));
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;		
	}
	
	public static JSONObject createObjFriendsBonusResult(int delta, int countfriends){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.DELTA, new Integer(delta));
			retObj.put(ProtocolKeys.COUNT_FRIENDS, new Integer(countfriends));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjChangeResult(ChangeResult result){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ERROR_CODE, new Integer(result.errorCode));
			retObj.put(ProtocolKeys.USER, createObjUser(result.user));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjBuyResult(BuyResult result){
		JSONObject retObj = new JSONObject();
		try{
			if(result.itemprototype != null){
				retObj.put(ProtocolKeys.ITEM_PROTOTYPE, createObjItemPrototype(result.itemprototype));
			}if(result.car != null){
				retObj.put(ProtocolKeys.CAR, createObjCar(result.car));
			}
			retObj.put(ProtocolKeys.ERROR, new Integer(result.error));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjBuyMoneyResult(BuyMoneyResult result){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ERROR, new Integer(result.error));
			retObj.put(ProtocolKeys.MONEY, new Integer(result.money));
			retObj.put(ProtocolKeys.MONEY_REAL, new Integer(result.moneyreal));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjUseResult(UseResult result){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ERROR, new Integer(result.error));
			retObj.put(ProtocolKeys.ITEM_ID, new Integer(result.itemid));
			retObj.put(ProtocolKeys.ITEM_TYPE, new Integer(result.itemtype));
			retObj.put(ProtocolKeys.COUNT, new Integer(result.count));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONArray createObjUsersMailMessage(ArrayList<UserMailMessage> users){
		JSONArray retArray = new JSONArray();
		try{
			if(users != null && users.size() > 0){
				for(int i = 0; i < users.size(); i++){
					retArray.add(createObjUserMailMessage(users.get(i)));
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retArray;
	}
	
	public static JSONObject createObjUserMailMessage(UserMailMessage user){
		JSONObject retObj = new JSONObject();
		try{
			if(user != null){
				retObj.put(ProtocolKeys.ID, new Integer(user.id));
				retObj.put(ProtocolKeys.POPULAR, new Integer(user.popular));	
				retObj.put(ProtocolKeys.MESSAGE_ID, new Integer(user.messageid));
				retObj.put(ProtocolKeys.IS_ONLINE, user.isonline);
				retObj.put(ProtocolKeys.LEVEL, new Integer(user.level));
				if(user.title == null){
					retObj.put(ProtocolKeys.TITLE, "");
				}else{
					retObj.put(ProtocolKeys.TITLE, user.title);
				}
				if(user.url == null){
					retObj.put(ProtocolKeys.URL, "");
				}else{
					retObj.put(ProtocolKeys.URL, user.url);
				}
				if(user.message == null){
					retObj.put(ProtocolKeys.MESSAGE, "");
				}else{
					retObj.put(ProtocolKeys.MESSAGE, user.message);
					retObj.put(ProtocolKeys.TIME, user.ctime);
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONArray createObjUsersForTop(ArrayList<UserForTop> users){
		JSONArray retArray = new JSONArray();
		try{
			if(users != null && users.size() > 0){
				for(int i = 0; i < users.size(); i++){
					retArray.add(createObjUserForTop(users.get(i)));
				}			
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }		
		return retArray;
	}
	
	public static JSONObject createObjUserForTop(UserForTop user){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ID, new Integer(user.id));
			retObj.put(ProtocolKeys.POPULAR, new Integer(user.popular));
			retObj.put(ProtocolKeys.EXP_HOUR, new Integer(user.exphour));
			retObj.put(ProtocolKeys.EXP_DAY, new Integer(user.expday));
			retObj.put(ProtocolKeys.LEVEL, new Integer(user.level));
			retObj.put(ProtocolKeys.SEX, new Integer(user.sex));
			retObj.put(ProtocolKeys.ROLE, new Integer(user.role));
			retObj.put(ProtocolKeys.IS_ONLINE,user.isonline);
			if(user.title == null){
				retObj.put(ProtocolKeys.TITLE, "");
			}else{
				retObj.put(ProtocolKeys.TITLE, user.title);
			}
			if(user.url == null){
				retObj.put(ProtocolKeys.URL, "");
			}else{
				retObj.put(ProtocolKeys.URL, user.url);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONArray createObjCheaterList(Map<Integer, UserConnection> users){
		JSONArray retArray = new JSONArray();
		try{
			if(users != null && users.size() > 0){
				Set<Entry<Integer, UserConnection>> set = users.entrySet();
				for (Map.Entry<Integer, UserConnection> user:set){
					retArray.add(createObjUser(user.getValue().user));
				}
				set = null;
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }		
		return retArray;
	}
	
	public static JSONObject createAdminAndModeratorUsers(ArrayList<UserForTop> adminUsers, ArrayList<UserForTop> moderatorUsers){
		JSONObject retObj = new JSONObject();		
		try{
			JSONArray adminsArray = new JSONArray();
			if(adminUsers != null && adminUsers.size() > 0){
				for(int i = 0; i < adminUsers.size(); i++){
					adminsArray.add(createObjUserForTop(adminUsers.get(i)));
				}			
			}
			retObj.put(ProtocolKeys.ADMIN_USERS, adminsArray);
			
			JSONArray moderatorArray = new JSONArray();
			if(moderatorUsers != null && moderatorUsers.size() > 0){
				for(int i = 0; i < moderatorUsers.size(); i++){
					moderatorArray.add(createObjUserForTop(moderatorUsers.get(i)));
				}			
			}
			retObj.put(ProtocolKeys.MODERATOR_USERS, moderatorArray);
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }		
		return retObj;
	}
	
	public static JSONArray createObjUsersFriend(ArrayList<UserFriend> users){
		JSONArray retArray = new JSONArray();
		try{
			if(users != null && users.size() > 0){
				for(int i = 0; i < users.size(); i++){
					retArray.add(createObjUserFriend(users.get(i)));
				}			
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }		
		return retArray;
	}
	
	public static JSONObject createObjUserFriend(UserFriend user){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ID, new Integer(user.id));
			retObj.put(ProtocolKeys.ROLE, new Integer(user.role));
			retObj.put(ProtocolKeys.POPULAR, new Integer(user.popular));
			retObj.put(ProtocolKeys.LEVEL, new Integer(user.level));
			retObj.put(ProtocolKeys.IS_ONLINE, user.isonline);
			if(user.title == null){
				retObj.put(ProtocolKeys.TITLE, "");
			}else{
				retObj.put(ProtocolKeys.TITLE, user.title);
			}			
			if(user.url == null){
				retObj.put(ProtocolKeys.URL, "");
			}else{
				retObj.put(ProtocolKeys.URL, user.url);
			}
			if(user.note == null){
				retObj.put(ProtocolKeys.DESCRIPTION, "");
			}else{
				retObj.put(ProtocolKeys.DESCRIPTION, user.note);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjUser(User u){
		JSONObject retObj = new JSONObject();
		try{			
			if(u != null){
				retObj.put(ProtocolKeys.ID, new Integer(u.id));
				retObj.put(ProtocolKeys.SEX, new Integer(u.sex));
				retObj.put(ProtocolKeys.ROLE, new Integer(u.role));
				retObj.put(ProtocolKeys.LEVEL, new Integer(u.level));
				retObj.put(ProtocolKeys.LAST_LEVEL, new Integer(u.lastlvl));
				retObj.put(ProtocolKeys.POPULAR, new Integer(u.popular));
				retObj.put(ProtocolKeys.EXPERIENCE, new Integer(u.experience));
				retObj.put(ProtocolKeys.EXP_HOUR, new Integer(u.exphour));
				retObj.put(ProtocolKeys.EXP_DAY, new Integer(u.expday));
				retObj.put(ProtocolKeys.NEXT_LEVEL_EXPERIENCE, new Integer(u.nextLevelExperience));
				retObj.put(ProtocolKeys.MONEY, new Integer(u.money));
				retObj.put(ProtocolKeys.MONEY_REAL, new Integer(u.moneyreal));
				retObj.put(ProtocolKeys.BANTYPE, new Integer(u.bantype));
				retObj.put(ProtocolKeys.SET_BAN_AT, new Integer(u.setbanat));
				retObj.put(ProtocolKeys.VIP, new Integer(u.vip));
				
				if(u.title == null){
					retObj.put(ProtocolKeys.TITLE, "");
				}else{
					retObj.put(ProtocolKeys.TITLE, u.title);
				}
				if(u.idSocial == null){
					retObj.put(ProtocolKeys.ID_SOCIAL, "");
				}else{
					retObj.put(ProtocolKeys.ID_SOCIAL, u.idSocial);
				}
				if(u.ip == null){
					retObj.put(ProtocolKeys.IP, "");
				}else{
					retObj.put(ProtocolKeys.IP, u.ip);
				}
				if(u.url == null){
					retObj.put(ProtocolKeys.URL, "");
				}else{
					retObj.put(ProtocolKeys.URL, u.url);
				}
				
				if(u.claninfo != null){
					JSONObject claninfo = new JSONObject();
					claninfo.put(ProtocolKeys.CLAN_ID, new Integer(u.claninfo.clanid));
					claninfo.put(ProtocolKeys.CLAN_DEPOSIT_M, new Integer(u.claninfo.clandepositm));
					claninfo.put(ProtocolKeys.CLAN_DEPOSIT_E, new Integer(u.claninfo.clandeposite));
					claninfo.put(ProtocolKeys.CLAN_ROLE, new Integer(u.claninfo.clanrole));
					claninfo.put(ProtocolKeys.GET_CLAN_MONEY_AT, new Integer(u.claninfo.getclanmoneyat));
					if(u.claninfo.clantitle == null){
						retObj.put(ProtocolKeys.CLAN_TITLE, "");
					}else{
						retObj.put(ProtocolKeys.CLAN_TITLE, u.claninfo.clantitle);
					}									
						
					retObj.put(ProtocolKeys.CLAN_INFO, claninfo);
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjInitUser(User u, int bt, int vt, List<Integer> pp, List<String> pt, int count){
		JSONObject retObj = new JSONObject();
		try{
			if(u != null){
				retObj = createObjUser(u);
				retObj.put(ProtocolKeys.BAN_TIME, new Integer(bt));
				retObj.put(ProtocolKeys.VIP_TIME, new Integer(vt));
				retObj.put(ProtocolKeys.COUNT, new Integer(count));
				
				JSONArray retArray = new JSONArray();				
				Set<Entry<Integer, CarModel>> carSet = u.cars.entrySet();
				for (Map.Entry<Integer, CarModel> car:carSet){
					retArray.add(createObjCar(car.getValue()));
				}
				carSet = null;
				retObj.put(ProtocolKeys.CARS, retArray);
				
				JSONObject optionsObj = new JSONObject();
				optionsObj.put(ProtocolKeys.ACTION, new Integer(ServerApplication.application.userinfomanager.options.action));
				retObj.put(ProtocolKeys.OPTIONS, optionsObj);
				
				retArray = new JSONArray();
				if(pp != null && pp.size() > 0){
					for(int i = 0; i < pp.size(); i++){
						retArray.add(pp.get(i));
					}
					retObj.put(ProtocolKeys.POPULAR_PARTS, retArray);
				}
				
				retArray = new JSONArray();
				if(pt != null && pt.size() > 0){
					for(int i = 0; i < pt.size(); i++){
						retArray.add(pt.get(i));
					}
					retObj.put(ProtocolKeys.POPULAR_TITLES, retArray);
				}
				
				if(u.quests != null){
					JSONObject questsObject = new JSONObject();
					Set<Entry<Integer, UserQuest>> set = u.quests.entrySet();
					for (Map.Entry<Integer, UserQuest> quest:set){
						if(quest.getValue() != null && quest.getValue().staticData != null){
							questsObject.put(Integer.toString(quest.getValue().staticData.id), createObjUserQuest(quest.getValue()));
						}
					}
					set = null;
					retObj.put(ProtocolKeys.QUESTS, questsObject);
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjUserInfo(User u, int vt, boolean selfInfo){
		JSONObject retObj = new JSONObject();
		try{
			if(u != null){
				retObj = createObjUser(u);
				retObj.put(ProtocolKeys.VIP_TIME, new Integer(vt));
				
				if(selfInfo && u.quests != null){
					JSONObject questsObject = new JSONObject();
					Set<Entry<Integer, UserQuest>> set = u.quests.entrySet();
					for (Map.Entry<Integer, UserQuest> quest:set){
						if(quest.getValue() != null && quest.getValue().staticData != null){
							questsObject.put(Integer.toString(quest.getValue().staticData.id), createObjUserQuest(quest.getValue()));
						}
					}
					set = null;
					retObj.put(ProtocolKeys.QUESTS, questsObject);
				}
				
				if(u.activeCar != null){
					retObj.put(ProtocolKeys.CAR, createObjCar(u.activeCar));
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjUserQuest(UserQuest quest){
		JSONObject retObj = new JSONObject();
		try{			
			retObj.put(ProtocolKeys.ID, new Integer(quest.staticData.id));
			retObj.put(ProtocolKeys.STATUS, new Integer(quest.status));
			retObj.put(ProtocolKeys.VALUE, new Integer(quest.value));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONArray createObjItemPrototypes(ArrayList<ItemPrototype> itps){		
		JSONArray retArray = new JSONArray();
		try{
			if(itps != null && itps.size() > 0){
				for(int i = 0; i < itps.size(); i++){
					retArray.add(createObjItemPrototype(itps.get(i)));
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }		
		return retArray;
	}
	
	public static JSONObject createObjItemPrototype(ItemPrototype itemp){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ID, new Integer(itemp.id));
			retObj.put(ProtocolKeys.COUNT, new Integer(itemp.count));
			retObj.put(ProtocolKeys.PRICE, new Integer(itemp.price));
			retObj.put(ProtocolKeys.PRICE_REAL, new Integer(itemp.pricereal));
			retObj.put(ProtocolKeys.SHOWED, itemp.showed);
			if(itemp.title == null){
				retObj.put(ProtocolKeys.TITLE, "");
			}else{
				retObj.put(ProtocolKeys.TITLE, itemp.title);
			}
			if(itemp.description == null){
				retObj.put(ProtocolKeys.DESCRIPTION, "");
			}else{
				retObj.put(ProtocolKeys.DESCRIPTION, itemp.description);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjCarPrototype(CarPrototypeModel carPrototype){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ID, new Integer(carPrototype.id));
			retObj.put(ProtocolKeys.CLASS, new Integer(carPrototype.carClass));
			retObj.put(ProtocolKeys.LEVEL, new Integer(carPrototype.minLevel));
			retObj.put(ProtocolKeys.PRICE, new Integer(carPrototype.price));
			retObj.put(ProtocolKeys.PRICE_REAL, new Integer(carPrototype.priceReal));
			if(carPrototype.title == null){
				retObj.put(ProtocolKeys.TITLE, "");
			}else{
				retObj.put(ProtocolKeys.TITLE, carPrototype.title);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjCar(CarModel car){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ID, new Integer(car.id));
			retObj.put(ProtocolKeys.CAR_PROTOTYPE, car.prototype.id);
			retObj.put(ProtocolKeys.COLOR, new Integer(car.color));
			retObj.put(ProtocolKeys.DURABILITY, new Integer(car.durability));
			retObj.put(ProtocolKeys.RENTED, new Integer(car.rented));
			int rentTime = 0;
			if(car.rented == 1){
				Date date = new Date();
				int currenttime = (int)(date.getTime() / 1000);
				date = null;

				rentTime = Math.max(0, car.rentTime + Config.rentCarDuration() - currenttime);
			}
			retObj.put(ProtocolKeys.RENT_TIME, new Integer(rentTime));
			
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjItemPresent(ItemPresent item){
		JSONObject retObj = new JSONObject();
		try{
			if(item != null){			
				retObj.put(ProtocolKeys.ID, new Integer(item.id));
				retObj.put(ProtocolKeys.PROTOTYPE_ID, new Integer(item.prototypeid));
				retObj.put(ProtocolKeys.PRICE, new Integer(item.price));
				retObj.put(ProtocolKeys.PRICE_REAL, new Integer(item.pricereal));
				retObj.put(ProtocolKeys.CATEGORY_ID, new Integer(item.categoryid));
				retObj.put(ProtocolKeys.COUNT, new Integer(item.count));	
				retObj.put(ProtocolKeys.PRESENTER, item.presenter);
				if(item.title == null){
					retObj.put(ProtocolKeys.TITLE, "");
				}else{
					retObj.put(ProtocolKeys.TITLE, item.title);
				}
				if(item.description == null){
					retObj.put(ProtocolKeys.DESCRIPTION, "");
				}else{
					retObj.put(ProtocolKeys.DESCRIPTION, item.description);
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception... " + ex.toString());
        }
		return retObj;		
	}
	
	public static JSONArray createObjItemsPresent(ArrayList<ItemPresent> items){		
		JSONArray retArray = new JSONArray();
		if(items != null && items.size() > 0){
			for(int i = 0; i < items.size(); i++){
				retArray.add(createObjItemPresent(items.get(i)));
			}			
		}
		return retArray;
	}
	
	public static JSONObject createObjItem(Item item){
		JSONObject retObj = new JSONObject();
		try{
			if(item != null){			
				retObj.put(ProtocolKeys.ID, new Integer(item.id));
				retObj.put(ProtocolKeys.PROTOTYPE_ID, new Integer(item.prototypeid));
				retObj.put(ProtocolKeys.PRICE, new Integer(item.price));
				retObj.put(ProtocolKeys.PRICE_REAL, new Integer(item.pricereal));
				retObj.put(ProtocolKeys.CATEGORY_ID, new Integer(item.categoryid));
				retObj.put(ProtocolKeys.COUNT, new Integer(item.count));
				if(item.title == null){
					retObj.put(ProtocolKeys.TITLE, "");
				}else{
					retObj.put(ProtocolKeys.TITLE, item.title);
				}
				if(item.description == null){
					retObj.put(ProtocolKeys.DESCRIPTION, "");
				}else{
					retObj.put(ProtocolKeys.DESCRIPTION, item.description);
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}	
	
	public static JSONArray createObjItems(ArrayList<Item> items){		
		JSONArray retArray = new JSONArray();
		if(items != null && items.size() > 0){
			for(int i = 0; i < items.size(); i++){
				retArray.add(createObjItem(items.get(i)));
			}			
		}
		return retArray;
	}
	
	public static JSONObject createObjClanInfo(ClanInfo ci){
		JSONObject retObj = new JSONObject();
		try{
			if(ci != null){			
				retObj.put(ProtocolKeys.ID, new Integer(ci.id));
				retObj.put(ProtocolKeys.OWNER_ID, new Integer(ci.ownerid));
				retObj.put(ProtocolKeys.MONEY, new Integer(ci.money));
				retObj.put(ProtocolKeys.EXPERIENCE, new Integer(ci.experience));
				retObj.put(ProtocolKeys.EXP_DAY, new Integer(ci.expday));
				if(ci.title == null){
					retObj.put(ProtocolKeys.TITLE, "");
				}else{
					retObj.put(ProtocolKeys.TITLE, ci.title);
				}
				if(ci.ownertitle == null){
					retObj.put(ProtocolKeys.OWNER_TITLE, "");
				}else{
					retObj.put(ProtocolKeys.OWNER_TITLE, ci.ownertitle);
				}
				if(ci.advert == null){
					retObj.put(ProtocolKeys.ADVERT, "");
				}else{
					retObj.put(ProtocolKeys.ADVERT, ci.advert);
				}
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONArray createObjClansInfo(ArrayList<ClanInfo> clans){		
		JSONArray retArray = new JSONArray();
		if(clans != null && clans.size() > 0){
			for(int i = 0; i < clans.size(); i++){
				retArray.add(createObjClanInfo(clans.get(i)));
			}			
		}
		return retArray;
	}
	
	public static JSONObject createObjUserOfClan(UserOfClan user){
		JSONObject retObj = new JSONObject();
		try{
			if(user != null){			
				retObj.put(ProtocolKeys.ID, new Integer(user.id));
				retObj.put(ProtocolKeys.ROLE, new Integer(user.role));
				retObj.put(ProtocolKeys.POPULAR, new Integer(user.popular));
				retObj.put(ProtocolKeys.LEVEL, new Integer(user.level));
				retObj.put(ProtocolKeys.CLAN_DEPOSIT_M, new Integer(user.clandepositm));
				retObj.put(ProtocolKeys.CLAN_DEPOSIT_E, new Integer(user.clandeposite));
				retObj.put(ProtocolKeys.CLAN_ROLE, new Integer(user.clanrole));
				retObj.put(ProtocolKeys.GET_CLAN_MONEY_AT, new Integer(user.getclanmoneyat));
				retObj.put(ProtocolKeys.IS_ONLINE, user.isonline);
				if(user.title == null){
					retObj.put(ProtocolKeys.TITLE, "");
				}else{
					retObj.put(ProtocolKeys.TITLE, user.title);
				}
			}	
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjClanAllInfo(ClanAllInfo callinfo){
		JSONObject retObj = new JSONObject();
		try{
			if(callinfo != null){			
				retObj.put(ProtocolKeys.TIME, new Integer(callinfo.time));
				retObj.put(ProtocolKeys.CLAN_INFO, createObjClanInfo(callinfo.claninfo));
			}	
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjClanUsers(ArrayList<UserOfClan> users){
		JSONObject retObj = new JSONObject();
		try{	
			JSONArray retArray = new JSONArray();
			if(users != null && users.size() > 0){
				for(int i = 0; i < users.size(); i++){
					retArray.add(createObjUserOfClan(users.get(i)));
				}
				retObj.put(ProtocolKeys.USERS, retArray);
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjCreateClanResult(CreateClanResult result){
		JSONObject retObj = new JSONObject();
		try{
			if(result != null){			
				retObj.put(ProtocolKeys.CLAN_ID, new Integer(result.clanid));
				retObj.put(ProtocolKeys.ERROR, new Integer(result.error));
				retObj.put(ProtocolKeys.CLAN_DEPOSIT_E, new Integer(result.clandeposite));
				retObj.put(ProtocolKeys.CLAN_DEPOSIT_M, new Integer(result.clandepositm));
				retObj.put(ProtocolKeys.CLAN_ROLE, new Integer(result.clanrole));
				retObj.put(ProtocolKeys.MONEY, new Integer(result.money));
				if(result.clantitle == null){
					retObj.put(ProtocolKeys.CLAN_TITLE, "");
				}else{
					retObj.put(ProtocolKeys.CLAN_TITLE, result.clantitle);
				}		
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjChangeUserClanResult(int error, int userid, int role){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.ERROR, new Integer(error));
			retObj.put(ProtocolKeys.USER_ID, new Integer(userid));
			retObj.put(ProtocolKeys.ROLE, new Integer(role));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjExtraction(ExtractionData extraction){
		JSONObject retObj = new JSONObject();
		try{
			if(extraction != null){
				retObj.put(ProtocolKeys.EXPERIENCE, new Integer(extraction.experience));
				retObj.put(ProtocolKeys.CEXPERIENCE, new Integer(extraction.cexperience));
				retObj.put(ProtocolKeys.POPULAR, new Integer(extraction.popular));
				retObj.put(ProtocolKeys.MONEY, new Integer(extraction.money));
				retObj.put(ProtocolKeys.EXPERIENCE_BONUS, new Integer(extraction.experiencebonus));
				retObj.put(ProtocolKeys.CEXPERIENCE_BONUS, new Integer(extraction.cexperiencebonus));
				retObj.put(ProtocolKeys.MONEY_BONUS, new Integer(extraction.moneybonus));
			}
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
	
	public static JSONObject createObjCurrentQuestInfo(int value, int time){
		JSONObject retObj = new JSONObject();
		try{
			retObj.put(ProtocolKeys.VALUE, new Integer(value));
			retObj.put(ProtocolKeys.TIME, new Integer(time));
		}catch(Exception ex){
			ServerApplication.application.logger.log("JSONObjectBuilder parser exception...");
        }
		return retObj;
	}
}
