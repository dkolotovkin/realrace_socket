package application.components.popup.help
{
	import application.components.popup.PopUpTitled;
	
	import utils.shop.CategoryType;
	
	public class PopUpHelp extends PopUpTitled
	{
		private var _help:Help = new Help();
		public function PopUpHelp(selectCategory:int)
		{
			super();
			
			_help.selectCategory = selectCategory;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_help);
		}
	}
}