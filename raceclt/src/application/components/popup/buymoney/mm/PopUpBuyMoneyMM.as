package application.components.popup.buymoney.mm
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpBuyMoneyMM extends PopUpTitled
	{
		private var _bumoneymmInfo:BuyMoneyMMInfo = new BuyMoneyMMInfo();
		
		public function PopUpBuyMoneyMM()
		{
			super();
			priority = 1000; 
			title = "";	
			_bumoneymmInfo.closeFunction = closePopUp;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_bumoneymmInfo);
		}
		
		public function closePopUp():void{
			onHide();
		}
	}
}