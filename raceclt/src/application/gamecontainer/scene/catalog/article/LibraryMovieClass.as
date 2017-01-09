package application.gamecontainer.scene.catalog.article
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	import utils.models.car.CarId;
	import utils.models.item.ItemType;
	import utils.models.map.DistrictModel;

	public class LibraryMovieClass
	{	
		public function LibraryMovieClass(){
		}
		
		public static function getClassByItemPrototypeID(id:int):Class{
			//vips
			if (id == ItemType.VIP_BRONZE){
				return VipBronze;
			}else if (id == ItemType.VIP_SILVER){
				return VipSilver;
			}else if (id == ItemType.VIP_GOLD){
				return VipGold;
			}
			//presents
			else if (id == ItemType.SWEET){
				return Sweet;
			}else if (id == ItemType.HEART){
				return Heart;
			}else if (id == ItemType.COCKTAIL){
				return Coctail;
			}else if (id == ItemType.FLOWERS){
				return Flowers;
			}else if (id == ItemType.BEAR){
				return Bear;
			}else if (id == ItemType.KISS){
				return Kiss;
			}else if (id == ItemType.MONEYBAG){
				return MoneyPresent;
			}else if (id == ItemType.CASTLE){
				return Castle2;
			}else if (id == ItemType.FIG){
				return Fig;
			}else if (id == ItemType.STRAWBERRYBIG){
				return Strawberry;
			}else if (id == ItemType.APPLE){
				return Apple;
			}else if (id == ItemType.CONCH){
				return Conch;
			}else if (id == ItemType.RING_STONE){
				return RingStone;
			}else if (id == ItemType.CRONE_PRESENT){
				return CronePresent;
			}else if (id == ItemType.BLACK_FLAG){
				return BlackFlag;
			}else if (id == ItemType.YACHT){
				return Yacht;
			}else if (id == ItemType.ILAND){
				return Iland;
			}else if (id == ItemType.PEPPER){
				return Pepper;
			}else if (id == ItemType.HERRINGBONE){
				return Herringbone;
			}else if (id == ItemType.WHEEL){
				return Wheel;
			}else if (id == ItemType.JERRYCAN){
				return Jerrycan;
			}else if (id == ItemType.BRELOK_MERCEDES){
				return BrelokMersPresent;
			}else if (id == ItemType.BRELOK_BMW){
				return BrelokBMWPresent;
			}else if (id == ItemType.BRELOK_AUDI){
				return BrelokAudiPresent;
			}else if (id == ItemType.TOOLS){
				return ToolPresent;
			}
			return MovieClip;	
		}
		
		public static function getPresentChatSize(id:int):Number{
			if (id == ItemType.SWEET){
				return 25;
			}else if (id == ItemType.LEMON){
				return 25;
			}else if (id == ItemType.FIG){
				return 25;
			}else if (id == ItemType.BLACK_FLAG){
				return 25;
			}else if (id == ItemType.KISS){
				return 25;
			}else if (id == ItemType.BOOK){
				return 25;
			}else if (id == ItemType.CHEESE){
				return 25;
			}else if (id == ItemType.RINGS){
				return 20;
			}
			
			else if (id == ItemType.CASTLE){
				return 50;
			}else if (id == ItemType.YACHT){
				return 50;
			}else if (id == ItemType.ILAND){
				return 50;
			}else if (id == ItemType.CONCH){
				return 40;
			}else if (id == ItemType.CHEBURASHKA){
				return 40;
			}else if (id == ItemType.PEPPER){
				return 40;
			}else if (id == ItemType.RING_STONE){
				return 40;
			}else if (id == ItemType.FLOWERS){
				return 40;
			}else if (id == ItemType.FIRTREE){
				return 40;
			}else if (id == ItemType.APPLE){
				return 40;
			}else if (id == ItemType.SNOWMAN){
				return 40;
			}else if (id == ItemType.BEAR){
				return 40;
			}else if (id == ItemType.PARROT){
				return 40;
			}else if (id == ItemType.CRONE_PRESENT){
				return 40;
			}else if (id == ItemType.RING){
				return 40;
			}else if (id == ItemType.INLOVE){
				return 40;
			}else if (id == ItemType.SNAKE){
				return 50;
			}else if (id == ItemType.DRAGON){
				return 40;
			}else if (id == ItemType.MONEYBAG){
				return 50;
			}else if (id == ItemType.HERRINGBONE){
				return 40;
			}else if (id == ItemType.WHEEL){
				return 40;
			}else if (id == ItemType.JERRYCAN){
				return 40;
			}else if (id == ItemType.BRELOK_MERCEDES){
				return 50;
			}else if (id == ItemType.BRELOK_BMW){
				return 50;
			}else if (id == ItemType.BRELOK_AUDI){
				return 50;
			}else if (id == ItemType.TOOLS){
				return 40;
			}
			return 30;
		}
		
		public static function getCarClassByCarPrototypeID(id:int):Class{
			if (id == CarId.VAZ_2110){
				return VAZ2110Mc;
			}else if (id == CarId.RENAULT_LOGAN){
				return RenaultLoganMc;
			}else if (id == CarId.FORD_FOCUS){
				return FordFocusMc;
			}else if (id == CarId.TOYOTA_COROLLA){
				return ToyotaCorollaMc;
			}else if (id == CarId.MAZDA_3){
				return Mazda3Mc;
			}else if (id == CarId.VOLKSWAGEN_PASSAT){
				return VWPassatMc;
			}else if (id == CarId.BMW_325i){
				return BMW3Mc;
			}else if (id == CarId.MERCEDES_SLC){
				return MercedesCLSMc;
			}else if (id == CarId.OPEL_ASTRA){
				return OpelAstraMc;
			}else if (id == CarId.VOLKSWAGEN_GOLF){
				return VWGolfMc;
			}else if (id == CarId.AUDI_A7){
				return AudiA7Mc;
			}
			return MovieClip;
		}
		
		public static function getCarTDClassByCarPrototypeID(id:int):Class{
			if (id == CarId.VAZ_2110){
				return VAZ2110TDMc;
			}else if (id == CarId.RENAULT_LOGAN){
				return RenaultLoganTDMc;
			}else if (id == CarId.FORD_FOCUS){
				return FordFocusTDMc;
			}else if (id == CarId.TOYOTA_COROLLA){
				return ToyotaCorollaTDMc;
			}else if (id == CarId.MAZDA_3){
				return Mazda3TDMc;
			}else if (id == CarId.VOLKSWAGEN_PASSAT){
				return VWPassatTDMc;
			}else if (id == CarId.BMW_325i){
				return BMW3TDMc;
			}else if (id == CarId.MERCEDES_SLC){
				return MercedesCLSTDMc;
			}else if (id == CarId.OPEL_ASTRA){
				return OpelAstraTDMc;
			}else if (id == CarId.VOLKSWAGEN_GOLF){
				return VWGolfTDMc;
			}else if (id == CarId.AUDI_A7){
				return AudiA7TDMc;
			}
			return MovieClip;
		}
		
		public static function getBgClassByDistrictID(id:int):Class{
			if (id == DistrictModel.DISTRICT1){
				return Bg1Mc;
			}else if (id == DistrictModel.DISTRICT2){
				return Bg3Mc;
			}else if (id == DistrictModel.DISTRICT3){
				return Bg4Mc;
			}else if (id == DistrictModel.DISTRICT4){
				return Bg2Mc;
			}else if (id == DistrictModel.DISTRICT5){
				return Bg5Mc;
			}
			return MovieClip;
		}
	}
}