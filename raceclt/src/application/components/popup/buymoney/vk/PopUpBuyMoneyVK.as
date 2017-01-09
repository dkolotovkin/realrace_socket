package application.components.popup.buymoney.vk
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpBuyMoneyVK extends PopUpTitled
	{
		private var _bumoneyvkInfo:BuyMoneyVKInfo = new BuyMoneyVKInfo();
		
		public function PopUpBuyMoneyVK()
		{
			super();
			priority = 1000; 
			title = "";	
			_bumoneyvkInfo.closeFunction = closePopUp;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_bumoneyvkInfo);
		}
		
		public function closePopUp():void{
			onHide();
		}
	}
}