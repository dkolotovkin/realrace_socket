package utils.managers.tooltip.types.durability
{
	import application.gamecontainer.persinfobar.durability.DurabilityIndicator;
	
	import utils.managers.tooltip.IToolTiped;
	import utils.managers.tooltip.types.simple.ToolTip;
	
	public class DurabilityToolTip extends ToolTip
	{
		private var durability:uint;
		private var maxDurability:uint;
		
		public function DurabilityToolTip()
		{
			super();
			setStyle("skinClass", DurabilityToolTipSkin);
		}
		
		override public function updateState() : void {
			if (initialized) {
				(skin as DurabilityToolTipSkin).durability.text = durability + "/" + maxDurability;				
			}
		}
		
		override public function set target(value : IToolTiped) : void {
			if (value is DurabilityIndicator){				
				durability = DurabilityIndicator(value).durability;
				maxDurability = DurabilityIndicator(value).maxDurability;
				updateState();
			}
		}
	}
}