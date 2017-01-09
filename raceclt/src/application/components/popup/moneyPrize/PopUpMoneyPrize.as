package application.components.popup.moneyPrize
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpMoneyPrize extends PopUpTitled
	{
		private var _content:MoneyPrizeContent = new MoneyPrizeContent();
		
		public function PopUpMoneyPrize(prize:int, desc:String = null, real:Boolean = false)
		{
			super();
			priority = 100;
			title = "Поздравляем!";
			_content.init(prize, desc, real);
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_content);
		}
	}
}