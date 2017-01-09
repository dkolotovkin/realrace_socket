package utils.models.map
{
	import flash.utils.ByteArray;

	public class MapModel
	{
		[Embed(source="embeds/test.xml", mimeType="application/octet-stream")]
		private var MapTest:Class;
		
		[Embed(source="embeds/map1.xml", mimeType="application/octet-stream")]
		private var Map1:Class;
		
		[Embed(source="embeds/map2.xml", mimeType="application/octet-stream")]
		private var Map2:Class;
		
		[Embed(source="embeds/map3.xml", mimeType="application/octet-stream")]
		private var Map3:Class;
		
		[Embed(source="embeds/map4.xml", mimeType="application/octet-stream")]
		private var Map4:Class;
		
		[Embed(source="embeds/map5.xml", mimeType="application/octet-stream")]
		private var Map5:Class;
		
		[Embed(source="embeds/map6.xml", mimeType="application/octet-stream")]
		private var Map6:Class;
		
		[Embed(source="embeds/map7.xml", mimeType="application/octet-stream")]
		private var Map7:Class;
		
		[Embed(source="embeds/map8.xml", mimeType="application/octet-stream")]
		private var Map8:Class;
		
		[Embed(source="embeds/map9.xml", mimeType="application/octet-stream")]
		private var Map9:Class;
		
		[Embed(source="embeds/map10.xml", mimeType="application/octet-stream")]
		private var Map10:Class;
		
		[Embed(source="embeds/map11.xml", mimeType="application/octet-stream")]
		private var Map11:Class;
		
		[Embed(source="embeds/map12.xml", mimeType="application/octet-stream")]
		private var Map12:Class;
		
		[Embed(source="embeds/map13.xml", mimeType="application/octet-stream")]
		private var Map13:Class;
		
		[Embed(source="embeds/map14.xml", mimeType="application/octet-stream")]
		private var Map14:Class;
		
		[Embed(source="embeds/map15.xml", mimeType="application/octet-stream")]
		private var Map15:Class;
		
		[Embed(source="embeds/map16.xml", mimeType="application/octet-stream")]
		private var Map16:Class;
		
		[Embed(source="embeds/map17.xml", mimeType="application/octet-stream")]
		private var Map17:Class;
		
		[Embed(source="embeds/map18.xml", mimeType="application/octet-stream")]
		private var Map18:Class;
		
		[Embed(source="embeds/map19.xml", mimeType="application/octet-stream")]
		private var Map19:Class;
		
		[Embed(source="embeds/map20.xml", mimeType="application/octet-stream")]
		private var Map20:Class;
		
		[Embed(source="embeds/map21.xml", mimeType="application/octet-stream")]
		private var Map21:Class;
		
		[Embed(source="embeds/map22.xml", mimeType="application/octet-stream")]
		private var Map22:Class;
		
		[Embed(source="embeds/map23.xml", mimeType="application/octet-stream")]
		private var Map23:Class;
		
		[Embed(source="embeds/map24.xml", mimeType="application/octet-stream")]
		private var Map24:Class;
		
		[Embed(source="embeds/map25.xml", mimeType="application/octet-stream")]
		private var Map25:Class;
		
		[Embed(source="embeds/map26.xml", mimeType="application/octet-stream")]
		private var Map26:Class;
		
		[Embed(source="embeds/map27.xml", mimeType="application/octet-stream")]
		private var Map27:Class;
		
		[Embed(source="embeds/map28.xml", mimeType="application/octet-stream")]
		private var Map28:Class;
		
		[Embed(source="embeds/map29.xml", mimeType="application/octet-stream")]
		private var Map29:Class;
		
		[Embed(source="embeds/map30.xml", mimeType="application/octet-stream")]
		private var Map30:Class;
		
		[Embed(source="embeds/map31.xml", mimeType="application/octet-stream")]
		private var Map31:Class;
		
		[Embed(source="embeds/map32.xml", mimeType="application/octet-stream")]
		private var Map32:Class;
		
		[Embed(source="embeds/map33.xml", mimeType="application/octet-stream")]
		private var Map33:Class;
		
		[Embed(source="embeds/map34.xml", mimeType="application/octet-stream")]
		private var Map34:Class;
		
		[Embed(source="embeds/map35.xml", mimeType="application/octet-stream")]
		private var Map35:Class;
		
		[Embed(source="embeds/map36.xml", mimeType="application/octet-stream")]
		private var Map36:Class;
		
		[Embed(source="embeds/map37.xml", mimeType="application/octet-stream")]
		private var Map37:Class;
		
		[Embed(source="embeds/map38.xml", mimeType="application/octet-stream")]
		private var Map38:Class;
		
		[Embed(source="embeds/map39.xml", mimeType="application/octet-stream")]
		private var Map39:Class;
		
		[Embed(source="embeds/map40.xml", mimeType="application/octet-stream")]
		private var Map40:Class;
		
		public var mapsClasses:Object;
		public var mapsXML:Object;
		public var constructorMap:XML;
		
		public var districts:Object;
		
		public function MapModel()
		{
			mapsXML = new Object();
			mapsClasses = new Object();
			mapsClasses[0] = MapTest;
			mapsClasses[1] = Map1;
			mapsClasses[2] = Map2;
			mapsClasses[3] = Map3;
			mapsClasses[4] = Map4;
			mapsClasses[5] = Map5;
			mapsClasses[6] = Map6;
			mapsClasses[7] = Map7;
			mapsClasses[8] = Map8;
			mapsClasses[9] = Map9;
			mapsClasses[10] = Map10;
			mapsClasses[11] = Map11;
			mapsClasses[12] = Map12;
			mapsClasses[13] = Map13;
			mapsClasses[14] = Map14;
			mapsClasses[15] = Map15;
			mapsClasses[16] = Map16;
			mapsClasses[17] = Map17;
			mapsClasses[18] = Map18;
			mapsClasses[19] = Map19;
			mapsClasses[20] = Map20;
			mapsClasses[21] = Map21;
			mapsClasses[22] = Map22;
			mapsClasses[23] = Map23;
			mapsClasses[24] = Map24;
			mapsClasses[25] = Map25;
			mapsClasses[26] = Map26;
			mapsClasses[27] = Map27;
			mapsClasses[28] = Map28;
			mapsClasses[29] = Map29;
			mapsClasses[30] = Map30;
			mapsClasses[31] = Map31;
			mapsClasses[32] = Map32;
			mapsClasses[33] = Map33;
			mapsClasses[34] = Map34;
			mapsClasses[35] = Map35;
			mapsClasses[36] = Map36;
			mapsClasses[37] = Map37;
			mapsClasses[38] = Map38;
			mapsClasses[39] = Map39;
			mapsClasses[40] = Map40;
			
			districts = new Object();
			
			var district:DistrictModel;
			
			district = new DistrictModel();
			district.id = DistrictModel.DISTRICT1;
			district.title = "Северо-западный район";
			district.carClassDescription = "Соревнования автомобилей 1 и 2 класса";
			district.experienceK = 0.8;
			districts[district.id] = district;
			
			district = new DistrictModel();
			district.id = DistrictModel.DISTRICT2;
			district.title = "Северо-восточный район";
			district.carClassDescription = "Соревнования автомобилей 3 и 4 класса";
			district.experienceK = 1.6;
			districts[district.id] = district;
			
			district = new DistrictModel();
			district.id = DistrictModel.DISTRICT3;
			district.title = "Юго-восточный район";
			district.carClassDescription = "Класс авто: 1 и 2";
			district.experienceK = 1.6;
			districts[district.id] = district;
			
			district = new DistrictModel();
			district.id = DistrictModel.DISTRICT4;
			district.title = "Юго-западный район";
			district.carClassDescription = "Соревнования автомобилей любого класса";
			district.experienceK = 1.0;
			districts[district.id] = district;
			
			district = new DistrictModel();
			district.id = DistrictModel.DISTRICT5;
			district.title = "Центральный район";
			district.carClassDescription = "Соревнования автомобилей любого класса";
			district.experienceK = 0;
			districts[district.id] = district;
		}
		
		public function getMapXMLByID(mid:int):XML{
			if(!mapsXML[mid]){
				var XMLClass:Class = mapsClasses[mid];
				var byteArray:ByteArray = new XMLClass();
				
				mapsXML[mid] = new XML(byteArray.readUTFBytes(byteArray.length));
			}
			return mapsXML[mid];
		}
	}
}