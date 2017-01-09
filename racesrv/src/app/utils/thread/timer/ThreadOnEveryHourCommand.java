package app.utils.thread.timer;

import java.io.File;

import app.ServerApplication;


public class ThreadOnEveryHourCommand implements Runnable {
	
	public ThreadOnEveryHourCommand(){
	}
	
	public void run(){
		try{
			ServerApplication.application.setupDataSource();
			ServerApplication.application.commonroom.sendHourPrize();
			
			//удаление закачанных для постов на стену фотографий
			File dir = new File("/var/www/html/images/upload");
			if (dir.isDirectory()) {
				String[] children = dir.list();
				for (int i=0; i<children.length; i++) {
					File f = new File(dir, children[i]);
					if(f.exists()){
						f.delete();		    						
					}
				}
			}
			
			ServerApplication.application.userinfomanager.updateTopUsers();
			ServerApplication.application.userinfomanager.updatePopularTopUsers();
		}catch(Throwable e){
    		ServerApplication.application.logger.log("ThreadOnEveryHourCommand error: " + e.toString());
    		e.printStackTrace();
    	}
	}
}
