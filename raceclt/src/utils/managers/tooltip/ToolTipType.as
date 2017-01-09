package utils.managers.tooltip {	
	import mx.core.IToolTip;
	
	import utils.managers.tooltip.types.betgame.BetGameToolTip;
	import utils.managers.tooltip.types.carPrototype.CarPrototypeToolTip;
	import utils.managers.tooltip.types.clanrole.ClanRoleToolTip;
	import utils.managers.tooltip.types.district.DistrictToolTip;
	import utils.managers.tooltip.types.durability.DurabilityToolTip;
	import utils.managers.tooltip.types.experience.ExperienceToolTip;
	import utils.managers.tooltip.types.popular.PopularToolTip;
	import utils.managers.tooltip.types.quests.QuestsToolTip;
	import utils.managers.tooltip.types.simple.ToolTip;
	import utils.managers.tooltip.types.titleanddesc.TitleAndDescriptionToolTip;
	import utils.managers.tooltip.types.vip.VipPrototypeToolTip;
	import utils.managers.tooltip.types.vipIndicator.VipIndicatorToolTip;

	public class ToolTipType {		
		public static const SIMPLE:int = 0;		public static const EXPERIENCE:int = 1;		
		public static const CLANROLE:int = 3;
		public static const TITLEANDDESCRIPTION:int = 4;
		public static const BETGAME:int = 5;
		public static const POPULAR:int = 6;
		public static const QUESTS:int = 7;
		public static const CAR_PROTOTYPE:int = 8;
		public static const VIP_PROTOTYPE:int = 9;
		public static const VIP_INDICATOR:int = 10;
		public static const DURABILITY:int = 11;
		public static const DISTRICT:int = 12;
				
		public static function createToolTip (type:int):IToolTip {
			if (type == EXPERIENCE){				return new ExperienceToolTip();		
			}else if (type == CLANROLE){
				return new ClanRoleToolTip();
			}else if (type == TITLEANDDESCRIPTION){
				return new TitleAndDescriptionToolTip();
			}else if (type == BETGAME){
				return new BetGameToolTip();
			}else if (type == POPULAR){
				return new PopularToolTip();
			}else if (type == QUESTS){
				return new QuestsToolTip();
			}else if (type == CAR_PROTOTYPE){
				return new CarPrototypeToolTip();
			}else if (type == VIP_PROTOTYPE){
				return new VipPrototypeToolTip();
			}else if (type == VIP_INDICATOR){
				return new VipIndicatorToolTip();
			}else if (type == DURABILITY){
				return new DurabilityToolTip();
			}else if (type == DISTRICT){
				return new DistrictToolTip();
			}
			return new ToolTip();
		}
	}
}
