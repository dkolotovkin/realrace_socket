package app.utils.thread;

import java.nio.channels.SocketChannel;

import app.ServerApplication;
import app.utils.protocol.ProtocolValues;
import atg.taglib.json.util.JSONObject;

public class ThreadMainCommand implements Runnable{
	public int command = 0;
	public SocketChannel connection;
	public JSONObject params;
	
	public ThreadMainCommand(int command, SocketChannel connection, JSONObject params){
		this.command = command;
		this.connection = connection;
		this.params = params;
	}
	
	public void run(){
		if(connection != null && connection.isConnected()){
			if(command == ProtocolValues.SEND_MESSAGE){
				ServerApplication.application.sendMessage(connection, params);
            }else if(command == ProtocolValues.GET_TOP_USERS){
            	ServerApplication.application.gettopusers(connection, params);
            }else if(command == ProtocolValues.GET_TOP_HOUR_USERS){
            	ServerApplication.application.gettophourusers(connection, params);
            }else if(command == ProtocolValues.GET_TOP_DAY_USERS){
            	ServerApplication.application.gettopdayusers(connection, params);
            }else if(command == ProtocolValues.GET_TOP_POPULAR_USERS){
            	ServerApplication.application.gettoppopularusers(connection, params);
            }else if(command == ProtocolValues.GET_CHEATER_LIST){
            	ServerApplication.application.getcheterlist(connection, params);
            }else if(command == ProtocolValues.REMOVE_FROM_CHEATER_LIST){
            	ServerApplication.application.userinfomanager.removeFromCheaterList(connection, params);
            }else if(command == ProtocolValues.BLOCK_CHEATER){
            	ServerApplication.application.userinfomanager.blockCheater(connection, params);
            }else if(command == ProtocolValues.BAN){
            	ServerApplication.application.ban(connection, params);
            }else if(command == ProtocolValues.GET_ONLINE_TIME_MONEY_INFO){
            	ServerApplication.application.getOnlineTimeMoneyInfo(connection, params);
            }else if(command == ProtocolValues.GET_ONLINE_TIME_MONEY){
            	ServerApplication.application.getOnlineTimeMoney(connection, params);
            }else if(command == ProtocolValues.IS_BAD_PLAYER){
            	ServerApplication.application.isBadPlayer(connection, params);
            }else if(command == ProtocolValues.USER_IN_COMMON_ROOM){
            	ServerApplication.application.userInCommonRoom(connection, params);
            }else if(command == ProtocolValues.USER_IN_MODS_ROOM){
            	ServerApplication.application.userInModsRoom(connection, params);
            }else if(command == ProtocolValues.ADMIN_SEND_NOTIFICATION){
            	ServerApplication.application.adminmanager.adminSendNotification(connection, params);
            }else if(command == ProtocolValues.GET_INVITED_USERS){
            	ServerApplication.application.userinfomanager.getInvitedUsers(connection, params);
            }else if(command == ProtocolValues.USER_IN_CLAN_ROOM){
            	ServerApplication.application.userInClanRoom(connection, params);
            }else if(command == ProtocolValues.USER_OUT_CLAN_ROOM){
            	ServerApplication.application.userOutClanRoom(connection, params);
            }else if(command == ProtocolValues.SET_ACTIVE_CAR){
            	ServerApplication.application.userinfomanager.setActiveCar(connection, params);
            }
		}
	}
}
