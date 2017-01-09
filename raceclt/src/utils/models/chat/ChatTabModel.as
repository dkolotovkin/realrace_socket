package utils.models.chat
{
	public class ChatTabModel
	{
		public var title:String;
		public var roomId:int;
		[Bindable]
		public var flash:Boolean;
		[Bindable]
		public var selected:Boolean;
		
		public function ChatTabModel()
		{
		}
	}
}