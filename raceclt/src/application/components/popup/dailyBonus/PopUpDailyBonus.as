package application.components.popup.dailyBonus
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpDailyBonus extends PopUpTitled
	{
		private var content:DailyBonusContent;
		
		public function PopUpDailyBonus(days:int = 1)
		{
			super();
			
			title = "Бонус за посещение";
			content = new DailyBonusContent();
			content.days = days;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			
			addElement(content);
		}
	}
}