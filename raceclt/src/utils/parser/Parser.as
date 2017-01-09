package utils.parser
{
	import application.GameApplication;
	
	import mx.collections.ArrayCollection;
	
	import utils.models.ClanModel;
	import utils.models.ItemPrototype;
	import utils.models.MailMessageModel;
	import utils.models.ShopCategory;
	import utils.models.car.CarModel;
	import utils.models.car.CarPrototypeModel;
	import utils.models.item.Item;
	import utils.models.item.ItemPresent;
	import utils.protocol.ProtocolKeys;
	import utils.shop.CategoryType;
	import utils.user.ClanUserRole;
	import utils.user.User;
	import utils.user.UserClanInfo;
	import utils.user.UserFriend;

	public class Parser
	{
		public function Parser()
		{
		}
		
		public static function parseShopCategories(categories:Array):void{
			var list:ArrayCollection = new ArrayCollection();
			var category:ShopCategory;
			for(var i:uint = 0; i < categories.length; i++){
				category = new ShopCategory(categories[i][ProtocolKeys.ID], categories[i][ProtocolKeys.TITLE]);				
				list.addItem(category);				
			}
			category = new ShopCategory(CategoryType.DARK_SHOP, "Черный рынок");				
			list.addItem(category);
			GameApplication.app.models.shopCategories = list;
		}
		
		public static function parseItemPrototypes(itemPrototypes:Array):void{			
			var itemprototype:ItemPrototype;
			for(var i:uint = 0; i < itemPrototypes.length; i++){
				itemprototype = GameApplication.app.models.itemPrototypes.getModelById(itemPrototypes[i][ProtocolKeys.ID]);
				itemprototype.title = itemPrototypes[i][ProtocolKeys.TITLE];
				itemprototype.description = itemPrototypes[i][ProtocolKeys.DESCRIPTION];
				itemprototype.count = itemPrototypes[i][ProtocolKeys.COUNT];
				itemprototype.price = itemPrototypes[i][ProtocolKeys.PRICE];
				itemprototype.priceReal = itemPrototypes[i][ProtocolKeys.PRICE_REAL];
				itemprototype.showed = itemPrototypes[i][ProtocolKeys.SHOWED];
			}
		}
		public static function parseItemPrototype(itemPrototypeObj:Object):ItemPrototype{			
			var itemprototype:ItemPrototype = new ItemPrototype(itemPrototypeObj[ProtocolKeys.ID]);
			itemprototype.title = itemPrototypeObj[ProtocolKeys.TITLE];
			itemprototype.description = itemPrototypeObj[ProtocolKeys.DESCRIPTION];
			itemprototype.count = itemPrototypeObj[ProtocolKeys.COUNT];
			itemprototype.price = itemPrototypeObj[ProtocolKeys.PRICE];
			itemprototype.priceReal = itemPrototypeObj[ProtocolKeys.PRICE_REAL];
			itemprototype.showed = itemPrototypeObj[ProtocolKeys.SHOWED];
			return itemprototype;
		}
		
		public static function parseCar(carObj:Object):CarModel{			
			var car:CarModel = new CarModel();
			car.id = carObj[ProtocolKeys.ID];
			car.prototype = GameApplication.app.models.cars.getCarPrototypeById(carObj[ProtocolKeys.CAR_PROTOTYPE]);
			car.color = carObj[ProtocolKeys.COLOR];
			car.durability = carObj[ProtocolKeys.DURABILITY];
			car.rented = carObj[ProtocolKeys.RENTED];
			if(car.rented){
				car.rentTime = carObj[ProtocolKeys.RENT_TIME];
			}
			return car;
		}
		
		public static function parseCarPrototype(carPrototypeObj:Object):CarPrototypeModel{			
			var carPrototype:CarPrototypeModel = new CarPrototypeModel();
			carPrototype.id = carPrototypeObj[ProtocolKeys.ID];
			carPrototype.title = carPrototypeObj[ProtocolKeys.TITLE];
			carPrototype.carClass = carPrototypeObj[ProtocolKeys.CLASS];
			carPrototype.minLevel = carPrototypeObj[ProtocolKeys.LEVEL];
			carPrototype.price = carPrototypeObj[ProtocolKeys.PRICE];
			carPrototype.priceReal = carPrototypeObj[ProtocolKeys.PRICE_REAL];
			return carPrototype;
		}
		
		public static function parseUserItemsPresent(items:Array):void{
			if(items == null || (items && items.length == 0)){				
				GameApplication.app.models.userPresents.end = true;
				GameApplication.app.models.userPresents.getting = false;
				if(GameApplication.app.models.userPresents.collection.length == 0){
					GameApplication.app.models.userPresents.collection.refresh();
				}
				return;
			}
			
			var temp:ArrayCollection = new ArrayCollection();	
			var item:ItemPresent;
			for(var i:uint = 0; i < items.length; i++){				
				item = new ItemPresent(items[i][ProtocolKeys.ID]);
				item.prototypeid = items[i][ProtocolKeys.PROTOTYPE_ID];
				item.price = items[i][ProtocolKeys.PRICE];
				item.pricereal = items[i][ProtocolKeys.PRICE_REAL];
				item.title = items[i][ProtocolKeys.TITLE];
				item.description = items[i][ProtocolKeys.DESCRIPTION];
				item.count = items[i][ProtocolKeys.COUNT];
				item.presenter = items[i][ProtocolKeys.PRESENTER];
				temp.addItem(item);
			}
			
			GameApplication.app.models.userPresents.collection.addAll(temp);
			GameApplication.app.models.userPresents.getting = false;
		}
		
		public static function parseUserItems(items:Array):void{			
			var item:Item;
			for(var i:uint = 0; i < items.length; i++){				
				item = GameApplication.app.models.userItems.getModelById(items[i][ProtocolKeys.ID]);
				item.prototypeid = items[i][ProtocolKeys.PROTOTYPE_ID];
				item.price = items[i][ProtocolKeys.PRICE];
				item.pricereal = items[i][ProtocolKeys.PRICE_REAL];
				item.title = items[i][ProtocolKeys.TITLE];
				item.description = items[i][ProtocolKeys.DESCRIPTION];
				item.count = items[i][ProtocolKeys.COUNT];
			}
		}
		
		public static function parseCurrentClanUsers(obj:Object):void{
			var newUsers:ArrayCollection = new ArrayCollection();			
			var user:UserClanInfo;
			var usersArr:Array = obj[ProtocolKeys.USERS];
			if(usersArr == null || (usersArr && usersArr.length == 0)){				
				GameApplication.app.models.currentClan.end = true;
				GameApplication.app.models.currentClan.getting = false;
				if(GameApplication.app.models.currentClan.users.length == 0){
					GameApplication.app.models.currentClan.users.refresh();
				}
				return;
			}
			for(var i:uint = 0; i < usersArr.length; i++){
				GameApplication.app.models.currentClan.countUsers++;
				user = UserClanInfo.createFromObject(usersArr[i]);
				if(user.clanrole != ClanUserRole.INVITED && user.clanrole != ClanUserRole.OWNER){
					newUsers.addItem(user);
				}
			}
			
			GameApplication.app.models.currentClan.users.addAll(newUsers);
			GameApplication.app.models.currentClan.users.refresh();
			GameApplication.app.models.currentClan.getting = false;
		}
		
		public static function parseFriends(friends:Array):void{
			if(friends == null || (friends && friends.length == 0)){				
				GameApplication.app.models.endFriends = true;
				GameApplication.app.models.gettingFriends = false;
				if(GameApplication.app.models.friends.length == 0){
					GameApplication.app.models.friends.refresh();
				}
				return;
			}
			
			var temp:ArrayCollection = new ArrayCollection();
			var user:UserFriend;
			for(var i:int = 0; i < friends.length; i++){
				user = UserFriend.createUserFriendFromObject(friends[i]);
				temp.addItem(user);
			}
			GameApplication.app.models.friends.addAll(temp);
			GameApplication.app.models.gettingFriends = false;
		}
		
		public static function parseCheaters(cheaters:Array):void{
			var temp:ArrayCollection = new ArrayCollection();
			var user:User;
			for(var i:int = 0; i < cheaters.length; i++){
				user = User.createFromObject(cheaters[i]);
				temp.addItem(user);
			}
			GameApplication.app.models.cheaters.removeAll();
			GameApplication.app.models.cheaters.addAll(temp);
		}
		
		public static function parseEnemies(enemies:Array):void{
			if(enemies == null || (enemies && enemies.length == 0)){				
				GameApplication.app.models.endEnemies = true;
				GameApplication.app.models.gettingEnemies = false;
				if(GameApplication.app.models.enemies.length == 0){
					GameApplication.app.models.enemies.refresh();
				}
				return;
			}
			
			var temp:ArrayCollection = new ArrayCollection();
			var user:User;
			
			for(var i:int = 0; i < enemies.length; i++){
				user = User.createFromObject(enemies[i])
				temp.addItem(user);
			}
			GameApplication.app.models.enemies.addAll(temp);		
			GameApplication.app.models.gettingEnemies = false;
		}
		
		public static function parseMailMessages(messages:Array):void{
			var temp:ArrayCollection = new ArrayCollection();
			var message:MailMessageModel;
			
			if(messages == null || (messages && messages.length == 0)){				
				GameApplication.app.models.endMessages = true;
				GameApplication.app.models.gettingMessages = false;
				if(GameApplication.app.models.mailMessages.length == 0){
					GameApplication.app.models.mailMessages.refresh();
				}
				return;
			}
			
			for(var i:int = 0; i < messages.length; i++){
				message = new MailMessageModel(User.createFromObject(messages[i]), messages[i][ProtocolKeys.MESSAGE], messages[i][ProtocolKeys.MESSAGE_ID], messages[i][ProtocolKeys.TIME]);
				temp.addItem(message);
			}
			GameApplication.app.models.mailMessages.addAll(temp);
			GameApplication.app.models.gettingMessages = false;
		}
		
		public static function parseClans(clans:Array):void{
			var temp:ArrayCollection = new ArrayCollection();
			var clanInfo:ClanModel;
			
			var maxExp:int;
			var maxExpDay:int;
			for(var i:int = 0; i < clans.length; i++){
				clanInfo = new ClanModel();
				clanInfo.id = clans[i][ProtocolKeys.ID];
				clanInfo.title = clans[i][ProtocolKeys.TITLE];
				clanInfo.ownertitle = clans[i][ProtocolKeys.OWNER_TITLE];
				clanInfo.money = clans[i][ProtocolKeys.MONEY];
				clanInfo.experience = clans[i][ProtocolKeys.EXPERIENCE];
				clanInfo.expday = clans[i][ProtocolKeys.EXP_DAY];
				temp.addItem(clanInfo);
				
				if(clanInfo.experience > maxExp){
					maxExp = clanInfo.experience;
				}
				if(clanInfo.expday > maxExpDay){
					maxExpDay = clanInfo.expday;
				}
			}
			
			for each(clanInfo in temp){
				var kCommon:Number = 0;
				if(maxExp == 0){
					kCommon = clanInfo.experience;
				}else{
					if(clanInfo.experience > 0 && maxExp > 0){
						kCommon = 0.4 * (clanInfo.experience / maxExp);
					}
				}
				var kDay:Number = 0;
				if(clanInfo.expday > 0 && maxExpDay > 0){
					kDay = 0.6 * (clanInfo.expday / maxExpDay);
				}
				clanInfo.k = kCommon + kDay;
			}
			
			GameApplication.app.models.clans = temp;
		}
	}
}