package application.gamecontainer.scene.game
{
	import flash.display.Stage;
	
	import qb2.As3Math.general.amUtils;
	import qb2.TopDown.ai.controllers.tdKeyboardCarController;
	import qb2.TopDown.objects.tdCarBody;
	
	public class KeyboardCarController extends tdKeyboardCarController
	{
		private var _leftRight:Number = 0;
		
		public var forward:Boolean;
		public var back:Boolean;
		public var left:Boolean;
		public var right:Boolean;
		public var brake:Boolean;
		
		public function KeyboardCarController()
		{
			super(null);
		}
		
		protected override function update():void
		{
			super.update();
			
			brainPort.clear();
			
			var brakeDown:Boolean = brake;
			var forwardDown:Boolean = forward;
			var backDown:Boolean = back;
			var leftDown:Boolean = left;
			var rightDown:Boolean = right;
			
			var forwardBack:Number = 0;
			var brake:Number = brakeDown ? 1 : 0;
			
			if ( forwardDown && !backDown )  forwardBack = 1;
			else if ( !forwardDown && backDown )  forwardBack = -1;
			
			if ( leftDown || rightDown )
			{
				if ( leftDown  )
				{
					if ( _leftRight > 0 )  _leftRight = 0;
					_leftRight -= turnRate;
				}
				if ( rightDown )
				{
					if ( _leftRight < 0 )  _leftRight = 0;
					_leftRight += turnRate;
				}
				
				_leftRight = amUtils.constrain(_leftRight, -1, 1);
			}
			else
			{
				_leftRight = 0;
			}
			
			brainPort.NUMBER_PORT_1 = forwardBack;
			brainPort.NUMBER_PORT_2 = _leftRight * (host as tdCarBody).maxTurnAngle;
			brainPort.NUMBER_PORT_3 = brake;
		}
	}
}