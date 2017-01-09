package app.utils.protocol;

public class ProtocolValues {
	//commands
	public static int PROCESS_MESSAGE = 0;
	public static int PROCESS_GAME_ACTION = 1;
	public static int CALLBACK = 2;	
	
	public static int SEND_MESSAGE = 4;
	
	public static int GAME_GO_TO_LEFT = 5;
	public static int GAME_GO_TO_RIGHT = 6;
	public static int GAME_FORWARD = 7;
	public static int GAME_BACK = 8;
	public static int GAME_BRAKE = 9;
	
	public static int UPDATE_PARAMS = 10;
	public static int BAN = 11;
	public static int UPDATE_USER = 12;
	public static int IS_BAD_PLAYER = 13;
	public static int ADD_TO_FRIEND = 14;
	public static int ADD_TO_ENEMY = 15;
	public static int GET_MAIL_MESSAGES = 16;
	public static int REMOVE_MAIL_MESSAGE = 17;
	public static int GET_FRIENDS = 18;
	public static int GET_POSTS = 19;
	public static int GET_ENEMIES = 20;
	public static int REMOVE_FRIEND = 27;
	public static int REMOVE_ENEMY = 28;
	public static int SEND_MAIL = 29;
	public static int GET_USER_INFO_BY_ID = 30;
	public static int CHANGE_INFO = 31;
	public static int START_CHANGE_INFO = 32;
	public static int GET_ONLINE_TIME_MONEY_INFO = 33;
	public static int GET_ONLINE_TIME_MONEY = 34;
	public static int GET_TOP_USERS = 35;
	public static int GET_TOP_POPULAR_USERS = 36;
	public static int GET_TOP_HOUR_USERS = 37;
	public static int GET_TOP_DAY_USERS = 38;
	public static int GET_FRIENDS_BONUS = 39;
	public static int CONNECT = 41;
	public static int DISCONNECT = 42;
	public static int LOGIN = 43;
	public static int LOGIN_SITE = 44;
	public static int INIT_PERS_PARAMS = 45;
	public static int PROCESS_USER_PRESENTS = 46;
	public static int PROCESS_CURRENT_CLAN_USERS = 48;
	public static int PROCESS_FRIENDS = 49;
	public static int PROCESS_ENEMIES = 50;
	public static int PROCESS_MAIL_MESSAGES = 51;
	public static int PROCESS_PROTOTYPES = 53;
	public static int USER_IN_COMMON_ROOM = 54;
	public static int USER_IN_MODS_ROOM = 55;
	public static int GET_INVITED_USERS = 57;
	public static int GET_DAILY_BONUS = 59;
	public static int GET_CHEATER_LIST = 60;
	public static int REMOVE_FROM_CHEATER_LIST = 61;
	public static int BLOCK_CHEATER = 62;
	public static int USER_IN_CLAN_ROOM = 63;
	public static int USER_OUT_CLAN_ROOM = 64;
	public static int SOCIAL_POST = 65;
	public static int GET_ONLINE_USERS = 66;
	public static int SET_ACTIVE_CAR = 67;
	
	public static int ADMIN_UPDATE_ALL_USERS_PARAMS = 100;
	public static int ADMIN_SET_MODERATOR = 101;		
	public static int ADMIN_DELETE_MODERATOR = 102;
	public static int ADMIN_DELETE_USER = 103;
	public static int ADMIN_SET_PARAM = 104;		
	public static int ADMIN_SET_NAME_PARAM = 105;		
	public static int ADMIN_SHOW_INFO = 106;		
	public static int ADMIN_SEND_NOTIFICATION = 107;
	
	public static int CLAN_GET_CLANS_INFO = 200;
	public static int CLAN_GET_CLAN_ALL_INFO = 201;		
	public static int CLAN_CREATE_CLAN = 202;		
	public static int CLAN_INVITE_USER = 203;		
	public static int CLAN_INVITE_ACCEPT = 204;		
	public static int CLAN_KICK = 205;		
	public static int CLAN_SET_ROLE = 206;		
	public static int CLAN_LEAVE = 207;		
	public static int CLAN_RESET = 208;		
	public static int CLAN_DESTROY = 209;		
	public static int CLAN_GET_MONEY = 210;
	public static int CLAN_BUY_EXPERIENCE = 211;
	public static int CLAN_GET_CLAN_USERS = 212;
	public static int CLAN_UPDATE_ADVERT = 213;
	
	public static int SHOP_BUY_VIP_STATUS = 300;
	public static int SHOP_GET_ITEM_PROTOTYPES = 301;
	public static int SHOP_BUY_CAR = 302;
	public static int SHOP_BUY_CAR_COLOR = 303;
	public static int SHOP_REPAIR_CAR = 304;
	public static int SHOP_BUY_PRESENT = 305;		
	public static int SHOP_GET_USER_ITEMS = 307;
	public static int SHOP_BUY_LINK = 309;
	public static int SHOP_GET_PRICE_BAN_OFF = 310;
	public static int SHOP_BUY_BAN_OFF = 311;
	public static int SHOP_EXCHANGE_MONEY = 312;
	public static int SHOP_SALE_ITEM = 316;
	public static int SHOP_GET_PRESENTS_PRICE = 318;
	public static int SHOP_SALE_ALL_PRESENTS = 319;		
	public static int SHOP_RENT_CAR = 320;
	
	public static int GAME_BET = 404;
	public static int GAME_GET_BET_GAMES_INFO = 409;
	public static int GAME_CREATE_BET_GAME = 410;
	public static int GAME_ADD_TO_BET_GAME = 411;
	public static int GAME_START_REQUEST = 412;
	public static int GAME_USER_EXIT = 414;	
	public static int GAME_SENSOR_START = 415;
	public static int GAME_SENSOR_FINISH = 416;
	public static int GAME_SENSOR_ADDITIONAL_ZONE = 417;
	
	public static int QUEST_GET = 900;
	public static int QUEST_PASS = 901;
	public static int QUEST_CANCEL = 902;
	public static int QUEST_GET_CURRENT_VALUE = 903;
}
