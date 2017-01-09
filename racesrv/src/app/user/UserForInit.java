package app.user;

import java.util.List;

import app.clan.ClanUserInfo;

public class UserForInit extends User {
	public int bantime;
	public List<Integer> popularparts;
	public List<String> populartitles;
	
	public UserForInit(int id, String idSocial, String ip, int sex, String title, int popular, int experience, int exphour, int expday, int lastlvl, int money, int moneyreal, int role, byte bantype, int setbanat, int changebanat, String url, ClanUserInfo claninfo, int inviter, int vip, int setvipat){
		super(id, idSocial, ip,  sex, title, popular, experience, exphour, expday, lastlvl, money, moneyreal, role, bantype, setbanat, changebanat, url, claninfo, inviter, vip, setvipat);
	}
	
	public static UserForInit createfromUser(User u){
		if(u != null){
			return new UserForInit(u.id, u.idSocial, u.ip, u.sex, u.title, u.popular, u.experience, u.exphour, u.expday, u.lastlvl, u.money, u.moneyreal, u.role, u.bantype, u.setbanat, u.changebanat, u.url, u.claninfo, u.inviter, u.vip, u.setvipat);
		}else{
			return null;
		}
	}
}
