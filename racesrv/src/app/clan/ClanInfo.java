package app.clan;

public class ClanInfo {
	public int id;
	public String title;
	public String ownertitle;
	public int ownerid;
	public int money;
	public int experience;
	public int expday;
	public String advert;
	
	public ClanInfo(int id, String title, String ownertitle, int ownerid, int money, int experience, int expday, String advert){
		this.id = id;
		this.title = title;
		this.ownertitle = ownertitle;
		this.ownerid = ownerid;
		this.money = money;
		this.experience = experience;
		this.expday = expday;
		this.advert = advert;
	}
}
