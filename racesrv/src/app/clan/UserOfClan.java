package app.clan;

public class UserOfClan {
	public int id;
	public int role;
	public String title;
	public int popular;
	public int level;
	public boolean isonline;
	
	public int clandepositm;
	public int clandeposite;
	public byte clanrole;
	public int getclanmoneyat;
	
	public UserOfClan(int id, int role, String title, int level, int popular, int clandepositm, int clandeposite, byte clanrole, int getclanmoneyat){
		this.id = id;
		this.role = role;
		this.title = title;
		this.level = level;
		this.popular = popular;
		this.clandepositm = clandepositm;
		this.clandeposite = clandeposite;
		this.clanrole = clanrole;
		this.getclanmoneyat = getclanmoneyat;		
	}
}
