package utils.managers.constructor
{
	import flash.events.Event;
	
	public class ConstructorManagerEvent extends Event
	{
		public static var ELEMENT_CREATED:String = "ELEMENT_CREATED";
		public static var LAPS_CHANGE:String = "LAPS_CHANGE";
		public static var BG_CHANGE:String = "BG_CHANGE";
		public static var CONSTRUCTOR_INIT:String = "CONSTRUCTOR_INIT";
		public static var SCENE_SIZE_CHANGE:String = "SCENE_SIZE_CHANGE";
		public static var ELEMENT_MOVE:String = "ELEMENT_MOVE";
		
		public var value:Number;
		
		public function ConstructorManagerEvent(type:String, value:Number = 0)
		{
			super(type, false, false);
			this.value = value;
		}
	}
}