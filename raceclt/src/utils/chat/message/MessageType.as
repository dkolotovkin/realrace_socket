package utils.chat.message
{
	public class MessageType
	{
		public static var USER_IN:uint = 0;
		public static var USER_OUT:uint = 1;
		public static var MESSAGE:uint = 2;
		public static var PRIVATE:uint = 3;
		public static var CHANGEINFO:uint = 4;
		public static var SYSTEM:uint = 5;
		public static var USEITEM:uint = 6;
		public static var BAN:uint = 7;
		public static var BAN_OUT:uint = 8;
		
		public static var CLAN_INVITE:uint = 11;
		public static var CLAN_KICK:uint = 12;
		
		public static var PRESENT:uint = 13;
		public static var NEW_LEVEL:uint = 14;
		public static var START_INFO:uint = 19;
		
		public static var BEST_HOUR:uint = 20;
		public static var BEST_DAY:uint = 21;
		public static var FRIEND_BONUS:uint = 26;
		
		public static var USER_NOT_FIND:int = 30;
		public static var ONLINE_COUNT:int = 31;
		
		public function MessageType()
		{
		}
	}
}