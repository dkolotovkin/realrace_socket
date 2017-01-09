package application.components.popup.friendbonus
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpFriendBonus extends PopUpTitled
	{
		private var _content:FriendBonus = new FriendBonus();
		
		public function PopUpFriendBonus()
		{
			super();
			title = "Бонусы за приглашенных";
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_content);
		}
	}
}