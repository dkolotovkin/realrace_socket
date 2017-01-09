package application.components.popup.gamebet
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpGameBet extends PopUpTitled
	{
		private var content:GameBetContent;
		
		public function PopUpGameBet()
		{
			super();
			
			title = "Заезды на деньги";
			
			content = new GameBetContent();
		}
		
		override public function onHide():Boolean{
			content && content.onHide();
			
			return super.onHide();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			
			addElement(content);
		}
	}
}