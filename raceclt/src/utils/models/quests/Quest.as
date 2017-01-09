package utils.models.quests
{
	public class Quest
	{
		public var id:int;
		public var groupId:int;
		public var minLevel:int;
		public var description:String;
		public var value:int;
		public var prize:int;
		[Bindable]
		public var status:int;
		[Bindable]
		public var currentValue:int;
		
		public function Quest()
		{
		}
	}
}