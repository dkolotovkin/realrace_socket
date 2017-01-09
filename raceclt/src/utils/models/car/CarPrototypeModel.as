package utils.models.car
{
	public class CarPrototypeModel
	{
		public var id:uint;
		public var carClass:int;
		public var title:String;
		public var size:String;		//объем
		public var power:int;
		public var length:Number;
		public var width:Number;
		public var height:Number;
		public var mass:Number;
		public var trannyGearRatios:Vector.<Number>;
		public var powersObj:Object;
		public var discR:int;
		public var tireFrictionK:Number;
		public var minLevel:int;
		
		public var price:int;
		public var priceReal:int;
		public var rentPriceReal:int;
		
		public function CarPrototypeModel()
		{
		}
	}
}