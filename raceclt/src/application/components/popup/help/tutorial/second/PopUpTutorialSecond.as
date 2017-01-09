package application.components.popup.help.tutorial.second
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpTutorialSecond extends PopUpTitled
	{
		private var content:TutorialSecondContent = new TutorialSecondContent();
		
		public function PopUpTutorialSecond()
		{
			super();	
			priority = 1000;
			_closeBt.visible = false;
			title = "В заезд!";
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(content);
		}
	}
}