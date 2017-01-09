package app.user;

import app.ServerApplication;

public class UserMailMessage {
	public int id;	
	public String title;
	public int level;
	public int popular;
	public String url;
	public boolean isonline;
	public String message;
	public int messageid;
	public String ctime;
	
	public UserMailMessage(int id, String title, int experience, int popular, String url, String ctime){
		this.id = id;
		this.popular = popular;
		this.title = title;
		this.url = url;
		this.ctime = ctime;
		
		setParamsByExperience(experience);
	}
	
	public void setParamsByExperience(int value){
		int level = ServerApplication.application.userinfomanager.getLevelByExperience(value);
		this.level = level;		
	}
}
