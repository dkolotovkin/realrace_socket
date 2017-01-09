package application.components.popup.buymoney.ng
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpBuyMoneyNg extends PopUpTitled
	{
		private var _bumoneynInfo:BuyMoneyNGInfo = new BuyMoneyNGInfo();
		
		public function PopUpBuyMoneyNg()
		{
			super();
			priority = 1000; 
			title = "";	
			_bumoneynInfo.closeFunction = closePopUp;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_bumoneynInfo);
		}
		
		public function closePopUp():void{
			onHide();
		}
	}
}