package utils.shop
{
	import application.GameApplication;
	import application.components.popup.banoff.PopUpBanOff;
	import application.components.popup.buy.PopUpBuy;
	import application.gamecontainer.scene.bag.article.BagInGameSmallArticle;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import utils.models.ItemPrototype;
	import utils.models.car.CarModel;
	import utils.models.car.CarPrototypeModel;
	import utils.models.item.Item;
	import utils.models.item.ItemType;
	import utils.parser.Parser;
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;
	import utils.user.VipType;

	public class ShopManager
	{
		public static var WAITING_PROTOTYPES:String = "waiting";
		public static var CATEGORIES:String = "categories";
		
		private var _callBackCategories:Function;
		private var _callBackItems:Function;
		private var _callBackItemPrototypes:Function;
		
		private var _currentUrl:String;
		
		public var gameinventory:Array;
		
		private var cash:Object = new Object();
		
		private var initCallBack:Function;
		
		public function ShopManager(){						
		}
		
		public function init(callBack:Function = null):void{
			initCallBack = callBack;
			callBack();
		}
		
		public function getItemPrototypes(categoryID:uint = 0, callback:Function = null):void{
			_callBackItemPrototypes = callback;
			
			if(cash[categoryID]){
				_callBackItemPrototypes && _callBackItemPrototypes();
				_callBackItemPrototypes = null;
			}else{
				cash[WAITING_PROTOTYPES] = categoryID;
				GameApplication.app.callsmanager.call(ProtocolValues.SHOP_GET_ITEM_PROTOTYPES, ongetItemPrototypes, categoryID);				
			}
		}
		private function ongetItemPrototypes(obj:Object):void{
			var category:int = cash[WAITING_PROTOTYPES];
			cash[category] = obj;
			
			var _lastCallBack:Function = _callBackItemPrototypes;
			_callBackItemPrototypes && _callBackItemPrototypes();
			if(_callBackItemPrototypes == _lastCallBack){
				_callBackItemPrototypes = null;
				_lastCallBack = null;
			}
		}
		
		private function onBuyItem(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				var itemprototype:ItemPrototype = Parser.parseItemPrototype(buyresult[ProtocolKeys.ITEM_PROTOTYPE]);
				GameApplication.app.popuper.show(new PopUpBuy(itemprototype));
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_PROTOTYPE){
				GameApplication.app.popuper.showInfoPopUp("Невозможно купить эту вещь.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 756. Сообщите об ошибке разработчикам.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 796. Сообщите об ошибке разработчикам.");
			}
		}
		
		public function buyPresent(prototypeID:int, userID:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_BUY_PRESENT, onBuyPresent, prototypeID, userID);
		}
		
		private function onBuyPresent(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
//				var itemprototype:ItemPrototype = Parser.parseItemPrototype(buyresult[ProtocolKeys.ITEM_PROTOTYPE]);
//				GameApplication.app.popuper.show(new PopUpBuy(itemprototype, "Подарок доставлен!"));
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_PROTOTYPE){
				GameApplication.app.popuper.showInfoPopUp("Невозможно купить эту вещь.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при отправке подарка.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при отправке подарка.");
			}
		}
		
		public function getUserPresents():void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_GET_USER_ITEMS, null, GameApplication.app.models.userPresents.collection.length);
		}
		
		public function getUserItemsByCategoryID(categoryID:uint = -1, callBackItems:Function = null):void{
			_callBackItems = callBackItems;
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_GET_USER_ITEMS, ongetUserItems, categoryID);
		}
		private function ongetUserItems(obj:Object):void{
			Parser.parseUserItems(obj[ProtocolKeys.ITEMS]);
			_callBackItems && _callBackItems();
			_callBackItems = null;
		}
		
		public function buyLink(url:String):void{
			_currentUrl = url;
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_BUY_LINK, onBuyLink);
		}
		
		private function onBuyLink(buyresult:Object):void{			
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				if (_currentUrl && _currentUrl.length){
					var request:URLRequest = new URLRequest(_currentUrl);
					try {
						navigateToURL(request, '_blank');
					} catch (e:Error) {
						trace("Error occurred!");
					}
					_currentUrl = null;
				}				
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 756. Сообщите об ошибке разработчикам.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 791. Сообщите об ошибке разработчикам.");
			}
		}
		
		
		//РАБОТА С БАНОМ
		public function showBanPrice():void{	
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_GET_PRICE_BAN_OFF, ongetPriceBanOff);
		}		
		private function ongetPriceBanOff(obj:Object):void{
			var price:int = obj[ProtocolKeys.VALUE];
			GameApplication.app.popuper.show(new PopUpBanOff(price));
		}
		
		public function buyBanOff():void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_BUY_BAN_OFF, onbuyBanOff);
		}
		
		private function onbuyBanOff(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				GameApplication.app.banmanager.banoff();	
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 756. Сообщите об ошибке разработчикам.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 791. Сообщите об ошибке разработчикам.");
			}
		}
		
		public function exchangeMoney(moneyreal:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_EXCHANGE_MONEY, onExchangeMoney, Math.abs(moneyreal));
		}
		
		private function onExchangeMoney(result:Object):void{
			GameApplication.app.popuper.hidePopUp();
			if (int(result[ProtocolKeys.ERROR]) == BuyMoneyResultCode.OK){
				GameApplication.app.userinfomanager.myuser.money = int(result[ProtocolKeys.MONEY]);
				GameApplication.app.userinfomanager.myuser.moneyReal = int(result[ProtocolKeys.MONEY_REAL]);				
				GameApplication.app.popuper.showInfoPopUp("Поздравляем! Обмен прошел успешно!");
			}else if (int(result[ProtocolKeys.ERROR]) == BuyMoneyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У вас недостаточно денег для обмена.");
			}else{
				GameApplication.app.popuper.showInfoPopUp("К сожалению, данная операция невозможна.");
			}
		}
		
		public function buyCar(carPrototypeID:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_BUY_CAR, onBuyCar, carPrototypeID);
		}
		
		private function onBuyCar(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				var car:CarModel = Parser.parseCar(buyresult[ProtocolKeys.CAR]);
				if(car){
					GameApplication.app.userinfomanager.myuser.cars.addItem(car);
					GameApplication.app.userinfomanager.myuser.cars.refresh();
					
					GameApplication.app.popuper.show(new PopUpBuy(car.prototype));
				}
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 756. Сообщите об ошибке разработчикам.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.LOW_LEVEL){
				GameApplication.app.popuper.showInfoPopUp("Вам недостаточно опыта для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.EXIST){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. У вас уже есть такая машина.");
			}
		}
		
		public function rentCar(carPrototypeID:int, color:uint):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_RENT_CAR, onRentCar, carPrototypeID, color);
		}
		
		private function onRentCar(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				var car:CarModel = Parser.parseCar(buyresult[ProtocolKeys.CAR]);
				if(car){
					GameApplication.app.userinfomanager.myuser.cars.addItem(car);
					GameApplication.app.userinfomanager.myuser.cars.refresh();
					
					GameApplication.app.popuper.showInfoPopUp("Вы успешно арендовали машину");
				}
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 756. Сообщите об ошибке разработчикам.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.LOW_LEVEL){
				GameApplication.app.popuper.showInfoPopUp("Вам недостаточно опыта для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.EXIST){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. У вас уже есть такая машина.");
			}
		}
		
		public function buyVipStatus(vipStatus:int):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_BUY_VIP_STATUS, onBuyVipStatus, vipStatus);
		}
		
		private function onBuyVipStatus(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				var itemprototype:ItemPrototype = Parser.parseItemPrototype(buyresult[ProtocolKeys.ITEM_PROTOTYPE]);
				GameApplication.app.popuper.show(new PopUpBuy(itemprototype));
				var vipTipe:int = VipType.NONE;
				
				if(itemprototype.id == ItemType.VIP_BRONZE){
					vipTipe = VipType.VIP_BRONZE;
				}else if(itemprototype.id == ItemType.VIP_SILVER){
					vipTipe = VipType.VIP_SILVER;
				}else if(itemprototype.id == ItemType.VIP_GOLD){
					vipTipe = VipType.VIP_GOLD;
				}
				var day:int = 60 * 60 * 24;
				GameApplication.app.userinfomanager.setVip(vipTipe, 5 * day);
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 756. Сообщите об ошибке разработчикам.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.LOW_LEVEL){
				GameApplication.app.popuper.showInfoPopUp("Вам недостаточно опыта для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.EXIST){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. У вас уже есть такая машина.");
			}
		}
		
		public function buyCarColor(carId:int, color:uint):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_BUY_CAR_COLOR, onBuyCarColor, carId, color);
		}
		
		private function onBuyCarColor(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				var car:CarModel = Parser.parseCar(buyresult[ProtocolKeys.CAR]);
				if(GameApplication.app.userinfomanager.myuser.activeCar){
					GameApplication.app.userinfomanager.myuser.activeCar.color = car.color;
					GameApplication.app.popuper.showInfoPopUp("Вы успешно покрасили машину! ");
				}
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 756. Сообщите об ошибке разработчикам.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке.");
			}
		}
		
		public function repairCar(carId:int, byReal:Boolean = false):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_REPAIR_CAR, onRepairCar, carId, byReal);
		}
		
		private function onRepairCar(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				if(GameApplication.app.userinfomanager.myuser.activeCar){
					GameApplication.app.userinfomanager.myuser.activeCar.durability = GameApplication.app.userinfomanager.myuser.activeCar.durabilityMax;
					GameApplication.app.popuper.showInfoPopUp("Вы успешно отремонтировали машину! ");
				}
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег для этой покупки.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.SQL_ERROR){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке. Код ошибки 756. Сообщите об ошибке разработчикам.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Ошибка при покупке.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOTHING){
				GameApplication.app.popuper.showInfoPopUp("Ваш автомобиль не нуждается в ремонте.");
			}
		}
		
		public function saleItem(item:Item):void{
			GameApplication.app.callsmanager.call(ProtocolValues.SHOP_SALE_ITEM, onSaleItem, item.id);
		}		
		
		private function onSaleItem(result:Object):void{
			if (result[ProtocolKeys.ERROR] == UseResultCode.GAMEACTION_OK){
				GameApplication.app.models.userPresents.removeModelById(result[ProtocolKeys.ITEM_ID]);
			}else{
				GameApplication.app.popuper.showInfoPopUp("Невозможно продать вещь");
			}			
		}
		
		private function onSaleItemError(error:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно продать вещь");
		}
	}
}