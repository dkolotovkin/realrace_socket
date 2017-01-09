package utils.user
{
	import application.GameApplication;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	import utils.models.car.CarModel;
	import utils.protocol.ProtocolKeys;

	public class User extends EventDispatcher
	{
		[Bindable]
		public var id:int;
		[Bindable]
		public var idSocial:String;
		[Bindable]
		public var title:String;
		[Bindable]
		public var sex:uint;
		[Bindable]
		public var level:uint;
		[Bindable]
		public var experience:uint;
		[Bindable]
		public var exphour:uint;
		[Bindable]
		public var expday:uint;
		[Bindable]
		public var popular:uint;
		[Bindable]
		public var maxExperience:uint;
		[Bindable]
		public var money:uint;
		[Bindable]
		public var moneyReal:uint;
		[Bindable]
		public var role:uint;
		[Bindable]
		public var url:String;	
		
		public var isonline:Boolean;
		
		public var claninfo:ClanUserInfo;
		[Bindable]
		public var vip:uint;
		public var vipTime:uint;
		
		[Bindable]
		public var activeCar:CarModel;
		public var cars:ArrayCollection = new ArrayCollection();
		
		public function User()
		{
			var sort:Sort = new Sort();
			sort.compareFunction = sortCars;
			cars.sort = sort;
		}
		
		private function sortCars(car1:CarModel, car2:CarModel, fields:Array = null):int{
			if(car1.prototype.carClass > car2.prototype.carClass){
				return 1;
			}else if(car1.prototype.carClass < car2.prototype.carClass){
				return -1;
			}else{
				if(car1.prototype.id > car2.prototype.id){
					return 1;
				}else if(car1.prototype.id < car2.prototype.id){
					return -1;
				}
			}
			return 0;
		}
		
		public function getCarById(carID:int):CarModel{
			for each(var car:CarModel in cars){
				if(car.id == carID){
					return car;
				}
			}
			return null;
		}
		
		public function clone():User{			
			var user:User = new User();
			user.id = id;
			user.idSocial = idSocial;
			user.title = title;
			user.sex = sex;
			user.level = level;
			user.popular = popular;
			user.experience = experience;
			user.exphour = exphour;
			user.expday = expday;
			user.maxExperience = maxExperience;			
			user.money = money;
			user.moneyReal = moneyReal;
			user.role = role;
			user.url = url;
			return user;
		}
		
		public function update():void{
			if (id == GameApplication.app.userinfomanager.myuser.id){
				GameApplication.app.userinfomanager.myuser.title = title;
				GameApplication.app.userinfomanager.myuser.sex = sex;
				GameApplication.app.userinfomanager.myuser.level = level;
				GameApplication.app.userinfomanager.myuser.experience = experience;
				GameApplication.app.userinfomanager.myuser.exphour = exphour;
				GameApplication.app.userinfomanager.myuser.expday = expday;
				GameApplication.app.userinfomanager.myuser.maxExperience = maxExperience;				
				GameApplication.app.userinfomanager.myuser.money = money;
				GameApplication.app.userinfomanager.myuser.moneyReal = moneyReal;
				GameApplication.app.userinfomanager.myuser.role = role;
				GameApplication.app.userinfomanager.myuser.url = url;
			}
			dispatchEvent(new UserEvent(UserEvent.UPDATE));
		}
		
		public static function createFromObject(u:Object):User{			
			if(u){
				var user:User = new User();
				user.id = int(u[ProtocolKeys.ID]);
				user.idSocial = String(u[ProtocolKeys.ID_SOCIAL]);
				user.sex = int(u[ProtocolKeys.SEX]);
				user.title = String(u[ProtocolKeys.TITLE]);	
				user.level = int(u[ProtocolKeys.LEVEL]);
				user.experience = int(u[ProtocolKeys.EXPERIENCE]);
				user.exphour = int(u[ProtocolKeys.EXP_HOUR]);
				user.expday = int(u[ProtocolKeys.EXP_DAY]);
				user.popular = int(u[ProtocolKeys.POPULAR]);
				user.maxExperience = int(u[ProtocolKeys.NEXT_LEVEL_EXPERIENCE]);				
				user.money = int(u[ProtocolKeys.MONEY]);
				user.moneyReal = int(u[ProtocolKeys.MONEY_REAL]);
				user.role = int(u[ProtocolKeys.ROLE]);
				user.url = String(u[ProtocolKeys.URL]);
				user.isonline = Boolean(u[ProtocolKeys.IS_ONLINE]);
				user.vip = int(u[ProtocolKeys.VIP]);
				user.vipTime = int(u[ProtocolKeys.VIP_TIME]);
				
				if(u[ProtocolKeys.CLAN_INFO] != null){
					user.claninfo = new ClanUserInfo(u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_ID], u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_TITLE], u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_DEPOSIT_M],
														u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_DEPOSIT_E], u[ProtocolKeys.CLAN_INFO][ProtocolKeys.CLAN_ROLE], u[ProtocolKeys.CLAN_INFO][ProtocolKeys.GET_CLAN_MONEY_AT]);
				}
				if(user.claninfo){
					user.claninfo.clantitle = u[ProtocolKeys.CLAN_TITLE];
				}
				
				if(u[ProtocolKeys.CAR] != null){
					user.activeCar = new CarModel();
					user.activeCar.id = u[ProtocolKeys.CAR][ProtocolKeys.ID];
					user.activeCar.color = u[ProtocolKeys.CAR][ProtocolKeys.COLOR];
					user.activeCar.durability = u[ProtocolKeys.CAR][ProtocolKeys.DURABILITY];
					user.activeCar.prototype = GameApplication.app.models.cars.getCarPrototypeById(u[ProtocolKeys.CAR][ProtocolKeys.CAR_PROTOTYPE]);
				}
				return user;
			}
			return null;
		}
		
		public static function createChatUserObjectByUser(u:User):Object{
			var userObject:Object = new Object();
			userObject[ProtocolKeys.ID] = u.id;
			userObject[ProtocolKeys.ID_SOCIAL] = u.idSocial;
			userObject[ProtocolKeys.SEX] = u.sex;
			userObject[ProtocolKeys.TITLE] = u.title;
			userObject[ProtocolKeys.ROLE] = u.role;
			userObject[ProtocolKeys.LEVEL] = u.level;
			userObject[ProtocolKeys.POPULAR] = u.popular;
			userObject[ProtocolKeys.URL] = u.url;
			return userObject;
		}
	}
}