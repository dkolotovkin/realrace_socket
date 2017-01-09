package utils.managers.tooltip.types.carPrototype
{
	import application.GameApplication;
	import application.gamecontainer.scene.catalog.article.catalog.CatalogCarArticleRenderer;
	import application.gamecontainer.scene.catalog.article.catalog.CatalogRentCarRenderer;
	
	import utils.managers.tooltip.IToolTiped;
	import utils.managers.tooltip.types.simple.ToolTip;
	
	public class CarPrototypeToolTip extends ToolTip
	{
		private var title:String;
		private var size:String;
		private var power:int;
		private var mass:int;
		private var carClass:int;
		private var minLevel:int;
		
		public function CarPrototypeToolTip()
		{
			super();
			setStyle("skinClass", CarPrototypeToolTipSkin);
		}
		
		override public function updateState() : void {
			if (initialized) {
				(skin as CarPrototypeToolTipSkin).title.text = title;
				(skin as CarPrototypeToolTipSkin).sizeLbl.text = "Объем двигателя: " + size + " л.";
				(skin as CarPrototypeToolTipSkin).powerLbl.text = "Мощность: " + power + " л.с.";
				(skin as CarPrototypeToolTipSkin).massLbl.text = "Macca: " + mass + " кг.";
				(skin as CarPrototypeToolTipSkin).classLbl.text =  "Класс авто: " + carClass;
				(skin as CarPrototypeToolTipSkin).avaliableLbl.text = "Доступно с " + minLevel + " уровня";
				
				if(minLevel <= GameApplication.app.userinfomanager.myuser.level){
					(skin as CarPrototypeToolTipSkin).avaliableLbl.setStyle("color", 0x00ff00);
				}else{
					(skin as CarPrototypeToolTipSkin).avaliableLbl.setStyle("color", 0xff0000);
				}
			}
		}
		
		override public function set target(value : IToolTiped) : void {
			if (value is CatalogCarArticleRenderer){				
				title = CatalogCarArticleRenderer(value).title;
				size = CatalogCarArticleRenderer(value).size;
				power = CatalogCarArticleRenderer(value).power;
				mass = CatalogCarArticleRenderer(value).mass;
				carClass = CatalogCarArticleRenderer(value).carClass;
				minLevel = CatalogCarArticleRenderer(value).minLevel;
				
				updateState();
			}else if (value is CatalogRentCarRenderer){				
				title = CatalogRentCarRenderer(value).title;
				size = CatalogRentCarRenderer(value).size;
				power = CatalogRentCarRenderer(value).power;
				mass = CatalogRentCarRenderer(value).mass;
				carClass = CatalogRentCarRenderer(value).carClass;
				minLevel = CatalogRentCarRenderer(value).minLevel;
				
				updateState();
			}
		}
	}
}