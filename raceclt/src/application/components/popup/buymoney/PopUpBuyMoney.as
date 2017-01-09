package application.components.popup.buymoney
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpBuyMoney extends PopUpTitled
	{
		private var _bumoneyInfo:BuyMoneyInfo = new BuyMoneyInfo();
		
		public function PopUpBuyMoney(text:String)
		{
			super();
			priority = 80;
			title = "";
			_bumoneyInfo.text = text;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_bumoneyInfo);
		}
	}
}