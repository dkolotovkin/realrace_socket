package utils.user
{
	import utils.protocol.ProtocolKeys;

	public class UserClanInfo extends User
	{
		public var clandepositm:int;
		public var clandeposite:int;
		public var clanrole:int;
		
		public function UserClanInfo()
		{
			super();
		}
		
		public static function createFromObject(u:Object):UserClanInfo{			
			if(u){
				var user:UserClanInfo = new UserClanInfo();
				user.id = int(u[ProtocolKeys.ID]);
				user.sex = int(u[ProtocolKeys.SEX]);
				user.title = String(u[ProtocolKeys.TITLE]);	
				user.level = int(u[ProtocolKeys.LEVEL]);
				user.experience = int(u[ProtocolKeys.EXPERIENCE]);
				user.exphour = int(u[ProtocolKeys.EXP_HOUR]);
				user.expday = int(u[ProtocolKeys.EXP_DAY]);
				user.popular = int(u[ProtocolKeys.POPULAR]);
				user.maxExperience = int(u[ProtocolKeys.NEXT_LEVEL_EXPERIENCE]);				
				user.money = int(u[ProtocolKeys.MONEY]);
				user.role = int(u[ProtocolKeys.ROLE]);
				user.url = String(u[ProtocolKeys.URL]);
				user.isonline = Boolean(u[ProtocolKeys.IS_ONLINE]);
				
				user.clandepositm = int(u[ProtocolKeys.CLAN_DEPOSIT_M]);
				user.clandeposite = int(u[ProtocolKeys.CLAN_DEPOSIT_E]);
				user.clanrole = int(u[ProtocolKeys.CLAN_ROLE]);
				
				if(u[ProtocolKeys.CLAN_INFO] != null){
					user.claninfo = new ClanUserInfo(u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_ID], u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_TITLE], u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_DEPOSIT_M],
						u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_DEPOSIT_E], u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_ROLE], u[ProtocolKeys.CLAN_INFO][ProtocolKeys.GET_CLAN_MONEY_AT]);
				}
				return user;
			}
			return null;
		}
	}
}