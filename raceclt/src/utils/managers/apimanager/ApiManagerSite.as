package utils.managers.apimanager
{
	import application.GameApplication;
	import application.components.popup.buymoney.site.PopUpBuyMoneySite;
	import application.components.popup.friendbonus.PopUpFriendBonus;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	
	import utils.md5.Md5;

	public class ApiManagerSite extends ApiManager
	{		
		public function ApiManagerSite()
		{	
			idsocail = GameApplication.app.config.login;
		}
		
		override public function init():void{			
			GameApplication.app.connect();
		}
		
		override public function buyMoney(money:uint = 0, gamemoney:uint = 0):void{
			var fields:URLVariables = new URLVariables();			
			var request:URLRequest;
			
			if(true){
				fields.project = 2906;														//id проекта
				fields.source = "http://mouserun.ru";
				fields.amount = money;
				fields.nickname = addMoneyUserID;
				fields[addMoneyUserID + "_extra"] = addMoneyUserID;
				
				request = new URLRequest("http://paymentgateway.ru/");
				request.method = URLRequestMethod.POST;
				request.data = fields;
			}else if(false){
				fields.eshopId = 435573;													//id магазина
				fields.orderId = 0;															//id платежа
				fields.serviceName = "Покупка игровой валюты: " + gamemoney + " реалов.";	//описание
				fields.recipientAmount = money;												//сумма покупки
				fields.recipientCurrency = "RUB";											//валюта				 
//				fields.userName = GameApplication.app.userinfomanager.myuser.title;			//login
				fields.userField_1 = addMoneyUserID;
				
				request = new URLRequest("https://merchant.intellectmoney.ru/ru/");
				request.method = URLRequestMethod.POST;
				request.data = fields;
			}else if(false){
				fields.MrchLogin = "dkolotovkin";										//login
				fields.OutSum = money;													//сумма покупки
				fields.InvId = 0;														//номер счета в магазине
				fields.Desc = "Покупка игровой валюты: " + gamemoney + " реалов.";		//описание
				fields.shpa = addMoneyUserID;
				fields.SignatureValue = Md5.hash("dkolotovkin:" + money + ":" + 0 + ":qwerty123:shpa=" + addMoneyUserID);
				
				request = new URLRequest("https://merchant.roboxchange.com/Index.aspx");
				request.method = URLRequestMethod.POST;
				request.data = fields;
			}else{
				fields.spShopId = 7877;													//id магазина			
				fields.spShopPaymentId = money;											//id покупки
				fields.spAmount = money;												//сумма покупки		
				fields.spCurrency = "rur";												//валюта
				
				fields.spPurpose = "Покупка игровой валюты: " + gamemoney + " реалов.";	//описание
				fields.lang = "ru";														//язык
				fields.tabNum = 1;														//таб, который будет выделен при переходе на сайт оплаты (1 - электронные платежи)
				fields.spUserDataUserID = addMoneyUserID;								//id пользователя
				
				request = new URLRequest("http://sprypay.ru/sppi/");
				request.method = URLRequestMethod.POST;
				request.data = fields;				
			}
			
			try {				
				navigateToURL(request, '_blank');
			} catch (e:Error) {
				trace("Error occurred!");
			}
			
			GameApplication.app.popuper.hidePopUp();
		}
		
		override public function inviteFriends():void{
			GameApplication.app.popuper.show(new PopUpFriendBonus());
		}
		
		override public function showBuyMoneyPopUp():void{
//			GameApplication.app.popuper.showInfoPopUp("Платежи на сайте в настоящее время не принимаются");
			if(GameApplication.app.userinfomanager.myuser.level >= 3 && GameApplication.app.config.playmode != 1){
				GameApplication.app.popuper.show(new PopUpBuyMoneySite());
			}
		}
		
		/*public function redirect():void{
			if(GameApplication.app.so){
				GameApplication.app.so.data["redirecing"] = true;
				GameApplication.app.so.data["currentServerIndex"] = GameApplication.app.serversmanager.currentServerIndex;
				GameApplication.app.so.flush();
				
				if(GameApplication.app.so.data["lastconnectedmode"] == GameMode.VK){
					authVK();
				}else if(GameApplication.app.so.data["lastconnectedmode"] == GameMode.MM){
					authMM();
				}else if(GameApplication.app.so.data["lastconnectedmode"] == GameMode.OD){
					authOD();
				}
			}
		}
		
		public function authVK():void{
			if(GameApplication.app.so){
				GameApplication.app.so.data["lastconnectedmode"] = GameMode.VK;
				GameApplication.app.so.flush();
			}
			
			var request:URLRequest = new URLRequest(GameApplication.app.config.authVKUrl);
			request.method = URLRequestMethod.GET;
			var variables:URLVariables = new URLVariables();
			variables.client_id = GameApplication.app.config.hardcodeSiteVkId;
			variables.scope = "notify";
			variables.redirect_uri = GameApplication.app.config.oficalSiteUrl;
			variables.response_type = "code";
			request.data = variables;
			navigateToURL(request, "_self");
		}
		
		public function authMM():void{
			if(GameApplication.app.so){
				GameApplication.app.so.data["lastconnectedmode"] = GameMode.MM;
				GameApplication.app.so.flush();
			}
			
			var request:URLRequest = new URLRequest(GameApplication.app.config.authMMUrl);
			request.method = URLRequestMethod.GET;
			var variables:URLVariables = new URLVariables();
			variables.client_id = GameApplication.app.config.hardcodeSiteMMId;
			//variables.scope = "widget";
			variables.redirect_uri = GameApplication.app.config.oficalSiteUrl;
			variables.response_type = "code";
			request.data = variables;
			navigateToURL(request, "_self");
		}
		
		public function authOD():void{
			if(GameApplication.app.so){
				GameApplication.app.so.data["lastconnectedmode"] = GameMode.OD;
				GameApplication.app.so.flush();
			}
			
			var request:URLRequest = new URLRequest(GameApplication.app.config.authODUrl);
			request.method = URLRequestMethod.GET;
			var variables:URLVariables = new URLVariables();
			variables.client_id = GameApplication.app.config.hardcodeSiteODId;
			variables.scope = "";
			variables.redirect_uri = GameApplication.app.config.oficalSiteUrl;
			variables.response_type = "code";
			request.data = variables;
			navigateToURL(request, "_self");
		}*/
	}
}