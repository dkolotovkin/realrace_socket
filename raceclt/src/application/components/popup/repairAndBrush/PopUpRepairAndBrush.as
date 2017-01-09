package application.components.popup.repairAndBrush
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpRepairAndBrush extends PopUpTitled
	{
		private var content:RepairAndBrushContent = new RepairAndBrushContent()
			
		public function PopUpRepairAndBrush()
		{
			super();
			title = "Мастерская"
		}
		
		override protected function createChildren():void{
			super.createChildren();
			
			addElement(content);
		}
	}
}