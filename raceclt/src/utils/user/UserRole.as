package utils.user
{
	import utils.rank.Rank;

	public class UserRole
	{		
		public static var USER:int = 0;
		public static var MODERATOR:int = 1;
		public static var ADMINISTRATOR:int = 2;
		public static var ADMINISTRATOR_MAIN:int = 3;
		
		public function UserRole()
		{
		}		
		//1 правый разряд у числа - должность в игре
		//2 правый разряд у числа - должность на сайте
		
		public static function isAdministratorMain(params:int):Boolean{
			if(Rank.getValueByRank(params, 1) == ADMINISTRATOR_MAIN)
				return true;
			return false;
		}
		
		public static function isAdministrator(params:int):Boolean{
			if(Rank.getValueByRank(params, 1) == ADMINISTRATOR)
				return true;
			return false;
		}
		
		public static function isModerator(params:int):Boolean{
			if(Rank.getValueByRank(params, 1) == MODERATOR)
				return true;
			return false;
		}
		
		public static function isSimpleUser(params:int):Boolean{
			if(Rank.getValueByRank(params, 1) == USER)
				return true;
			return false;
		}
	}
}