package application.components.popup.repairAndBrush
{
	import application.components.separator.SeparatorMXML;
	import application.gamecontainer.scene.catalog.bar.tab.CatalogTab;
	import application.gamecontainer.scene.catalog.bar.tab.CatalogTabEvent;
	
	import spark.components.HGroup;
	import spark.layouts.VerticalAlign;
	
	import utils.models.ShopCategory;
	import utils.selector.Selector;
	import utils.selector.SelectorEvent;
	import utils.shop.CategoryType;

	public class RepairAndBrushTabBar extends HGroup
	{
		private var _hash:Object = new Object ();
		private var _tabs:Array = new Array();
		private var _selector:Selector = new Selector ();
		
		private var _tabsGroup:HGroup = new HGroup();
		
		public function get hash():Object{
			return _hash;
		}
		
		public function RepairAndBrushTabBar() {
			verticalAlign = VerticalAlign.BOTTOM;
			
			_selector.addEventListener(SelectorEvent.SELECTED, onSelected, false, 0, true);
			_selector.addEventListener(SelectorEvent.UNSELECTED, onUnselected, false, 0, true);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			_tabsGroup.gap = 0;
			_tabsGroup.verticalAlign = VerticalAlign.BOTTOM;
			
			var underLine:SeparatorMXML = new SeparatorMXML();
			underLine.percentWidth = 100;
			underLine.height = 1;
			
			addElement(_tabsGroup);
			addElement(underLine);
		}
		
		private function onUnselected(event : SelectorEvent) : void {
		}
		
		private function onSelected(event : SelectorEvent) : void {			
		}
		
		public function showGroups(selectedIndex:int = 0) : void {	
			var tabwidth:int = 100;
			
			var sc1:ShopCategory = new ShopCategory(CategoryType.REPAIR_CAR, "Ремонт");
			var tab1:CatalogTab = new CatalogTab();
			tab1.width = tabwidth;
			tab1.init(sc1);
			
			var sc2:ShopCategory = new ShopCategory(CategoryType.BRUSH_CAR, "Покраска");
			var tab2:CatalogTab = new CatalogTab();
			tab2.width = tabwidth;
			tab2.init(sc2);
			
			addTab(tab1);
			addTab(tab2);
			
			(_tabs[selectedIndex] as CatalogTab).selected = true;
		}
		
		public function addTab (tab:CatalogTab):void {
			if (!_hash[tab.category.id]){
				_hash[tab.category.id] = tab;
				_tabs.push(tab);
				tab.addEventListener(CatalogTabEvent.SELECTED, onTabSelected, false, 0, true);
				tab.addEventListener(CatalogTabEvent.UNSELECTED, onTabUnselected, false, 0, true);
				_tabsGroup.addElement(tab);
			}
		}
		
		private function onTabSelected(event : CatalogTabEvent) : void {
			_selector.selected(event.tab);
			dispatchEvent(event.clone());
		}
		
		private function onTabUnselected(event : CatalogTabEvent) : void {
			_selector.unselected(event.tab);
			dispatchEvent(event.clone());
		}
		
		public function removeTab (id:int):void {
			var tab:CatalogTab = _hash[id];
			if (tab){
				for (var i : uint = 0, len:uint = _tabs.length; i <  len; i++) {
					if ((_tabs[i] as CatalogTab).category.id == id){
						_tabs.splice(i, 1);
						break;
					}
				}
				tab.removeEventListener(CatalogTabEvent.SELECTED, onTabSelected);
				tab.removeEventListener(CatalogTabEvent.UNSELECTED, onTabUnselected);
				_tabsGroup.removeElement(tab);
			}
		}
	}
}