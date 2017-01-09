package application.components.popup.articleinfo
{
	import application.components.popup.PopUpTitled;
	
	import utils.models.item.Item;
	
	public class PopUpArticleInfo extends PopUpTitled
	{
		private var _articleInfo:ArticleInfo;
		private var _item:Item;
		
		public function PopUpArticleInfo(item:Item)
		{
			super();
			_item = item;
			_articleInfo = new ArticleInfo();
		}
		
		override protected function createChildren():void{
			super.createChildren();
			_articleInfo.title.text = _item.title;
			_articleInfo.description.text = _item.description;
			_articleInfo.article.init(_item);
			addElement(_articleInfo);
		}
	}
}