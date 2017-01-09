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
	import qb2.As3Math.general.*;

	public class amCurve2d extends amEntity2d
	{
		/** Abstract base class for all curves, including, lines, circles, polylines, splines, etc.
		 */
		public function amCurve2d()
		{
			if ( Object(this).constructor == amCurve2d )  throw new Error("amCurve2d" + amErrors.ILLEGAL_INSTANTIATION_ERROR_MSG);
		}
		
		public virtual function getStartPoint():amPoint2d { return null; }
		
		public virtual function getEndPoint():amPoint2d { return null; }

		public virtual function distanceToPoint(point:amPoint2d):Number { return NaN; }
		
		public virtual function distanceToCurve(curve:amCurve2d):Number { return NaN; }
		
		public virtual function closestPointTo(point:amPoint2d):amPoint2d { return null; }
		
		public virtual function getPointAtDist(distanceAlongCurve:Number):amPoint2d {  return null; }
		
		public virtual function getDistAtPoint(pointOnCurve:amPoint2d):Number {  return NaN; }
		
		public virtual function getSubcurve(pointOrDistStart:Object, pointOrDistFinish:Object):amCurve2d { return null; }
		
		public virtual function flip():amCurve2d  { return this; }
		
		public virtual function isLinear(outputLine:amLine2d = null, radianTolerance:Number = 0):Boolean {  return false;  }
		
		public virtual function get area():Number { return NaN; }
		
		public virtual function get length():Number { return NaN; }
		
		public virtual function selfIntersects(outputPoints:Vector.<amPoint2d> = null, stopAtFirstPointFound:Boolean = true, distanceTolerance:Number = 0, radianTolerance:Number = 0):Boolean  { return false; }
		
		
		public function getSamplePoints(begDistance:Number, endDistance:Number, numPoints:uint, fixedVector:Boolean = true):Vector.<amPoint2d>
		{
			var toReturn:Vector.<amPoint2d> = new Vector.<amPoint2d>(numPoints, fixedVector);
			var inc:Number = (endDistance - begDistance)/Number(numPoints-1);
			for ( var i:int = 0; i < numPoints; i++ )
			{
				if ( fixedVector )
					toReturn[i] = getPointAtDist(begDistance + i * inc);
				else
					toReturn.push(getPointAtDist(begDistance + i * inc));
			}
			return toReturn;
		}
		
		public function splitAtPoints(splitPoints:Vector.<amPoint2d>, fixedVector:Boolean = true):Vector.<amCurve2d>
		{
			var toReturn:Vector.<amCurve2d> = Vector.<amCurve2d>(splitPoints.length + 1, fixedVector);
			toReturn[0] = getSubcurve(this.getStartPoint(), splitPoints[0]);
			for ( var i:int = 0; i < splitPoints.length; i++ )
			{
				toReturn[i+1] = getSubcurve(splitPoints[i], splitPoints[i+1]);
			}
			toReturn[toReturn.length - 1] = getSubcurve(splitPoints[splitPoints.length - 1], this.getEndPoint());
			
			return toReturn;
		}
		
		public function splitAtDists(distances:Vector.<Number>, fixedVector:Boolean = true):Vector.<amCurve2d>
		{
			var toReturn:Vector.<amCurve2d> = Vector.<amCurve2d>(distances.length + 1, fixedVector);
			
			return toReturn;
		}
		
		public function splitAtPoint(splitPoint:amPoint2d, fixedVector:Boolean = true):Vector.<amCurve2d>
		{
			var wrapper:Vector.<amPoint2d> = Vector.<amPoint2d>(1, fixedVector);
			wrapper[0] = splitPoint;
			return splitAtPoints(wrapper, fixedVector);
		}
		
		public function splitAtDist(distance:Number, fixedVector:Boolean = true):Vector.<amCurve2d>
		{
			var wrapper:Vector.<Number> = Vector.<Number>(1, fixedVector);
			wrapper[0] = distance;
			return splitAtDists(wrapper, fixedVector);
		}
		
		protected function getSubcurveHelper(pointOrDistStart:Object, pointOrDistFinish:Object, out1:amPoint2d, out2:amPoint2d):Boolean
		{
			var point1:amPoint2d, point2:amPoint2d;
			if ( pointOrDistStart is amPoint2d )
				point1 = closestPointTo(pointOrDistStart as amPoint2d);
			else if ( pointOrDistStart is Number )
				point1 = getPointAtDist(pointOrDistStart as Number);
				
			if ( pointOrDistFinish is amPoint2d )
				point2 = closestPointTo(pointOrDistFinish as amPoint2d);
			else if ( pointOrDistFinish is Number )
				point2 = getPointAtDist(pointOrDistFinish as Number);
				
			if ( point1 && point2 )
			{
				out1.copy(point1);
				out2.copy(point2);
				return true;
			}
			return false;
		}
	}
}