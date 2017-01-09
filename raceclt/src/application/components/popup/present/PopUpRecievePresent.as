package application.components.popup.present
{
	import application.components.popup.PopUpTitled;
	
	import utils.models.ItemPrototype;
	import utils.models.car.CarPrototypeModel;
	import utils.models.item.Item;
	
	public class PopUpRecievePresent extends PopUpTitled
	{
		private var content:RecievePresentContent;
		private var prototype:*;
		
		public function PopUpRecievePresent(prototype:*, description:String = "Вам подарок!"){
			super();
			priority = 31;
			this.prototype = prototype;
			
			content = new RecievePresentContent();
			content.description.text = description;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			if(prototype is CarPrototypeModel){
				content.carArticle.init(prototype);
				content.carArticle.visible = content.carArticle.includeInLayout = true;
			}else if(prototype is ItemPrototype){
				content.article.init(Item.createFromItemPrototype(prototype));
				content.article.visible = content.article.includeInLayout = true;
			}
			addElement(content);
		}
	}
}