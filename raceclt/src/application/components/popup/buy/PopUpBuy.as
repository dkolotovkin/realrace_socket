package application.components.popup.buy
{
	import application.GameApplication;
	import application.GameMode;
	import application.components.popup.PopUpTitled;
	
	import utils.models.ItemPrototype;
	import utils.models.car.CarPrototypeModel;
	import utils.models.item.Item;
	
	public class PopUpBuy extends PopUpTitled
	{
		private var buyInfo:BuyInfo;
		private var prototype:*;
		
		public function PopUpBuy(prototype:*, description:String = "Поздравляем с успешной покупкой!!"){
			super();
			priority = 31;
			this.prototype = prototype;
			
			buyInfo = new BuyInfo();
			buyInfo.description.text = description;
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