package application.components.popup.updateclanadvert
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpUpdateClanAdvert extends PopUpTitled
	{
		private var _content:UpdateClanAdvertContent = new UpdateClanAdvertContent();
		
		public function PopUpUpdateClanAdvert()
		{
			super();
			title = "Дать объявление";
			_content.closefunction = closepopup;
		}
		
		private function closepopup():void{
			onHide();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_content);
		}
	}
}