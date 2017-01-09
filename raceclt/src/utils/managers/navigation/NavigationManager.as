package utils.managers.navigation
{
	import application.GameApplication;
	import application.gamecontainer.scene.admin.AdminPanel;
	import application.gamecontainer.scene.bag.Bag;
	import application.gamecontainer.scene.betpage.BetPage;
	import application.gamecontainer.scene.catalog.Catalog;
	import application.gamecontainer.scene.clans.ClanRoom;
	import application.gamecontainer.scene.clans.ClansRoom;
	import application.gamecontainer.scene.constructor.Constructor;
	import application.gamecontainer.scene.findUsers.FindUsersPage;
	import application.gamecontainer.scene.game.GameWorld;
	import application.gamecontainer.scene.home.HomePage;
	import application.gamecontainer.scene.map.MapPage;
	import application.gamecontainer.scene.myroom.MyRoom;
	import application.gamecontainer.scene.top.Top;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;
	
	import spark.components.Group;
	
	import utils.interfaces.ISceneContent;
	
	public class NavigationManager extends EventDispatcher
	{
		public var currentSceneContent:ISceneContent;
		
		public function NavigationManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function clear():void{
			if(currentSceneContent){
				currentSceneContent.onHide();
				GameApplication.app.gameContainer.scene.removeElement(currentSceneContent as Group);
			} 
		}
		
		public function goHome():void{			
			clear();
			
			var hp:HomePage = new HomePage();			
			GameApplication.app.gameContainer.scene.addElement(hp);
			currentSceneContent = hp;
		}
		
		public function goMapPage():void{			
			clear();
			
			var map:MapPage = new MapPage();			
			GameApplication.app.gameContainer.scene.addElement(map);
			currentSceneContent = map;
		}
		
		public function goMyRoom():void{			
			clear();
			
			var myr:MyRoom = new MyRoom();
			GameApplication.app.gameContainer.scene.addElement(myr);
			currentSceneContent = myr;
		}
		
		public function goBetPage():void{
			clear();
			
			var hp:BetPage = new BetPage();			
			GameApplication.app.gameContainer.scene.addElement(hp);
			currentSceneContent = hp;
		}
		
		public function goGameWorld(roomID:int, districtID:int, users:Array, cars:Array, colors:Array, gt:int):GameWorld{			
			clear();
			var gw:GameWorld = new GameWorld(roomID, districtID, users, cars, colors, gt);
			GameApplication.app.gameContainer.scene.addElement(gw);
			currentSceneContent = gw;
			return gw;
		}
		
		public function goFindUsersScreen(wt:int):void{
			clear();
			
			var fup:FindUsersPage = new FindUsersPage();
			fup.time = wt;
			GameApplication.app.gameContainer.scene.addElement(fup);
			currentSceneContent = fup;
		}
		
		public function goShop():void{
			clear();			
			
			var catalog:Catalog = new Catalog();
			GameApplication.app.gameContainer.scene.addElement(catalog);
			currentSceneContent = catalog;		
		}
		
		public function goBag(selectCategory:int = 5):void{
			clear();			
			
			var bag:Bag = new Bag();
			bag.selectedCategory = selectCategory;
			GameApplication.app.gameContainer.scene.addElement(bag);
			currentSceneContent = bag;		
		}
		
		public function goTop():void{
			clear();			
			
			var top:Top = new Top();
			GameApplication.app.gameContainer.scene.addElement(top);
			currentSceneContent = top;		
		}
		
		public function goAdminPanel():void{
			clear();			
			
			var admin:AdminPanel = new AdminPanel();
			GameApplication.app.gameContainer.scene.addElement(admin);
			currentSceneContent = admin;		
		}
		
		public function goClansRoom():void{
			clear();			
			
			var clans:ClansRoom = new ClansRoom();
			GameApplication.app.gameContainer.scene.addElement(clans);
			currentSceneContent = clans;		
		}
		public function goClanRoom(idclan:int):void{
			clear();			
			
			var clan:ClanRoom = new ClanRoom();
			clan.idclan = idclan;
			GameApplication.app.gameContainer.scene.addElement(clan);
			currentSceneContent = clan;		
		}
		
		public function goConstructor(xml:XML = null):Constructor{
			clear();
			
			var r:Rectangle = new Rectangle(0, 0, GameApplication.app.gameContainer.scene.width, GameApplication.app.gameContainer.scene.height);
			var contructor:Constructor = new Constructor();			
			GameApplication.app.gameContainer.scene.addElement(contructor);
			currentSceneContent = contructor;
			GameApplication.app.constructor.constructor = contructor;			
			
			if(xml){
				GameApplication.app.constructor.initXML(xml);
			}else{
				GameApplication.app.constructor.init();
			}
			
			return contructor;
		}
	}
}