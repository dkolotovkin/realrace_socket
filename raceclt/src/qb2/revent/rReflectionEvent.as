/**
 * Copyright (c) Doug Koellmer
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package qb2.revent
{
	import flash.utils.Dictionary;
	import qb2.revent.*;
	use namespace rev_friend;
	
	/**
	 * The event dispatched when a listener type or types are added or removed from a rEventDispatcher.
	 * 
	 * @author Doug Koellmer
	 */
	public class rReflectionEvent extends rEvent
	{
		public static const EVENT_TYPES_ADDED:String   = "eventTypesAdded";
		public static const EVENT_TYPES_REMOVED:String = "eventTypesRemoved";
		
		public static const ALL_EVENT_TYPES:Array      = [EVENT_TYPES_ADDED, EVENT_TYPES_REMOVED];
		
		rev_friend var _dict:Dictionary = null;
		
		public function rReflectionEvent(type:String = null)
		{
			super(type);
		}
		
		public function concernsType(eventType:String):Boolean
		{
			return _dict[eventType] ? true : false;
		}
		
		public function concernsTypes(eventTypes:Array):Boolean
		{
			for (var i:int = 0; i < eventTypes.length; i++) 
			{
				if ( _dict[eventTypes[i]] )
				{
					return true;
				}
			}
			
			return false;
		}
		
		public override function clone():rEvent
		{
			var clone:rReflectionEvent = super.clone() as rReflectionEvent;
			
			clone._dict = _dict;
			
			return clone;
		}
		
		public override function toString():String
		{
			return "[rEvent(dispatcher:" + _dispatcher + ")]";
		}
	}
}