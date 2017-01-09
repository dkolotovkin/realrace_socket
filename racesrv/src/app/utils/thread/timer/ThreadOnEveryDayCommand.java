package app.utils.thread.timer;

import app.ServerApplication;

public class ThreadOnEveryDayCommand implements Runnable {

	public ThreadOnEveryDayCommand(){
	}
	
	public void run(){
		try{
			ServerApplication.application.commonroom.sendDayPrize();
			ServerApplication.application.commonroom.updateClans();
		}catch(Throwable e){
    		ServerApplication.application.logger.log("ThreadOnEveryDayCommand error: " + e.toString());
    		e.printStackTrace();
    	}
	}
}
