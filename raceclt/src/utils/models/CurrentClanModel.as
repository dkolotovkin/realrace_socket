package utils.models
{
	import mx.collections.ArrayCollection;

	public class CurrentClanModel
	{
		[Bindable]
		public var users:ArrayCollection;
		[Bindable]
		public var iisOwner:Boolean;
		[Bindable]
		public var iinClan:Boolean;
		
		public var countUsers:int;
		
		public var end:Boolean = false;
		public var getting:Boolean = false;
		
		[Bindable]
		public var ownerTitle:String;
		[Bindable]
		public var clanMoney:int;
		[Bindable]
		public var clanExperience:int;
		[Bindable]
		public var clanDayExperience:int;
		[Bindable]
		public var clanAdvert:String;
		
		public var clanId:int;
		
		public var iInClanRoom:Boolean;
		
		public function CurrentClanModel()
		{
			users = new ArrayCollection();
		}
	}
}