package application.components.popup.help.tutorial.map
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpTutorialMap extends PopUpTitled
	{
		private var content:TutorialMapContent = new TutorialMapContent();
		
		public function PopUpTutorialMap()
		{
			super();	
			priority = 1000;
			title = "Карта города!";
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(content);
		}
	}
}