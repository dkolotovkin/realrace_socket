package app.user;

import java.nio.channels.SocketChannel;

import app.Config;
import app.ServerApplication;
import app.clan.ClanUserInfo;
import app.utils.protocol.ProtocolKeys;
import atg.taglib.json.util.JSONArray;
import atg.taglib.json.util.JSONObject;

public class UserConnection {
	public User user;
	public SocketChannel connection;
	
	public UserConnection(int id, String idSocial, String ip, int sex, String title, int popular, int experience, int exphour, 
						int expday, int lastlvl, int money, int moneyreal, int role, byte bantype, int setbanat, int changebanat, 
						String url,	ClanUserInfo claninfo, int inviter, int vip, int setvipat, SocketChannel connection){
		this.connection = connection;		
		user = new User(id, idSocial, ip, sex, title, popular, experience, exphour, expday, lastlvl, 
						money, moneyreal, role, bantype, setbanat, changebanat, url, claninfo, inviter, vip, setvipat);
	}
	
	public void update(int level, int experience, int energy){
		user.update(level, experience, energy);
	}
	
	public void call(int command, JSONObject jobj){
		if(connection != null && connection.isConnected() && jobj != null){
			try{
				jobj.put(ProtocolKeys.COMMAND, command);
				
		        byte [] sendbytes = (jobj.toString() + Config.lineSeparator()).getBytes(Config.characterEncoding());
		        
		        ServerApplication.application.send(connection, sendbytes);		        
	        }catch(Exception exception){	        	
	        	ServerApplication.application.logger.log("UserConnection call command <" + command + "> error: " + exception.toString());
	        }
		}
	}
	
	public void call(int command, String key, JSONArray jarr){
		if(connection != null && connection.isConnected() && jarr != null){
			JSONObject jobj = new JSONObject();
			try{				
				jobj.put(ProtocolKeys.COMMAND, command);
				jobj.put(key, jarr);
				
		        byte [] sendbytes = (jobj.toString() + Config.lineSeparator()).getBytes(Config.characterEncoding());
		        
		        ServerApplication.application.send(connection, sendbytes);
	        }catch(Exception exception){	        	
	        	ServerApplication.application.logger.log("UserConnection call command <" + command + "> error: " + exception.toString());
	        }
		}
	}
}
