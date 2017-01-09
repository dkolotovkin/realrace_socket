package application.components.popup.help.tutorial.fist
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpTutorialFirst extends PopUpTitled
	{
		private var content:TutorialFistContent = new TutorialFistContent();
		public function PopUpTutorialFirst()
		{
			super();	
			priority = 1000;
			_closeBt.visible = false;
			title = "Привет!";
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(content);
		}
	}
}