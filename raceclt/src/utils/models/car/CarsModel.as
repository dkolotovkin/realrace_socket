package utils.models.car
{
	import mx.collections.ArrayCollection;

	public class CarsModel
	{
		[Bindable]
		public var carPrototypesCollection:ArrayCollection;
		
		public function CarsModel()
		{
			carPrototypesCollection = new ArrayCollection();
			
			var carPrototype:CarPrototypeModel;
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.VAZ_2110;
			carPrototype.carClass = 1;
			carPrototype.title = "Ваз 2110";
			carPrototype.size = "1.6";
			carPrototype.power = 75;
			carPrototype.length = 4263;
			carPrototype.width = 1676;
			carPrototype.height = 1430;
			carPrototype.mass = 1050;
			carPrototype.trannyGearRatios = Vector.<Number>([3.5, 3.6, 1.95, 1.357, 0.941, 0.784]);
			carPrototype.powersObj = {1000:40, 2000:60, 3000:100, 4000:125, 5000:140};
			carPrototype.discR = 14;
			carPrototype.tireFrictionK = 1;
			carPrototype.minLevel = 1;
			carPrototype.price = 0;
			carPrototype.rentPriceReal = 0;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.RENAULT_LOGAN;
			carPrototype.carClass = 1;
			carPrototype.title = "Renault Logan";
			carPrototype.size = "1.4";
			carPrototype.power = 75;
			carPrototype.length = 4250;
			carPrototype.width = 1742;
			carPrototype.height = 1525;
			carPrototype.mass = 1000;
			carPrototype.trannyGearRatios = Vector.<Number>([3.545, 3.7, 2.0, 1.39, 1.0, 0.79]);
			carPrototype.powersObj = {1000:50, 2000:70, 3000:100, 4000:140, 5000:160};
			carPrototype.discR = 14;
			carPrototype.tireFrictionK = 1;
			carPrototype.minLevel = 2;
			carPrototype.price = 2000;
			carPrototype.rentPriceReal = 20;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.FORD_FOCUS;
			carPrototype.carClass = 2;
			carPrototype.title = "Ford Focus";
			carPrototype.size = "1.6";
			carPrototype.power = 100;
			carPrototype.length = 4488;
			carPrototype.width = 1840;
			carPrototype.height = 1497;
			carPrototype.mass = 1170;
			carPrototype.trannyGearRatios = Vector.<Number>([3.62, 3.58, 1.93, 1.28, 0.95, 0.76]);
			carPrototype.powersObj = {1000:50, 2000:70, 3000:110, 4000:155, 5000:190};
			carPrototype.discR = 15;
			carPrototype.tireFrictionK = 1;
			carPrototype.minLevel = 3;
			carPrototype.price = 8000;
			carPrototype.rentPriceReal = 50;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.TOYOTA_COROLLA;
			carPrototype.carClass = 2;
			carPrototype.title = "Toyota Corolla";
			carPrototype.size = "1.6";
			carPrototype.power = 110;
			carPrototype.length = 4540;
			carPrototype.width = 1760;
			carPrototype.height = 1470;
			carPrototype.mass = 1250;
			carPrototype.trannyGearRatios = Vector.<Number>([3.25, 3.545, 1.904, 1.31, 0.969, 0.815]);
			carPrototype.powersObj = {1000:55, 2000:80, 3000:120, 4000:155, 5000:195, 6000:200};
			carPrototype.discR = 15;
			carPrototype.tireFrictionK = 1.2;
			carPrototype.minLevel = 4;
			carPrototype.price = 15000;
			carPrototype.rentPriceReal = 100;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.OPEL_ASTRA;
			carPrototype.carClass = 2;
			carPrototype.title = "Opel Astra";
			carPrototype.size = "1.8";
			carPrototype.power = 125;
			carPrototype.length = 4419;
			carPrototype.width = 1814;
			carPrototype.height = 1510;
			carPrototype.mass = 1350;
			carPrototype.trannyGearRatios = Vector.<Number>([3.3, 3.73, 2.136, 1.414, 1.21, 0.89]);
			carPrototype.powersObj = {1000:50, 2000:80, 3000:125, 4000:170, 5000:200, 6000:220};
			carPrototype.discR = 15;
			carPrototype.tireFrictionK = 1.3;
			carPrototype.minLevel = 5;
			carPrototype.price = 20000;
			carPrototype.rentPriceReal = 150;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.MAZDA_3;
			carPrototype.carClass = 3;
			carPrototype.title = "Mazda 3";
			carPrototype.size = "1.8";
			carPrototype.power = 140;
			carPrototype.length = 4249;
			carPrototype.width = 1753;
			carPrototype.height = 1460;
			carPrototype.mass = 1280;
			carPrototype.trannyGearRatios = Vector.<Number>([3.308, 3.727, 2.136, 1.414, 1.121, 0.890]);
			carPrototype.powersObj = {1000:50, 2000:90, 3000:130, 4000:175, 5000:210, 6000:230};
			carPrototype.discR = 16;
			carPrototype.tireFrictionK = 1.3;
			carPrototype.minLevel = 7;
			carPrototype.price = 30000;
			carPrototype.rentPriceReal = 200;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.VOLKSWAGEN_GOLF;
			carPrototype.carClass = 3;
			carPrototype.title = "Volkswagen Golf";
			carPrototype.size = "2.0";
			carPrototype.power = 150;
			carPrototype.length = 4255;
			carPrototype.width = 1799;
			carPrototype.height = 1452;
			carPrototype.mass = 1350;
			carPrototype.trannyGearRatios = Vector.<Number>([4.5, 3.77, 2.09, 1.320, 0.910, 0.90, 0.76]);
			carPrototype.powersObj = {1000:60, 2000:100, 3000:140, 4000:190, 5000:230, 6000:250};
			carPrototype.discR = 16;
			carPrototype.tireFrictionK = 1.5;
			carPrototype.minLevel = 8;
			carPrototype.price = 40000;
			carPrototype.rentPriceReal = 250;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.VOLKSWAGEN_PASSAT;
			carPrototype.carClass = 3;
			carPrototype.title = "Volkswagen Passat";
			carPrototype.size = "2.0";
			carPrototype.power = 155;
			carPrototype.length = 4765;
			carPrototype.width = 1820;
			carPrototype.height = 1472;
			carPrototype.mass = 1390;
			carPrototype.trannyGearRatios = Vector.<Number>([3.6, 3.78, 2.27, 1.65, 1.27, 1.03, 0.87]);
			carPrototype.powersObj = {1000:80, 2000:110, 3000:160, 4000:220, 5000:275, 6000:290, 7000:300};
			carPrototype.discR = 16;
			carPrototype.tireFrictionK = 1.5;
			carPrototype.minLevel = 10;
			carPrototype.price = 50000;
			carPrototype.rentPriceReal = 300;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.BMW_325i;
			carPrototype.carClass = 4;
			carPrototype.title = "BMW 325i";
			carPrototype.size = "2.5";
			carPrototype.power = 210;
			carPrototype.length = 4531;
			carPrototype.width = 2013;
			carPrototype.height = 1421;
			carPrototype.mass = 1410;
			carPrototype.trannyGearRatios = Vector.<Number>([3.403, 3.76, 2.33, 1.61, 1.23, 1.0]);
			carPrototype.powersObj = {1000:90, 2000:140, 3000:200, 4000:260, 5000:330, 6000:370, 7000:380};
			carPrototype.discR = 16;
			carPrototype.tireFrictionK = 1.6;
			carPrototype.minLevel = 12;
			carPrototype.price = 200000;
			carPrototype.rentPriceReal = 900;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.AUDI_A7;
			carPrototype.carClass = 4;
			carPrototype.title = "Audi A7";
			carPrototype.size = "3.0";
			carPrototype.power = 240;
			carPrototype.length = 4969;
			carPrototype.width = 1911;
			carPrototype.height = 1421;
			carPrototype.mass = 1800;
			carPrototype.trannyGearRatios = Vector.<Number>([2.95, 3.69, 2.15, 1.40, 1.05, 0.787]);
			carPrototype.powersObj = {1000:120, 2000:180, 3000:240, 4000:300, 5000:360, 6000:400, 7000:420};
			carPrototype.discR = 17;
			carPrototype.tireFrictionK = 1.8;
			carPrototype.minLevel = 13;
			carPrototype.priceReal = 15000;
			carPrototype.rentPriceReal = 1000;
			carPrototypesCollection.addItem(carPrototype);
			
			carPrototype = new CarPrototypeModel();
			carPrototype.id = CarId.MERCEDES_SLC;
			carPrototype.carClass = 4;
			carPrototype.title = "Mercedes SLC";
			carPrototype.size = "3.0";
			carPrototype.power = 240;
			carPrototype.length = 4562;
			carPrototype.width = 1820;
			carPrototype.height = 1317;
			carPrototype.mass = 1785;
			carPrototype.trannyGearRatios = Vector.<Number>([3.42, 3.6, 2.19, 1.41, 1, 0.83]);
			carPrototype.powersObj = {1000:120, 2000:180, 3000:240, 4000:300, 5000:380, 6000:420, 7000:450};
			carPrototype.discR = 17;
			carPrototype.tireFrictionK = 1.8;
			carPrototype.minLevel = 15;
			carPrototype.priceReal = 18000;
			carPrototype.rentPriceReal = 1200;
			carPrototypesCollection.addItem(carPrototype);
		}
		
		public function getCarPrototypeById(pid:int):CarPrototypeModel{
			for each(var prototype:CarPrototypeModel in carPrototypesCollection){
				if(prototype.id == pid){
					return prototype;
				}
			}
			return null;
		}
	}
}