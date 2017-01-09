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
	import qb2.As3Math.*;
	import qb2.As3Math.consts.*;
	import qb2.As3Math.general.*;
	import qb2.As3Math.geo2d.*;
	import flash.events.*;
	import qb2.surrender.srGraphics2d;
	import qb2.surrender.srIDrawable2d;
	
	use namespace am_friend;

	/** Abstract base class for all 2d point set classes. Any class that extends from this class represents a set of points in 2D space.
	 */
	public class amEntity2d extends amEntity
	{	
		public function amEntity2d()
		{
			if( Object(this).constructor == amEntity2d )  throw new Error("amEntity2d" + amErrors.ILLEGAL_INSTANTIATION_ERROR_MSG);
		}
		
		public virtual function copy(otherEntity:amEntity2d):amEntity2d { return this; };
		
		public virtual function clone():amEntity2d { return null; }
		
		public virtual function get boundBox():amBoundBox2d  { return null; }
		
		
		
		public virtual function scaleBy(xValue:Number, yValue:Number, origin:amPoint2d = null):amEntity2d { return this; }
		
		public virtual function rotateBy(radians:Number, origin:amPoint2d = null):amEntity2d { return this; }
		
		public virtual function translateBy(vector:amVector2d):amEntity2d { return this; }
		
		public virtual function transformBy(matrix:amMatrix2d):amEntity2d { return this; }
		
		public virtual function mirror(across:amLine2d):amEntity2d { return this; }
		
		
		
		public virtual function equals(otherEntity:amEntity2d, tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean { return false; }
		
		public virtual function isOn(point:amPoint2d, tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean { return false; }
	}
}