package application.components.buttonswf
{
	import application.GameApplication;
	import application.components.iconswf.IconMXML;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	
	import utils.sound.SoundType;
	
	public class ButtonMXMLExit extends UIComponent
	{
		protected var _icon:MovieClip;
		
		public function ButtonMXMLExit() {		
			super();
			
			buttonMode = true;
			
			addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);	
			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}
		
		public function set iconClass(ClipClass:Class):void{
			if(_icon == null){
				_icon = new ClipClass();
				_icon.stop();
				width = _icon.width;
				height = _icon.height;
				addChild(_icon);				
			}
		}
				
		private function onRollOut(event : MouseEvent): void {
			_icon.gotoAndStop(1);
			_icon.stop();
		}
		
		private function onRollOver(event : MouseEvent) : void {
			_icon.play();
		}
		
		private function onClick(event : MouseEvent) : void {
			GameApplication.app.soundmanager.play(SoundType.CLICK);
		}
	}
}