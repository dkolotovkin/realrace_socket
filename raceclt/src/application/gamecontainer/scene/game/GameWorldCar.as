package application.gamecontainer.scene.game
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	
	import utils.flasher.IFlashing;
	
	public class GameWorldCar extends Sprite implements IFlashing
	{
		private var _glow:GlowFilter = new GlowFilter(0xffffff, 1, 3, 3, 1);
		
		public function GameWorldCar()
		{
			super();
		}
		
		private var _flash:Boolean;
		
		public function set flash(value:Boolean):void
		{
			if(_flash == value)
				return;
			
			_flash = value;
			
			if(_flash)
				filters = [_glow];
			else
				filters = [];
			
		}
		
		public function get flash():Boolean
		{
			return _flash;
		}
	}
}