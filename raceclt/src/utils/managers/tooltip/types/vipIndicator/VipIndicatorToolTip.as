package utils.managers.tooltip.types.vipIndicator
{
	import application.GameApplication;
	import application.gamecontainer.scene.home.vip.VipIndicator;
	
	import utils.managers.tooltip.IToolTiped;
	import utils.managers.tooltip.types.simple.ToolTip;
	import utils.user.VipType;
	
	public class VipIndicatorToolTip extends ToolTip
	{
		private var title:String;
		private var description:String;
		
		public function VipIndicatorToolTip()
		{
			super();
			setStyle("skinClass", VipIndicatorToolTipSkin);
		}
		
		override public function updateState() : void {
			if (initialized) {
				(skin as VipIndicatorToolTipSkin).title.text = title;
				(skin as VipIndicatorToolTipSkin).description.text = description;
			}
		}
		
		override public function set target(value : IToolTiped) : void {			
			if (value is VipIndicator){
				if(GameApplication.app.userinfomanager.myuser.vip == VipType.VIP_BRONZE){
					title = "Бронзовый VIP-аккаунт";
				}else if(GameApplication.app.userinfomanager.myuser.vip == VipType.VIP_SILVER){
					title = "Серебряный VIP-аккаунт";
				}else if(GameApplication.app.userinfomanager.myuser.vip == VipType.VIP_GOLD){
					title = "Золотой VIP-аккаунт";
				}else{
					title = "undefined";
				}
				
				var days:int = Math.floor(GameApplication.app.userinfomanager.myuser.vipTime / (60 * 60 * 24));
				var hours:int =  Math.floor((GameApplication.app.userinfomanager.myuser.vipTime - days * 60 * 60 * 24) / (60 * 60));
				var minuts:int = Math.floor((GameApplication.app.userinfomanager.myuser.vipTime - days * 60 * 60 * 24 - hours * 60 * 60) / 60);
				var seconds:int = GameApplication.app.userinfomanager.myuser.vipTime - days * 60 * 60 * 24 - hours * 60 * 60 - minuts * 60;
				var hstr:String = String(hours);
				if (hours < 10) hstr = "0" + hstr;
				var mstr:String = String(minuts);
				if (minuts < 10) mstr = "0" + mstr;
				var sstr:String = String(seconds);
				if (seconds < 10) sstr = "0" + sstr;
				
				description = "Оставшееся время: " + days + " дн. " + hstr + " ч. " + mstr + " м. " + sstr + " с.";
				
				updateState();
			}
		}
	}
}