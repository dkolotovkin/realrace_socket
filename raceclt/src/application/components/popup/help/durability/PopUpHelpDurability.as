package application.components.popup.help.durability
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpHelpDurability extends PopUpTitled
	{
		private var content:DurabilityContent = new DurabilityContent();
		
		public function PopUpHelpDurability()
		{
			super();			
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(content);
		}
	}
}