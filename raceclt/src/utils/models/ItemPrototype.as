package utils.models
{
	public class ItemPrototype
	{
		public var id:int;
		public var title:String;
		public var description:String;
		public var count:int;
		public var price:int;
		public var priceReal:int;
		public var showed:int;
		
		public function ItemPrototype(pid:int){
			this.id = pid;
		}
	}
}