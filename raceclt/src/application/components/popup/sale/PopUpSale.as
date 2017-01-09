package application.components.popup.sale
{
	import application.components.popup.PopUpTitled;
	
	import utils.models.item.Item;
	
	public class PopUpSale extends PopUpTitled
	{
		private var _info:SaleInfo = new SaleInfo();
		public function PopUpSale(item:Item)
		{
			super();
			_info.init(item);
			_info.closefunction = closepopup;
		}
		
		private function closepopup():void{
			onHide();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_info);
		}
	}
}