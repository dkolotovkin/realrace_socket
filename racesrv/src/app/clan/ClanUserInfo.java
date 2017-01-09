package app.clan;

public class ClanUserInfo {
	public int clanid;
	public String clantitle;
	public int clandepositm;
	public int clandeposite;
	public byte clanrole;
	public int getclanmoneyat;
	
	public ClanUserInfo(int clanid, String clantitle, int clandepositm, int clandeposite, byte clanrole, int getclanmoneyat){
		this.clanid = clanid;
		this.clantitle = clantitle;
		this.clandepositm = clandepositm;
		this.clandeposite = clandeposite;
		this.clanrole = clanrole;
		this.getclanmoneyat = getclanmoneyat;	
	}
}
