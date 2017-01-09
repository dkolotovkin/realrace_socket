package application.components.popup.help.tutorial.second
{
	import application.components.buttonswf.ButtonMXML;
	
	import flash.filters.GlowFilter;
	
	public class FlashingButtonMXML extends ButtonMXML
	{
		private var _glow:GlowFilter = new GlowFilter(0xffffff, 1, 15, 15, .6);
		
		public function FlashingButtonMXML()
		{
			super();
		}
		
		override public function set flash(value:Boolean):void
		{
			if(_flash == value)
				return;
			
			_flash = value;
			
			if(_flash)
				filters = [_glow];
			else
				filters = [];
		}
	}
}