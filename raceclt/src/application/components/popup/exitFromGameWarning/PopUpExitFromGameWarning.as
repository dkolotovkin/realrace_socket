package application.components.popup.exitFromGameWarning
{
	import application.components.popup.PopUpTitled;

	public class PopUpExitFromGameWarning extends PopUpTitled
	{
		private var content:ExitFromGameWarningContent = new ExitFromGameWarningContent();
		
		public function PopUpExitFromGameWarning()
		{
			super();
			title = "Выход из заезда";
			content.closeFunction = onHide;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(content);
		}
	}
}