package utils.user
{
	import utils.protocol.ProtocolKeys;

	public class UserFriend extends User
	{
		public var note:String;
		
		public function UserFriend()
		{
			super();
		}
		
		public static function createUserFriendFromObject(u:Object):UserFriend{			
			if(u){
				var user:UserFriend = new UserFriend();
				user.id = int(u[ProtocolKeys.ID]);
				user.idSocial = String(u[ProtocolKeys.ID_SOCIAL]);
				user.sex = int(u[ProtocolKeys.SEX]);
				user.title = String(u[ProtocolKeys.TITLE]);	
				user.level = int(u[ProtocolKeys.LEVEL]);
				user.experience = int(u[ProtocolKeys.EXPERIENCE]);
				user.exphour = int(u[ProtocolKeys.EXP_HOUR]);
				user.expday = int(u[ProtocolKeys.EXP_DAY]);
				user.popular = int(u[ProtocolKeys.POPULAR]);
				user.maxExperience = int(u[ProtocolKeys.NEXT_LEVEL_EXPERIENCE]);				
				user.money = int(u[ProtocolKeys.MONEY]);
				user.moneyReal = int(u[ProtocolKeys.MONEY_REAL]);
				user.role = int(u[ProtocolKeys.ROLE]);
				user.url = String(u[ProtocolKeys.URL]);
				user.isonline = Boolean(u[ProtocolKeys.IS_ONLINE]);
				user.vip = int(u[ProtocolKeys.VIP]);
				user.vipTime = int(u[ProtocolKeys.VIP_TIME]);
				user.note = String(u[ProtocolKeys.DESCRIPTION]);
								
				return user;
			}
			return null;
		}
	}
}