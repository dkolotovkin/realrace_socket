package utils.managers.tooltip.types.quests
{
	import application.gamecontainer.persinfobar.quests.QuestsIndicator;
	
	import mx.core.IToolTip;
	
	import utils.managers.tooltip.IToolTiped;
	import utils.managers.tooltip.types.simple.ToolTip;
	
	public class QuestsToolTip extends ToolTip implements IToolTip
	{
		private var _value:uint;
		private var _maxValue:uint;
		
		public function QuestsToolTip()
		{
			super();
			setStyle("skinClass", QuestsToolTipSkin);
		}
		
		override public function updateState() : void {
			if (initialized) {
				(skin as QuestsToolTipSkin).percent.text = _value + "/" + _maxValue;
			}
		}		
		
		override public function set target(value : IToolTiped) : void {
			if (value is QuestsIndicator){				
				_value = QuestsIndicator(value).value;
				_maxValue = QuestsIndicator(value).maxValue;
				updateState();
			}
		}
	}
}