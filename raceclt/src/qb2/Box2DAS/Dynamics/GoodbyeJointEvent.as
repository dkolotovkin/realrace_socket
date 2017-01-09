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
	
	public class GoodbyeJointEvent extends Event {
		
		public static var GOODBYE_JOINT:String = 'onGoodbyeJoint';
		
		public var joint:b2Joint;
		
		public function GoodbyeJointEvent(j:b2Joint) {
			joint = j;
			super(GOODBYE_JOINT);
		}
	}
}