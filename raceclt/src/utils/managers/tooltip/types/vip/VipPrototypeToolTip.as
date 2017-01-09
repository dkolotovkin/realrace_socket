package utils.managers.tooltip.types.vip
{
	import application.gamecontainer.scene.catalog.article.catalog.CatalogArticleRenderer;
	
	import utils.managers.tooltip.IToolTiped;
	import utils.managers.tooltip.types.simple.ToolTip;
	
	public class VipPrototypeToolTip extends ToolTip
	{
		private var title:String;
		private var description:String;
		
		public function VipPrototypeToolTip()
		{
			super();
			setStyle("skinClass", VipPrototypeToolTipSkin);
		}
		
		override public function updateState() : void {
			if (initialized) {
				(skin as VipPrototypeToolTipSkin).title.text = title;
				(skin as VipPrototypeToolTipSkin).description.text = description;
			}
		}
		
		override public function set target(value : IToolTiped) : void {			
			if (value is CatalogArticleRenderer){
				title = CatalogArticleRenderer(value).tooltiptitle;
				description = CatalogArticleRenderer(value).tooltipdescription;
				updateState();
			}
		}
	}
}