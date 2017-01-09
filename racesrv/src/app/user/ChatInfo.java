package app.user;

public class ChatInfo {
	public int id;
	public String idSocial;
	public int sex;
	public String title;
	public int role;
	public int level;
	public int popular;
	public String url;
	
	public ChatInfo(int id, String idSocial, int sex, String title, int role, int level, int popular, String url){
		this.id = id;
		this.idSocial = idSocial;
		this.sex = sex;
		this.title = title;
		this.role = role;
		this.level = level;
		this.popular = popular;
		this.url = url;
	}
	
	public static ChatInfo createFromUser(User u){
		if(u != null){
			return new ChatInfo(u.id, u.idSocial, u.sex, u.title, u.role, u.level, u.popular, u.url);
		}
		return null;
	}
}
