package utils.game
{
	import application.gamecontainer.scene.game.GameWorld;
	
	import flash.events.EventDispatcher;
	
	import qb2.Box2DAS.Dynamics.Contacts.b2Contact;
	import qb2.Box2DAS.Dynamics.b2ContactListener;
	import qb2.QuickB2.objects.tangibles.qb2PolygonShape;
	import qb2.QuickB2.stock.qb2TripSensor;
	
	public class GameContactListener extends b2ContactListener
	{
		private var gameWorld:GameWorld;
		
		public function GameContactListener(gw:GameWorld)
		{
			super();
			
			gameWorld = gw;
		}
		
		public override function BeginContact(contact:b2Contact):void
		{
			 var obj1:* = contact.GetFixtureA().GetBody().GetUserData();
			 var obj2:* = contact.GetFixtureB().GetBody().GetUserData();
			 
			 gameWorld && gameWorld.beginContact(obj1, obj2);
		}
	}
}