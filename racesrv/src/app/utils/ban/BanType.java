package app.utils.ban;

import app.utils.rank.Rank;

public class BanType {
	public static byte NO_BAN = 0;
	public static byte MINUT5 = 1;
	public static byte MINUT15 = 2;
	public static byte MINUT30 = 3;
	public static byte HOUR1 = 4;
	public static byte DAY1 = 5;
	public static byte WEEK = 6;
	
	public static boolean noBan(int params){
		if(params == NO_BAN)
			return true;
		return false;
	}
	
	public static boolean by5Minut(int params){
		if(params == MINUT5)
			return true;
		return false;
	}
	
	public static boolean by15Minut(int params){
		if(params == MINUT15)
			return true;
		return false;
	}
	
	public static boolean by30Minut(int params){
		if(params == MINUT30)
			return true;
		return false;
	}
	
	public static boolean byHour(int params){
		if(Rank.getValueByRank(params, 1) == HOUR1)
			return true;
		return false;
	}
	
	public static boolean byDay(int params){
		if(Rank.getValueByRank(params, 1) == DAY1)
			return true;
		return false;
	}
	
	public static boolean byWeek(int params){
		if(params == WEEK)
			return true;
		return false;
	}
}
