package utils.models
{
	import mx.collections.ArrayCollection;
	
	import utils.models.car.CarsModel;
	import utils.models.game.GameModel;
	import utils.models.map.MapModel;
	import utils.models.quests.QuestsModel;
	import utils.models.vips.VipsModel;
	import utils.user.User;

	public class Models
	{
		[Bindable]
		public var friends:ArrayCollection;		
		public var gettingFriends:Boolean = false;
		public var endFriends:Boolean = false;
		
		[Bindable]
		public var chatForUser:User;		
		
		[Bindable]
		public var onlineUsersCount:int;
		
		[Bindable]
		public var usersOfLastMessages:ArrayCollection;
		public var usersOfLastMessagesHash:Object;
		
		[Bindable]
		public var cheaters:ArrayCollection;
		
		[Bindable]
		public var enemies:ArrayCollection;
		public var gettingEnemies:Boolean = false;
		public var endEnemies:Boolean = false;
		
		[Bindable]
		public var mailMessages:ArrayCollection;
		public var gettingMessages:Boolean = false;
		public var endMessages:Boolean = false;
		
		[Bindable]
		public var shopCategories:ArrayCollection;
		[Bindable]
		public var itemPrototypes:ItemPrototypesCollectionModel;
		[Bindable]
		public var userItems:UserItemsCollectionModel;
		[Bindable]
		public var userPresents:UserPresentsCollectionModel;
		[Bindable]
		public var currentClan:CurrentClanModel;
		[Bindable]
		public var clans:ArrayCollection;
		[Bindable]
		public var settings:SettingsModel;
		
		public var options:OptionsModel;
		[Bindable]
		public var gameModel:GameModel;
		[Bindable]
		public var chatTabsCollection:ArrayCollection;
		[Bindable]
		public var questsModel:QuestsModel;
		
		public var cars:CarsModel;
		public var vips:VipsModel;
		
		public var map:MapModel;
		
		public function Models()
		{
			shopCategories = new ArrayCollection();
			friends = new ArrayCollection();
			enemies = new ArrayCollection();
			cheaters = new ArrayCollection();
			mailMessages = new ArrayCollection();
			chatTabsCollection = new ArrayCollection();
			usersOfLastMessages = new ArrayCollection();
			usersOfLastMessagesHash = new Object();
			
			currentClan = new CurrentClanModel();			
			itemPrototypes = new ItemPrototypesCollectionModel();
			userItems = new UserItemsCollectionModel();
			userPresents = new UserPresentsCollectionModel();
			settings = new SettingsModel();
			options = new OptionsModel();
			gameModel = new GameModel();
			questsModel = new QuestsModel();
			
			cars = new CarsModel();
			vips = new VipsModel();
			map = new MapModel();
		}
	}
}