package utils.user
{
	public class ClanUserInfo
	{
		public var clanid:int;
		public var clantitle:String;
		public var clandepositm:int;
		public var clandeposite:int;
		public var clanrole:int;
		public var getclanmoneyat:int;
	
		public function ClanUserInfo(clanid:int, clantitle:String, clandepositm:int, clandeposite:int, clanrole:int, getclanmoneyat:int)
		{
			this.clanid = clanid;
			this.clantitle = clantitle;
			this.clandepositm = clandepositm;
			this.clandeposite = clandeposite;
			this.clanrole = clanrole;
			this.getclanmoneyat = getclanmoneyat;		
		}
	}
}