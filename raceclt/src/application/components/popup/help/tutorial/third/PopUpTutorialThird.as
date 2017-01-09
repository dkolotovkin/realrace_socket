package application.components.popup.help.tutorial.third
{
	import application.components.popup.PopUpTitled;

	public class PopUpTutorialThird extends PopUpTitled
	{
		private var content:TutorialThirdContent = new TutorialThirdContent();
		
		public function PopUpTutorialThird()
		{
			super();	
			priority = 1000;
			_closeBt.visible = false;
			title = "Поздравляем!";
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(content);
		}
	}
}