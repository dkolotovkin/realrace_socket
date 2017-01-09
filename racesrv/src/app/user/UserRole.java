package app.user;

public class UserRole {
	public static int UNDEFINED = -1;
	public static byte USER = 0;
	public static byte MODERATOR = 1;
	public static byte ADMINISTRATOR = 2;
	public static byte ADMINISTRATOR_MAIN = 3;
	
	public static boolean isAdministratorMain(int params){
		if(params == ADMINISTRATOR_MAIN)
			return true;
		return false;
	}
	
	public static boolean isAdministrator(int params){
		if(params == ADMINISTRATOR)
			return true;
		return false;
	}
	
	public static boolean isModerator(int params){
		if(params == MODERATOR)
			return true;
		return false;
	}
	
	public static boolean isSimpleUser(int params){
		if(params == USER)
			return true;
		return false;
	}
}
