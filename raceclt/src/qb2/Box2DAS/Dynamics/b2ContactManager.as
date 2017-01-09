﻿package qb2.Box2DAS.Dynamics {
	
	import qb2.Box2DAS.*;
	import qb2.Box2DAS.Collision.*;
	import qb2.Box2DAS.Collision.Shapes.*;
	import qb2.Box2DAS.Common.*;
	import qb2.Box2DAS.Dynamics.*;
	import qb2.Box2DAS.Dynamics.Contacts.*;
	import qb2.Box2DAS.Dynamics.Joints.*;
	import cmodule.Box2D.*;

	// Delegate of b2World.
	public class b2ContactManager extends b2Base {
		
		public function b2ContactManager(p:int) {
			_ptr = p;
			m_broadPhase = new b2BroadPhase(_ptr + 0);
		}
		
		public function get m_contactList():b2Contact {
			return new b2Contact(mem._mr32(_ptr + 60));
		}
		
		public function get m_contactCount():int { return mem._mr32(_ptr + 64); }
		public function set m_contactCount(v:int):void { mem._mw32(_ptr + 64, v); }
		public var m_broadPhase:b2BroadPhase;
	
	}
}