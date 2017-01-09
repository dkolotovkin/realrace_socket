package utils.protocol
{
	public class ProtocolValues
	{
		//commands
		public static var PROCESS_MESSAGE:int = 0;
		public static var PROCESS_GAME_ACTION:int = 1;
		public static var CALLBACK:int = 2;
		
		public static var SEND_MESSAGE:int = 4;
		
		public static var GAME_GO_TO_LEFT:int = 5;
		public static var GAME_GO_TO_RIGHT:int = 6;
		public static var GAME_FORWARD:int = 7;
		public static var GAME_BACK:int = 8;
		public static var GAME_BRAKE:int = 9;
		
		public static var UPDATE_PARAMS:int = 10;
		public static var BAN:int = 11;
		public static var UPDATE_USER:int = 12;
		public static var IS_BAD_PLAYER:int = 13;
		public static var ADD_TO_FRIEND:int = 14;
		public static var ADD_TO_ENEMY:int = 15;
		public static var GET_MAIL_MESSAGES:int = 16;
		public static var REMOVE_MAIL_MESSAGE:int = 17;
		public static var GET_FRIENDS:int = 18;
		public static var GET_POSTS:int = 19;
		public static var GET_ENEMIES:int = 20;
		public static var CHECK_LUCK:int = 21;
		public static var USER_IN_AUCTION:int = 24;
		public static var USER_OUT_AUCTION:int = 25;
		public static var AUCTION_BET:int = 26;
		public static var REMOVE_FRIEND:int = 27;
		public static var REMOVE_ENEMY:int = 28;
		public static var SEND_MAIL:int = 29;
		public static var GET_USER_INFO_BY_ID:int = 30;
		public static var CHANGE_INFO:int = 31;
		public static var START_CHANGE_INFO:int = 32;
		public static var GET_ONLINE_TIME_MONEY_INFO:int = 33;
		public static var GET_ONLINE_TIME_MONEY:int = 34;
		public static var GET_TOP_USERS:int = 35;
		public static var GET_TOP_POPULAR_USERS:int = 36;
		public static var GET_TOP_HOUR_USERS:int = 37;
		public static var GET_TOP_DAY_USERS:int = 38;
		public static var GET_FRIENDS_BONUS:int = 39;
		public static var CONNECT:int = 41;
		public static var DISCONNECT:int = 42;
		public static var LOGIN:int = 43;
		public static var LOGIN_SITE:int = 44;
		public static var INIT_PERS_PARAMS:int = 45;
		public static var PROCESS_USER_PRESENTS:int = 46;
		public static var PROCESS_CURRENT_CLAN_USERS:int = 48;
		public static var PROCESS_FRIENDS:int = 49;
		public static var PROCESS_ENEMIES:int = 50;
		public static var PROCESS_MAIL_MESSAGES:int = 51;
		public static var LOGIN_MB:int = 52;
		public static var PROCESS_PROTOTYPES:int = 53;
		public static var USER_IN_COMMON_ROOM:int = 54;
		public static var USER_IN_MODS_ROOM:int = 55;
		public static var LOGIN_NG:int = 56;
		public static var GET_INVITED_USERS:int = 57;
		public static var BET_AUCTION_REAL:int = 58;
		public static var GET_DAILY_BONUS:int = 59;
		public static var GET_CHEATER_LIST:int = 60;
		public static var REMOVE_FROM_CHEATER_LIST:int = 61;
		public static var BLOCK_CHEATER:int = 62;
		public static var USER_IN_CLAN_ROOM:int = 63;
		public static var USER_OUT_CLAN_ROOM:int = 64
		public static var SOCIAL_POST:int = 65;
		public static var GET_ONLINE_USERS:int = 66;
		public static var SET_ACTIVE_CAR:int = 67;
		
		public static var ADMIN_UPDATE_ALL_USERS_PARAMS:int = 100;
		public static var ADMIN_SET_MODERATOR:int = 101;		
		public static var ADMIN_DELETE_MODERATOR:int = 102;
		public static var ADMIN_DELETE_USER:int = 103;
		public static var ADMIN_SET_PARAM:int = 104;		
		public static var ADMIN_SET_NAME_PARAM:int = 105;		
		public static var ADMIN_SHOW_INFO:int = 106;		
		public static var ADMIN_SEND_NOTIFICATION:int = 107;
		
		public static var CLAN_GET_CLANS_INFO:int = 200;
		public static var CLAN_GET_CLAN_ALL_INFO:int = 201;		
		public static var CLAN_CREATE_CLAN:int = 202;		
		public static var CLAN_INVITE_USER:int = 203;		
		public static var CLAN_INVITE_ACCEPT:int = 204;
		public static var CLAN_KICK:int = 205;		
		public static var CLAN_SET_ROLE:int = 206;		
		public static var CLAN_LEAVE:int = 207;		
		public static var CLAN_RESET:int = 208;		
		public static var CLAN_DESTROY:int = 209;		
		public static var CLAN_GET_MONEY:int = 210;
		public static var CLAN_BUY_EXPERIENCE:int = 211;
		public static var CLAN_GET_CLAN_USERS:int = 212;
		public static var CLAN_UPDATE_ADVERT:int = 213;
		
		public static var SHOP_BUY_VIP_STATUS:int = 300;
		public static var SHOP_GET_ITEM_PROTOTYPES:int = 301;
		public static var SHOP_BUY_CAR:int = 302;
		public static var SHOP_BUY_CAR_COLOR:int = 303;
		public static var SHOP_REPAIR_CAR:int = 304;
		public static var SHOP_BUY_PRESENT:int = 305;		
		public static var SHOP_GET_USER_ITEMS:int = 307;
		public static var SHOP_BUY_LINK:int = 309;
		public static var SHOP_GET_PRICE_BAN_OFF:int = 310;
		public static var SHOP_BUY_BAN_OFF:int = 311;
		public static var SHOP_EXCHANGE_MONEY:int = 312;
		public static var SHOP_USE_GAME_ITEM:int = 314;
		public static var SHOP_SALE_ITEM:int = 316;		
		public static var SHOP_GET_PRESENTS_PRICE:int = 318;
		public static var SHOP_SALE_ALL_PRESENTS:int = 319;
		public static var SHOP_RENT_CAR:int = 320;
		
		public static var GAME_GET_BETS_INFO:int = 400;
		public static var GAME_ADD_TO_BETS_GAME:int = 401;
		public static var GAME_CREATE_BETS_GAME:int = 402;
		public static var GAME_GET_BETS_GAMES_INFO:int = 403;
		public static var GAME_BET:int = 404;
		public static var GAME_SEND_REQUEST_BETS_GAME:int = 405;		
		public static var GAME_ADD_USER_TO_BETS_GAME:int = 406;
		public static var GAME_START_BETS_GAME:int = 407;
		public static var GAME_EXIT_BETS_GAME:int = 408;
		public static var GAME_GET_BET_GAMES_INFO:int = 409;
		public static var GAME_CREATE_BET_GAME:int = 410;
		public static var GAME_ADD_TO_BET_GAME:int = 411;
		public static var GAME_START_REQUEST:int = 412;		
		public static var GAME_USER_OUT:int = 413;
		public static var GAME_USER_EXIT:int = 414;
		public static var GAME_SENSOR_START:int = 415;
		public static var GAME_SENSOR_FINISH:int = 416;
		public static var GAME_SENSOR_ADDITIONAL_ZONE:int = 417;
		
		public static var KINGS_GET_ALL_INFO:int = 700;
		public static var KINGS_BET:int = 701;
		public static var KINGS_ASPIRANT_REQUEST:int = 702;
		
		public static var CASINO_SPIN:int = 800;
		
		public static var QUEST_GET:int = 900;
		public static var QUEST_PASS:int = 901;
		public static var QUEST_CANCEL:int = 902;
		public static var QUEST_GET_CURRENT_VALUE:int = 903;
	}
}