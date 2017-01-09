package utils.game
{
	import flash.events.Event;
	
	public class GameManagerEvent extends Event
	{
		public static var MY_USER_OUT:String = "MY_USER_OUT";
		public static var TIMER_UPDATE:String = "TIMER_UPDATE";
		
		public var value:int;
		
		public function GameManagerEvent(type:String, value:int)
		{
			super(type, false, false);
			this.value = value;
		}
		
		override public function clone() : Event {
			return new GameManagerEvent(type, value);
		}
	}
}