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

package qb2.As3Math.geo2d
{
	import qb2.As3Math.consts.*;
	import qb2.As3Math.general.*;

	public class amBoundArea2d extends amEntity2d
	{
		public function amBoundArea2d()
		{
			if ( Object(this).constructor == amBoundArea2d )  throw new Error("amBoundArea2d" + amErrors.ILLEGAL_INSTANTIATION_ERROR_MSG);
		}
		
		public virtual function intersectsArea(otherArea:amBoundArea2d, tolerance:Number = 0, includeEdges:Boolean = false):Boolean {  return false;  }
		
		public virtual function isSingularity(tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean {  return true;  }
			
		public virtual function get area():Number {  return NaN;   }

		public virtual function containsPoint(point:amPoint2d, tolerance:Number = 0, includeEdges:Boolean = true, pointRadius:Number = 0):Boolean {  return false;  }
		
		public virtual function containsAllPoints(points:Vector.<amPoint2d>, tolerance:Number = 0, includeEdges:Boolean = true, pointRadii:Number = 0):Boolean {  return false;  }
		
		public virtual function containsArea(otherArea:amBoundArea2d, tolerance:Number = 0, includeEdges:Boolean = true):Boolean  {  return false;  }
			
		public virtual function distanceToPoint(point:amPoint2d):Number {  return NaN;  }
		
		
		public virtual function swell(byAmount:Number):amBoundArea2d { return this; }
		
		public virtual function expandToPoint(point:amPoint2d, extraRadius:Number = 0):amBoundArea2d { return this; }
		
		public virtual function expandToArea(otherArea:amBoundArea2d):amBoundArea2d { return this; }
	}
}