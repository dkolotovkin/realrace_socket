package app.user;

import app.ServerApplication;

public class UserFriend {
	public int id;
	public int role;
	public String title;
	public int level;
	public int popular;
	public String url;
	public boolean isonline;
	public String note;
	
	public UserFriend(int id, int role, String title, int experience, int popular, String url, String note){
		this.id = id;
		this.role = role;
		this.popular = popular;
		this.title = title;
		this.url = url;
		this.note = note;
		
		setParamsByExperience(experience);
	}
	
	public void setParamsByExperience(int value){
		int level = ServerApplication.application.userinfomanager.getLevelByExperience(value);
		this.level = level;		
	}
}
