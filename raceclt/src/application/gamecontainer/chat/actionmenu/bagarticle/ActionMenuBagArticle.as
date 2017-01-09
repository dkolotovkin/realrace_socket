package application.gamecontainer.chat.actionmenu.bagarticle
{
	import application.GameApplication;
	import application.components.popup.articleinfo.PopUpArticleInfo;
	import application.components.popup.sale.PopUpSale;
	import application.gamecontainer.chat.actionmenu.ActionMenu;
	import application.gamecontainer.chat.actionmenu.Actions;
	import application.gamecontainer.chat.actionmenu.title.ArticleTitle;
	import application.gamecontainer.chat.actionmenu.title.TargetTitle;
	
	import utils.models.item.Item;
	
	public class ActionMenuBagArticle extends ActionMenu
	{
		private var _item:Item;
		
		public function ActionMenuBagArticle(item : Item) {
			super();
			_item = item;			
			title = _item.title;
		}
		
		override protected function createChildren() : void {
			super.createChildren();
			_titleComponent.setTitle("", true, 0);
			addAndCreateControl(Actions.INFO, "Информация");
			addAndCreateControl(Actions.SALE, "Продать");
			//addAndCreateControl(Actions.USE, "Использовать");
		}
		
		override protected function getTitleComponent ():TargetTitle{
			return new ArticleTitle();
		}
		
		override protected function onAction(id : String) : void {
			super.onAction(id);			
			if (id == Actions.INFO){
				GameApplication.app.popuper.show(new PopUpArticleInfo(_item));
			}else if(id == Actions.SALE){				 
				GameApplication.app.popuper.show(new PopUpSale(_item));
			}
		}
	}
}