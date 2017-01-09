package app.utils.thread;

import java.nio.channels.SocketChannel;

import app.ServerApplication;
import app.user.UserConnection;
import app.utils.protocol.ProtocolValues;
import atg.taglib.json.util.JSONObject;

public class ThreadCommand implements Runnable{
	public int command = 0;
	public SocketChannel connection;
	public JSONObject params;
	
	public ThreadCommand(int command, SocketChannel connection, JSONObject params){
		this.command = command;
		this.connection = connection;
		this.params = params;
	}
	
	public void run(){
		if(connection != null && connection.isConnected()){
			if(command == ProtocolValues.LOGIN){            	
            	ServerApplication.application.logIn(connection, params);
            }else if(command == ProtocolValues.LOGIN_SITE){
            	ServerApplication.application.loginSite(connection, params);
            }else if(command == ProtocolValues.ADMIN_SHOW_INFO){
            	ServerApplication.application.adminmanager.adminShowInfo(connection, params);
            }else if(command == ProtocolValues.ADMIN_UPDATE_ALL_USERS_PARAMS){
            	ServerApplication.application.adminmanager.adminUpdateAllUsersParams(connection, params);
            }else if(command == ProtocolValues.ADMIN_SET_MODERATOR){
            	ServerApplication.application.adminmanager.adminSetModerator(connection, params);
            }else if(command == ProtocolValues.ADMIN_DELETE_MODERATOR){
            	ServerApplication.application.adminmanager.adminDeleteModerator(connection, params);
            }else if(command == ProtocolValues.ADMIN_DELETE_USER){
            	ServerApplication.application.adminmanager.adminDeleteUser(connection, params);
            }else if(command == ProtocolValues.ADMIN_SET_PARAM){
            	ServerApplication.application.adminmanager.adminSetParam(connection, params);
            }else if(command == ProtocolValues.ADMIN_SET_NAME_PARAM){
            	ServerApplication.application.adminmanager.adminSetNameParam(connection, params);
            }else if(command == ProtocolValues.CHANGE_INFO){
            	ServerApplication.application.changeInfo(connection, params);
            }else if(command == ProtocolValues.ADD_TO_FRIEND){
            	ServerApplication.application.addToFriend(connection, params);
            }else if(command == ProtocolValues.ADD_TO_ENEMY){
            	ServerApplication.application.addToEnemy(connection, params);
            }else if(command == ProtocolValues.REMOVE_FRIEND){
            	ServerApplication.application.removeFriend(connection, params);
            }else if(command == ProtocolValues.REMOVE_ENEMY){
            	ServerApplication.application.removeEnemy(connection, params);
            }else if(command == ProtocolValues.UPDATE_USER){
            	ServerApplication.application.updateUser(connection, params);
            }else if(command == ProtocolValues.UPDATE_PARAMS){
            	ServerApplication.application.updateParams(connection, params);
            }else if(command == ProtocolValues.SEND_MAIL){
            	ServerApplication.application.sendMail(connection, params);
            }else if(command == ProtocolValues.REMOVE_MAIL_MESSAGE){
            	ServerApplication.application.removeMailMessage(connection, params);
            }else if(command == ProtocolValues.GET_POSTS){
            	ServerApplication.application.getPosts(connection, params);
            }else if(command == ProtocolValues.GET_FRIENDS){
            	ServerApplication.application.getFiends(connection, params);
            }else if(command == ProtocolValues.GET_ENEMIES){
            	ServerApplication.application.getEnemies(connection, params);
            }else if(command == ProtocolValues.GET_MAIL_MESSAGES){
            	ServerApplication.application.getMailMessages(connection, params);
            }else if(command == ProtocolValues.GET_FRIENDS_BONUS){
            	ServerApplication.application.getFriendsBonus(connection, params);
            }else if(command == ProtocolValues.GET_USER_INFO_BY_ID){
            	ServerApplication.application.getUserInfoByID(connection, params);
            }else if(command == ProtocolValues.SHOP_GET_USER_ITEMS){
				ServerApplication.application.shopmanager.shopGetUserItems(connection, params);
			}else if(command == ProtocolValues.SHOP_GET_ITEM_PROTOTYPES){
				UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
            	if(user != null){
            		ServerApplication.application.shopmanager.shopGetItemPrototypes(user, params);            		
            	}
			}else if(command == ProtocolValues.SHOP_GET_PRESENTS_PRICE){
				ServerApplication.application.shopmanager.shopGetUserPresentsPrice(connection, params);
            }else if(command == ProtocolValues.SHOP_SALE_ALL_PRESENTS){
            	ServerApplication.application.shopmanager.shopSaleAllPresents(connection, params);
            }else if(command == ProtocolValues.SHOP_GET_PRICE_BAN_OFF){
            	ServerApplication.application.shopmanager.shopGetPriceBanOff(connection, params);
            }else if(command == ProtocolValues.SHOP_BUY_PRESENT){
            	ServerApplication.application.shopmanager.shopBuyPresent(connection, params);
            }else if(command == ProtocolValues.SHOP_BUY_LINK){
            	ServerApplication.application.shopmanager.shopBuyLink(connection, params);
            }else if(command == ProtocolValues.SHOP_BUY_BAN_OFF){
            	ServerApplication.application.shopmanager.shopBuyBanOff(connection, params);
            }else if(command == ProtocolValues.SHOP_EXCHANGE_MONEY){
            	ServerApplication.application.shopmanager.shopExchangeMoney(connection, params);
            }else if(command == ProtocolValues.SHOP_SALE_ITEM){
            	ServerApplication.application.shopmanager.shopSaleItem(connection, params);
            }else if(command == ProtocolValues.SHOP_BUY_VIP_STATUS){
            	ServerApplication.application.shopmanager.shopBuyVipStatus(connection, params);
            }else if(command == ProtocolValues.SHOP_BUY_CAR){
            	ServerApplication.application.shopmanager.shopBuyCar(connection, params);
            }else if(command == ProtocolValues.SHOP_BUY_CAR_COLOR){
            	ServerApplication.application.shopmanager.shopBuyCarColor(connection, params);
            }else if(command == ProtocolValues.SHOP_RENT_CAR){
            	ServerApplication.application.shopmanager.shopRentCar(connection, params);
            }else if(command == ProtocolValues.SHOP_REPAIR_CAR){
            	ServerApplication.application.shopmanager.shopRepairCar(connection, params);
            }else if(command == ProtocolValues.CLAN_GET_CLANS_INFO){
            	ServerApplication.application.clanmanager.clanGetClansInfo(connection, params);
			}else if(command == ProtocolValues.CLAN_GET_CLAN_ALL_INFO){
				ServerApplication.application.clanmanager.clanGetClanAllInfo(connection, params);	
			}else if(command == ProtocolValues.CLAN_GET_CLAN_USERS){
				ServerApplication.application.clanmanager.clanGetClanUsers(connection, params);	
			}else if(command == ProtocolValues.CLAN_GET_MONEY){
				ServerApplication.application.clanmanager.clanGetMoney(connection, params);	
			}else if(command == ProtocolValues.CLAN_CREATE_CLAN){
				ServerApplication.application.clanmanager.clanCreateClan(connection, params);	
			}else if(command == ProtocolValues.CLAN_INVITE_USER){
				ServerApplication.application.clanmanager.clanInviteUser(connection, params);	
			}else if(command == ProtocolValues.CLAN_INVITE_ACCEPT){
				ServerApplication.application.clanmanager.clanInviteAccept(connection, params);	
			}else if(command == ProtocolValues.CLAN_KICK){
				ServerApplication.application.clanmanager.clanKick(connection, params);	
			}else if(command == ProtocolValues.CLAN_SET_ROLE){
				ServerApplication.application.clanmanager.clanSetRole(connection, params);	
			}else if(command == ProtocolValues.CLAN_LEAVE){
				ServerApplication.application.clanmanager.clanLeave(connection, params);	
			}else if(command == ProtocolValues.CLAN_RESET){
				ServerApplication.application.clanmanager.clanReset(connection, params);	
			}else if(command == ProtocolValues.CLAN_DESTROY){
				ServerApplication.application.clanmanager.clanDestroy(connection, params);	
			}else if(command == ProtocolValues.CLAN_BUY_EXPERIENCE){
				ServerApplication.application.clanmanager.clanBuyExperience(connection, params);	
			}else if(command == ProtocolValues.CLAN_UPDATE_ADVERT){
				ServerApplication.application.clanmanager.clanUpdateAdvert(connection, params);	
			}else if(command == ProtocolValues.GET_DAILY_BONUS){
				ServerApplication.application.getDailyBonus(connection, params);	
			}else if(command == ProtocolValues.QUEST_GET){
				ServerApplication.application.questsmanager.getQuest(connection, params);	
			}else if(command == ProtocolValues.QUEST_PASS){
				ServerApplication.application.questsmanager.passQuest(connection, params);
			}else if(command == ProtocolValues.QUEST_CANCEL){
				ServerApplication.application.questsmanager.cancelQuest(connection, params);	
			}else if(command == ProtocolValues.QUEST_GET_CURRENT_VALUE){
				ServerApplication.application.questsmanager.getCurrentQuestValue(connection, params);
			}else if(command == ProtocolValues.SOCIAL_POST){
				ServerApplication.application.userinfomanager.setSocialPostCount(connection, params);
			}else if(command == ProtocolValues.GET_ONLINE_USERS){
				ServerApplication.application.userinfomanager.getOnlineUsers(connection, params);
			}else if(command == ProtocolValues.START_CHANGE_INFO){
            	ServerApplication.application.userinfomanager.startChangeInfo(connection, params);
            }
		}
	}
}
