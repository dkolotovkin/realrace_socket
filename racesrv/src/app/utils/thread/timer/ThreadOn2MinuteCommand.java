package app.utils.thread.timer;

import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import app.ServerApplication;

import app.user.UserConnection;

public class ThreadOn2MinuteCommand implements Runnable {
	private int updateTime = 0;
	
	public ThreadOn2MinuteCommand(int time){
		updateTime = time;
	}
	
	public void run(){
		try{
			Set<Entry<String, UserConnection>> set = ServerApplication.application.commonroom.users.entrySet();
    		for (Map.Entry<String, UserConnection> user:set){
    			ServerApplication.application.commonroom.updateVip(user.getValue(), updateTime);
    		}
    		set = null;
    		
    		ServerApplication.application.commonroom.updateClansMoney();
    		ServerApplication.application.commonroom.updateUsersExtractions();
		}catch(Throwable e){
    		ServerApplication.application.logger.log("ThreadOn2MinuteCommand error: " + e.toString());
    		e.printStackTrace();
    	}
	}
}
