package utils.managers.tooltip.types.district
{
	import application.gamecontainer.scene.map.MapDistrict;
	
	import utils.managers.tooltip.IToolTiped;
	import utils.managers.tooltip.types.simple.ToolTip;
	import utils.models.map.DistrictModel;
	
	public class DistrictToolTip extends ToolTip
	{
		private var _district:DistrictModel;
		
		public function DistrictToolTip()
		{
			super();
			setStyle("skinClass", DistrictToolTipSkin);
		}
		
		override public function updateState() : void {
			if (initialized) {
				(skin as DistrictToolTipSkin).title.text = _district.title;
				(skin as DistrictToolTipSkin).classLbl.text = _district.carClassDescription;
				(skin as DistrictToolTipSkin).prizeLbl.text = "Максимальная награда (опыта): " + Math.ceil(_district.experienceK * 10);
			}
		}
		
		override public function set target(value : IToolTiped) : void {
			if (value is MapDistrict){
				_district = MapDistrict(value).district;
				
				updateState();
			}
		}
	}
}