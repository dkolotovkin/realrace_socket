package app.db;

import app.Config;

public class DataBaseConfig {
	
	public static String connectionUrl(){
		return "jdbc:mysql://" + mysqlServerHost() +":" + mysqlServerPort() + "/" + dbname() + "?characterEncoding=" + characterEncoding();
	}	
	public static String dbname(){
		return "race";
	}
	public static String dblogin(){
		return "root";
	}
	public static String dbpassward(){
		if(Config.mode() == Config.TEST){
			return "130874";
		}else{
			return "zkc78sfT5";
		}
	}
	
	private static String mysqlServerHost(){
		if(Config.mode() == Config.TEST){
			return "localhost";			
		}else{
			return "localhost";
//			return "109.234.154.125";			
		}
	}
	private static String mysqlServerPort(){
		return "3306";
	}	
	private static String characterEncoding(){
		return "utf8";
	}
}
