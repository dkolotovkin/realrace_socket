package utils.models.item
{
	import utils.models.ItemPrototype;

	public class Item
	{
		public var id:int;
		public var prototypeid:int;
		public var price:int;
		public var pricereal:int;
		public var title:String;
		public var description:String;
		[Bindable]
		public var count:int;
		
		public function Item(id:int){
			this.id = id;
		}
		
		public static function createFromItemPrototype(ip:ItemPrototype):Item{
			var item:Item = new Item(ip.id);
			item.prototypeid = ip.id;
			item.price = ip.price;
			item.pricereal = ip.priceReal;
			item.title = ip.title;
			item.description = ip.description;
			item.count = ip.count;	
			return item;
		} 
		
		public function clone():Item{
			var item:Item = new Item(id);
			item.prototypeid = prototypeid;
			item.price = price;
			item.pricereal = pricereal;
			item.title = title;
			item.description = description;
			item.count = count;		
			return item;
		}
	}
}