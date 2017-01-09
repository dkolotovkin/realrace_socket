package application.components.popup.saleall
{
	import application.components.popup.PopUpTitled;
	
	public class PopUpSaleAll extends PopUpTitled
	{
		private var _info:SaleInfo = new SaleInfo();
		
		public function PopUpSaleAll()
		{
			super();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_info);
		}
	}
}