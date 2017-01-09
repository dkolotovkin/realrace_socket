package application.components.popup.addfriend
{
	import application.components.popup.PopUpTitled;
	
	import utils.user.User;
	
	public class PopUpAddFriend extends PopUpTitled
	{
		private var _content:AddFriend = new AddFriend();
		
		public function PopUpAddFriend(u:User)
		{
			super();
			title = "Добавить в друзья";
			u.isonline = true;
			_content.user = u;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_content);
		}
	}
}