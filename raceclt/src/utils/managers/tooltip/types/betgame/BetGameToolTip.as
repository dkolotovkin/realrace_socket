package utils.managers.tooltip.types.betgame
{
	import application.gamecontainer.scene.betpage.betgameitem.BetGameItem;
	
	import spark.components.Label;
	
	import utils.managers.tooltip.IToolTiped;
	import utils.managers.tooltip.types.simple.ToolTip;
	
	public class BetGameToolTip extends ToolTip
	{
		private var _users:Array;
		
		public function BetGameToolTip()
		{
			super();
			setStyle("skinClass", BetGameToolTipSkin);
		}
		
		override public function updateState() : void {
			if (initialized) {
				(skin as BetGameToolTipSkin).users.removeAllElements();
				for(var i:int = 0; i < _users.length; i++){
					var l:Label = new Label();
					l.setStyle("color", 0xffffff);
					l.setStyle("fontSize", 12);
					l.text = _users[i];
					(skin as BetGameToolTipSkin).users.addElement(l);
				}
			}
		}		
		
		override public function set target(value : IToolTiped) : void {			
			if (value is BetGameItem){				
				_users = BetGameItem(value).roomInfo.users;
				updateState();
			}
		}
	}
}