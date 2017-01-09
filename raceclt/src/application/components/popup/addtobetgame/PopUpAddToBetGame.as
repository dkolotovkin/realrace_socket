package application.components.popup.addtobetgame
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpAddToBetGame extends PopUpTitled
	{
		private var _info:AddToBetGameInfo = new AddToBetGameInfo();
		
		public function PopUpAddToBetGame(roomID:int)
		{
			super();
			_info.roomID = roomID;
			title = "Вход в заезд";
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_info);
		}
	}
}