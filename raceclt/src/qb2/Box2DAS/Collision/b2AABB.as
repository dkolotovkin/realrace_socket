package qb2.Box2DAS.Collision {
	
	import qb2.Box2DAS.*;
	import qb2.Box2DAS.Collision.*;
	import qb2.Box2DAS.Collision.Shapes.*;
	import qb2.Box2DAS.Common.*;
	import qb2.Box2DAS.Dynamics.*;
	import qb2.Box2DAS.Dynamics.Contacts.*;
	import qb2.Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;
	
	/// An axis aligned bounding box.
	public class b2AABB extends b2Base {
		
		public function b2AABB(p:int) {
			_ptr = p;
			lowerBound = new b2Vec2(_ptr + 0);
			upperBound = new b2Vec2(_ptr + 8);
		}
		
		public function get aabb():AABB {
			return new AABB(lowerBound.v2, upperBound.v2);
		}
		
		public function set aabb(v:AABB):void {
			lowerBound.v2 = v.lowerBound;
			upperBound.v2 = v.upperBound;
		}
		
		public var lowerBound:b2Vec2; // lowerBound = new b2Vec2(_ptr + 0);
		public var upperBound:b2Vec2; // upperBound = new b2Vec2(_ptr + 8);
	
	}
}