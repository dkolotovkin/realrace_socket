package utils.game.action
{
	public class GameActionType
	{
		public static var WAIT_START:uint = 0;
		public static var NOT_ENOUGH_USERS:uint = 1;
		public static var FINISH_EXTRACTION:uint = 2;
		public static var START:uint = 3;
		public static var FINISH:uint = 4;
		public static var ACTION:uint = 5;
		public static var FINISH_BET:uint = 20;
		public static var PASSED_5_SECOND:int = 21;
		public static var RETURN_TO_START:int = 22;
		public static var NEW_LAP:int = 23;
		
		public function GameActionType()
		{
		}
	}
}