package qb2.Box2DAS.Dynamics {
	
	import qb2.Box2DAS.*;
	import qb2.Box2DAS.Collision.*;
	import qb2.Box2DAS.Collision.Shapes.*;
	import qb2.Box2DAS.Common.*;
	import qb2.Box2DAS.Dynamics.*;
	import qb2.Box2DAS.Dynamics.Contacts.*;
	import qb2.Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	import flash.events.*;
	
	public class GoodbyeFixtureEvent extends Event {
		
		public static var GOODBYE_FIXTURE:String = 'onGoodbyeFixture';
		
		public var fixture:b2Fixture;
		
		public function GoodbyeFixtureEvent(f:b2Fixture) {
			fixture = f;
			super(GOODBYE_FIXTURE);
		}
	}
}