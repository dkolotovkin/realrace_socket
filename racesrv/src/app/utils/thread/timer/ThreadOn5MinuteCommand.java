package app.utils.thread.timer;

import app.ServerApplication;

public class ThreadOn5MinuteCommand implements Runnable {

	public ThreadOn5MinuteCommand(){
	}
	
	public void run(){
		try{
			ServerApplication.application.userinfomanager.updateAdminUsers();
			ServerApplication.application.userinfomanager.updateModeratorUsers();
			ServerApplication.application.userinfomanager.updateTopHourUsers();
			ServerApplication.application.userinfomanager.updateTopDayUsers();
			ServerApplication.application.userinfomanager.updateOptions();
		}catch(Throwable e){				
    		ServerApplication.application.logger.log("ThreadOn5MinuteCommand error: " + e.toString());
    		e.printStackTrace();
    	}
	}
}
