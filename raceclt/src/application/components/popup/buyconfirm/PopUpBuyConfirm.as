package application.components.popup.buyconfirm
{
	import application.components.popup.PopUpTitled;
	
	import utils.models.ItemPrototype;
	import utils.models.car.CarPrototypeModel;
	import utils.models.item.Item;
	
	public class PopUpBuyConfirm extends PopUpTitled
	{
		private var buyInfo:BuyConfirm;
		private var prototype:*;
		
		public function PopUpBuyConfirm(p:*){
			super();
			priority = 31;
			prototype = p;
			
			buyInfo = new BuyConfirm();
			buyInfo.prototype = prototype;
			buyInfo.description.text = "Вы действительно хотите купить эту вещь?";
		}
		
		override protected function createChildren():void{
			super.createChildren();
			if(prototype is CarPrototypeModel){
				buyInfo.carArticle.init(prototype);
				buyInfo.carArticle.visible = buyInfo.carArticle.includeInLayout = true;
			}else if(prototype is ItemPrototype){
				buyInfo.article.init(Item.createFromItemPrototype(prototype));
				buyInfo.article.visible = buyInfo.article.includeInLayout = true;
			}
			addElement(buyInfo);
		}
	}
}