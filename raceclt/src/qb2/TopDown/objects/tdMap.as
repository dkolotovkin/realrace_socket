/**
 * Copyright (c) 2010 Johnson Center for Simulation at Pine Technical College
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

package qb2.TopDown.objects 
{
	import qb2.As3Math.geo2d.*;
	import flash.display.*;
	import flash.utils.*;
	import qb2.QuickB2.events.qb2ContainerEvent;
	import qb2.QuickB2.objects.*;
	import qb2.QuickB2.objects.tangibles.*;
	import qb2.surrender.srGraphics2d;
	import qb2.TopDown.*;
	import qb2.TopDown.ai.*;
	import qb2.TopDown.internals.*;
	
	use namespace td_friend;
	
	/**
	 * ...
	 * @author Doug Koellmer
	 */
	public class tdMap extends qb2Group
	{
		private const trackDict:Dictionary = new Dictionary(true);
		
		public function tdMap():void
		{
			addEventListener(qb2ContainerEvent.ADDED_OBJECT,   justAddedObject, null, true);
			addEventListener(qb2ContainerEvent.REMOVED_OBJECT, justRemovedObject, null, true);
		}
		
		public function get trafficManager():tdTrafficManager
			{  return _trafficManager;  }
		public function set trafficManager(manager:tdTrafficManager):void
		{
			if ( _trafficManager )  _trafficManager.setMap(null);
			_trafficManager = manager;
			_trafficManager.setMap(this);
		}
		private var _trafficManager:tdTrafficManager;
		
		protected override function update():void
		{
			super.update();
			
			if ( _trafficManager )  _trafficManager.relay_update();
		}
		
		private function justAddedObject(evt:qb2ContainerEvent):void
		{
			var object:qb2Object = evt.child;
			
			if ( object is tdTrack )
			{
				var track:tdTrack = object as tdTrack;
				track._map = this;
				
				trackDict[track] = true;
				
				updateTrackBranches(track);
			}
		}
		
		private function justRemovedObject(evt:qb2ContainerEvent):void
		{
			var object:qb2Object = evt.child;
			
			if ( object is tdTrack )
			{
				var track:tdTrack = object as tdTrack;
				track.clearBranches();
				track._map = null;
				
				delete trackDict[track];
			}
		}
		
		td_friend function updateTrackBranches(track:tdTrack):void
		{
			if ( !trackDict[track] )  return;
			
			track.clearBranches();
			
			for ( var key:* in trackDict ) 
			{
				var ithTrack:tdTrack = key as tdTrack;
				
				var trackLine:amLine2d = track.lineRep;
				var ithTrackLine:amLine2d = ithTrack.lineRep;
				
				var intPoint:amPoint2d = new amPoint2d();
				if ( trackLine.intersectsLine(ithTrackLine, intPoint) )
				{
					//--- Add the ith track to the input track's branches.
					var trackBranch:tdInternalTrackBranch = new tdInternalTrackBranch();
					trackBranch.track = ithTrack;
					trackBranch.distance = trackLine.getDistAtPoint(intPoint);
					track.addBranch(trackBranch);
					
					//--- Add the input track to the ith track's branches.
					trackBranch = new tdInternalTrackBranch();
					trackBranch.track = track;
					trackBranch.distance = ithTrackLine.getDistAtPoint(intPoint);
					ithTrack.addBranch(trackBranch);
				}
			}
		}

		public override function drawDebug(graphics:srGraphics2d):void
		{
			super.drawDebug(graphics);
		}
	}
}