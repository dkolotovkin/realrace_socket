package utils.models.game
{
	import application.gamecontainer.scene.game.SceneElements;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;

	public class GameModel extends EventDispatcher
	{
		public var sceneWidth:Number;
		public var sceneHeight:Number;
		
		public var sceneMinWidth:Number = 750;
		public var sceneMinHeight:Number = 380;
		
		public var sceneVisibleWidth:Number = 750;
		public var sceneVisibleHeight:Number = 380;
		
		public var sceneX:Number;
		public var sceneY:Number;
		public var showByMiniMap:Boolean;
		
		public var carPoint:Point;
		public var carRotation:Number;
		
		[Bindable]
		public var currentLap:int;
		[Bindable]
		public var mapID:int;
		[Bindable]
		public var laps:int;
		
		public var gameStatus:int;
		
		public var gameType:int;
		
		public function GameModel()
		{
		}
		
		public function deserializeXML(xmlContent:XML):void
		{
		}
	}
}