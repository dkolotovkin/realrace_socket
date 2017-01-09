package app.utils.thread.timer;

import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import app.ServerApplication;

import app.user.UserConnection;

public class ThreadOn30SecondCommand implements Runnable {
	private int updateTime = 0;
	
	public ThreadOn30SecondCommand(int time){
		updateTime = time;
	}
	
	public void run(){
		try{
			ServerApplication.application.commonroom.updateTransactionsVK();
			ServerApplication.application.commonroom.updateTransactionsMM();
			ServerApplication.application.commonroom.updateTransactionsOD();
			ServerApplication.application.commonroom.updateTransactionsSite();
			
			Set<Entry<String, UserConnection>> set = ServerApplication.application.commonroom.users.entrySet();
    		for (Map.Entry<String, UserConnection> user:set){
    			if(!user.getValue().connection.isConnected()){
    				ServerApplication.application.onDisconnect(user.getValue().connection);
				}
    			ServerApplication.application.commonroom.updateBan(user.getValue(), updateTime);
    		}
    		set = null;
    		
    		ServerApplication.application.commonroom.sendOnlineCountMessage();
		}catch(Throwable e){				
    		ServerApplication.application.logger.log("ThreadOn30SecondCommand error: " + e.toString());
    		e.printStackTrace();
    	}
	}
}
