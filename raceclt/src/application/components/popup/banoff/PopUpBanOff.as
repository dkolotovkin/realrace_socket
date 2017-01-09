package application.components.popup.banoff
{
	import application.GameApplication;
	import application.components.popup.PopUpTitled;
	
	import utils.user.UserRole;
	
	public class PopUpBanOff extends PopUpTitled
	{
		private var _content:BanOffContent = new BanOffContent();
		
		public function PopUpBanOff(price:int)
		{
			super();
			title = "Выход из бана";
			_content.money.money = price;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_content);
		}
	}
}