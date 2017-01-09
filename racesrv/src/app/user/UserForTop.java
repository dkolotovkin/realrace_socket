package app.user;

public class UserForTop {
	public int id;
	public int popular;
	public int exphour;
	public int expday;
	public boolean isonline;
	public int vip;
	
	public String title;
	public int level;
	public int sex;
	public int role;
	public String url;
	public Boolean newuser = false;
	
	public UserForTop(int id, int role, int sex, String title, int level, int exphour, int expday, int popular, int vip, String url){
		this.id = id;
		this.role = role;
		this.title = title;
		this.sex = sex;
		this.level = level;
		this.exphour = exphour;
		this.expday = expday;
		this.popular = popular;
		this.url = url;
		this.vip = vip;
	}
}
