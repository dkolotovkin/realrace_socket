package utils.managers.apimanager
{
	import application.GameApplication;
	import application.components.popup.buymoney.ng.PopUpBuyMoneyNg;
	
	import flash.external.ExternalInterface;

	public class ApiManagerNG extends ApiManager
	{
		public function ApiManagerNG()
		{
			super();
		}
		
		override public function init():void{
			idsocail = "ng" + GameApplication.app.config.uid;
			vid = String(GameApplication.app.config.uid);
			url = "";			
			GameApplication.app.connect();
		}
		
		override public function showBuyMoneyPopUp():void{
			GameApplication.app.popuper.show(new PopUpBuyMoneyNg());
		}
		
		override public function buyMoney(money:uint = 0, gamemoney:uint = 0):void{
			ExternalInterface.call("payment.openDialog", addMoneyUserID, money, gamemoney + " реалов", "Игровая валюта", "");
			GameApplication.app.popuper.hidePopUp();
		}
	}
}