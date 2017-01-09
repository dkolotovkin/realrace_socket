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
	import flash.display.*;
	import flash.geom.*;
	import qb2.surrender.srGraphics2d;

	public class amBoundBox2d extends amBoundArea2d
	{
		public static const INSIDE:uint    = 0x00000000;
		public static const TO_TOP:uint    = 0x00000001;
		public static const TO_BOTTOM:uint = 0x00000002;
		public static const TO_LEFT:uint   = 0x00000004;
		public static const TO_RIGHT:uint  = 0x00000008;
		
		public var min:amPoint2d = null;
		public var max:amPoint2d = null;

		public function amBoundBox2d(initMin:amPoint2d = null, initMax:amPoint2d = null)
			{  set(initMin ? initMin : new amPoint2d(), initMax ? initMax : new amPoint2d());  }
	
		public function set(newMin:amPoint2d, newMax:amPoint2d):amBoundBox2d
			{ min = newMin;  max = newMax;  return this;  }
			
		public function setByCopy(newMin:amPoint2d, newMax:amPoint2d):amBoundBox2d
			{ min.copy(newMin);  max.copy(newMax);  return this;  }
			
		public function setToSingularity():void
		{
			min.set(0, 0);
			max.set(0, 0);
		}
		
		public function getContainment(point:amPoint2d):uint
		{
			var bits:uint = 0;
	
			if ( point.x < left )    bits |= TO_LEFT;
			if ( point.x > right )   bits |= TO_RIGHT;
			if ( point.y < top )     bits |= TO_TOP;
			if ( point.y > bottom )  bits |= TO_BOTTOM;
			
			return bits;
		}
			
		public static function newFromFlashRect(flashRect:Rectangle):amBoundBox2d
			{  return (new amBoundBox2d()).copyFlashRect(flashRect);  }
			
		public static function newFromSprite(sprite:DisplayObject, coordinateSpace:DisplayObject = null ):amBoundBox2d
		{
			var space:DisplayObject;
			if ( coordinateSpace ) space = coordinateSpace;
			else
			{
				if (sprite.parent )  space = sprite.parent;
				else space = sprite;
			}
			var rect:Rectangle = sprite.getRect(space);
			return newFromFlashRect(rect);
		}
	
		public function copyFlashRect(flashRect:Rectangle):amBoundBox2d
		{
			min.x = flashRect.x;  min.y = flashRect.y;
			max.x = flashRect.x + flashRect.width;  max.y = flashRect.y + flashRect.height;
			return this;
		}
		
		public function asLines():Vector.<amLine2d>
		{
			var corners:Vector.<amPoint2d> = asPoints();
			var sides:Vector.<amLine2d> = new Vector.<amLine2d>(4, true);
			for ( var i:int = 0; i < corners.length; i++ )
				sides[i] = new amLine2d(corners[i], i == corners.length - 1 ? corners[0] : corners[i + 1]);
			return sides;
		}
		
		public function asPoints():Vector.<amPoint2d>
		{
			var corners:Vector.<amPoint2d> = new Vector.<amPoint2d>(4, true);
			corners[0] = min.clone();
			corners[1] = min.clone().set(max.x, min.y);
			corners[2] = max.clone();
			corners[3] = max.clone().set(min.x, max.y);
			
			return corners;
		}
		
		public function get center():amPoint2d
			{  return new amPoint2d((max.x + min.x) / 2, (max.y + min.y) / 2);  }
			
		public function set center(point:amPoint2d):void
		{
			var vec:amVector2d = point.minus(center);
			min.translateBy(vec);  max.translateBy(vec);
		}
			
		public function get left():Number
			{  return min.x;  }
			
		public function get right():Number
			{  return max.x;  }
			
		public function get top():Number
			{  return min.y;  }
			
		public function get bottom():Number
			{  return max.y;  }
			
		public function get height():Number
			{  return max.y - min.y;  }
		public function set height(value:Number):void
		{
			max.y = min.y + value;
		}
		
		public function get width():Number
			{  return max.x - min.x;  }
		public function set width(value:Number):void
		{
			max.x = min.x + value;
		}
			
			
		public function get topLeft():amPoint2d
			{  return new amPoint2d(left, top);  }
			
		public function get topRight():amPoint2d
			{  return new amPoint2d(right, top);  }
			
		public function get bottomLeft():amPoint2d
			{  return new amPoint2d(left, bottom);  }
			
		public function get bottomRight():amPoint2d
			{  return new amPoint2d(right, bottom);  }
			
			
		public function get topCenter():amPoint2d
			{  return center.incY( -height / 2);  }
			
		public function get rightCenter():amPoint2d
			{  return center.incX( width / 2);  }
			
		public function get bottomCenter():amPoint2d
			{  return center.incY( height / 2);  }
			
		public function get leftCenter():amPoint2d
			{  return center.incX( -width / 2);  }
		
			
		public function get leftEdge():amLine2d
			{  return new amLine2d(bottomLeft, topLeft);  }
			
		public function get rightEdge():amLine2d
			{  return new amLine2d(topRight, bottomRight);  }
			
		public function get topEdge():amLine2d
			{  return new amLine2d(topLeft, topRight);  }
			
		public function get bottomEdge():amLine2d
			{  return new amLine2d(bottomRight, bottomLeft);  }
		
				
		public override function copy(otherEntity:amEntity2d):amEntity2d
		{
			if ( otherEntity is amBoundBox2d )
			{
				var otherBox:amBoundBox2d = otherEntity as amBoundBox2d;
				min.copy(otherBox.min);
				max.copy(otherBox.max);
			}
			
			return this;
		}
		
		public override function clone():amEntity2d
			{  return new amBoundBox2d(min.clone(), max.clone());  }
			
		public override function get boundBox():amBoundBox2d
		{
			return this.clone() as amBoundBox2d;
		}
		
		public override function scaleBy(xValue:Number, yValue:Number, origin:amPoint2d = null):amEntity2d
			{  min.scaleBy(xValue, yValue, origin);  max.scaleBy(xValue, yValue, origin);  return this;  }
		
		public override function rotateBy(radians:Number, origin:amPoint2d = null):amEntity2d
			{  throw new Error(amErrors.ILLEGAL_ROTATION_ERROR_MSG);  }
		
		public override function translateBy(vector:amVector2d):amEntity2d
			{  min.translateBy(vector);  max.translateBy(vector);  return this;  }
		
		public override function transformBy(matrix:amMatrix2d):amEntity2d
			{  min.transformBy(matrix);  max.transformBy(matrix);  return this;  }
		
		public override function mirror(across:amLine2d):amEntity2d
			{  throw new Error(amErrors.ILLEGAL_MIRROR_ERROR_MSG);  }
		
		public override function equals(otherEntity:amEntity2d, tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean
		{
			if ( otherEntity is amBoundBox2d )
			{
				var otherBox:amBoundBox2d = otherEntity as amBoundBox2d;
				return min.equals(otherBox.min, tolerance, pointEqualityMode) && max.equals(max, tolerance, pointEqualityMode)
			}
			
			return false;
		}
		
		public override function isOn(point:amPoint2d, tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean
		{
			var sides:Vector.<amLine2d> = asLines();
			for ( var i:uint = 0; i < 4; i++ )
			{
				if ( sides[i].isOn(point, tolerance, pointEqualityMode) )
					return true;
			}
			return false;
		}
		
		
		
		public override function intersectsArea(otherArea:amBoundArea2d, tolerance:Number = 0, includeEdges:Boolean = false):Boolean
		{
			if ( otherArea is amBoundBox2d )
			{
				var otherBox:amBoundBox2d = otherArea as amBoundBox2d;
				
				if ( includeEdges )
					return !(this.min.x > otherBox.max.x+tolerance  || this.max.x < otherBox.min.x-tolerance  || this.min.y > otherBox.max.y+tolerance  || this.max.y < otherBox.min.y-tolerance);
				else
					return !(this.min.x >= otherBox.max.x+tolerance || this.max.x <= otherBox.min.x-tolerance || this.min.y >= otherBox.max.y+tolerance || this.max.y <= otherBox.min.y-tolerance);
			}
			else if ( otherArea is amBoundCircle2d )
			{
				return containsPoint((otherArea as amBoundCircle2d).center, tolerance, includeEdges, (otherArea as amBoundCircle2d).radius);
			}
			
			return false; 
		}
		
		public override function isSingularity(tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean
			{  return min.equals(max, tolerance, pointEqualityMode);  }	
			
		public override function get area():Number
			{  return (max.x - min.x) * (max.y - min.y);  }

		public override function containsPoint(point:amPoint2d, tolerance:Number = 0, includeEdges:Boolean = true, pointRadius:Number = 0):Boolean
		{
			if ( pointRadius == 0 )
			{
				return includeEdges ?
					amUtils.isWithin(point.x, min.x, max.x, tolerance)  && amUtils.isWithin(point.y, min.y, max.y, tolerance) :
					amUtils.isBetween(point.x, min.x, max.x, tolerance) && amUtils.isBetween(point.y, min.y, max.y, tolerance);
			}
			else
			{
				// TODO: this could probably be preceded by a simple test to arithmatically see if the point has any chance of intersecting in the first place.
				var centerDist:Number = this.distanceToPoint(point);
				if ( includeEdges )
					return centerDist <= pointRadius + tolerance;
				else
					return centerDist < pointRadius + tolerance;
			}
		}
		
		public override function containsAllPoints(points:Vector.<amPoint2d>, tolerance:Number = 0, includeEdges:Boolean = true, pointRadii:Number = 0):Boolean
		{
			for ( var i:int = 0; i < points.length; i++ )
			{
				if ( !containsPoint(points[i], tolerance, includeEdges, pointRadii) )
					return false;
			}
			return true;
		}
		
		public override function containsArea(otherArea:amBoundArea2d, tolerance:Number = 0, includeEdges:Boolean = true):Boolean
		{
			if ( otherArea is amBoundBox2d )
			{
				var otherBox:amBoundBox2d = otherArea as amBoundBox2d
				return containsPoint(otherBox.min, tolerance, includeEdges) && containsPoint(otherBox.max, tolerance, includeEdges);
			}
			else if( otherArea is amBoundCircle2d )
			{
				var circle:amBoundCircle2d = otherArea as amBoundCircle2d;
				if ( includeEdges )
				{
					return amUtils.isWithin(circle.center.x - circle.radius, min.x, max.x) && amUtils.isWithin(circle.center.x + circle.radius, min.x, max.x) &&
						   amUtils.isWithin(circle.center.y - circle.radius, min.y, max.y) && amUtils.isWithin(circle.center.y + circle.radius, min.y, max.y);   
				}
				else
				{
					return amUtils.isBetween(circle.center.x - circle.radius, min.x, max.x) && amUtils.isBetween(circle.center.x + circle.radius, min.x, max.x) &&
						   amUtils.isBetween(circle.center.y - circle.radius, min.y, max.y) && amUtils.isBetween(circle.center.y + circle.radius, min.y, max.y);
				}
			}
			
			return false;
		}
		
		public override function distanceToPoint(point:amPoint2d):Number
		{
			if ( containsPoint(point, 0, true) )  return 0;
	
			var smallestDist:Number = Infinity;
			var sides:Vector.<amLine2d> = asLines();
			for ( var i:uint = 0; i < 4; i++ )
			{
				var distance:Number = sides[i].distanceToPoint(point);
				if ( distance < smallestDist )
					smallestDist = distance;
			}
			return smallestDist;
		}
		
		public override function swell(byAmount:Number):amBoundArea2d
		{
			min.x -= byAmount;  min.y -= byAmount;
			max.x += byAmount;  max.y += byAmount;
			return this;
		}
		
		public override function expandToPoint(point:amPoint2d, extraRadius:Number = 0):amBoundArea2d
		{
			if ( point.x - extraRadius < min.x ) min.x = point.x - extraRadius;
			if ( point.y - extraRadius < min.y ) min.y = point.y - extraRadius;
			
			if ( point.x + extraRadius > max.x ) max.x = point.x + extraRadius;
			if ( point.y + extraRadius > max.y ) max.y = point.y + extraRadius;
			
			return this;
		}
		
		public override function expandToArea(otherArea:amBoundArea2d):amBoundArea2d
		{
			if ( otherArea is amBoundBox2d )
			{
				var otherBox:amBoundBox2d = otherArea as amBoundBox2d;
				expandToPoint(otherBox.min);
				expandToPoint(otherBox.max);
			}
			else if( otherArea is amBoundCircle2d )
			{
				var otherCircle:amBoundCircle2d = otherArea as amBoundCircle2d;
				var minPoint:amPoint2d = otherCircle.center.clone();
				minPoint.x -= otherCircle.radius;
				minPoint.y -= otherCircle.radius;
				var maxPoint:amPoint2d = otherCircle.center.clone();
				maxPoint.x += otherCircle.radius;
				maxPoint.y += otherCircle.radius;
				expandToPoint(minPoint);
				expandToPoint(maxPoint);
			}
			return this;
		}
		
		
		
		public function getIntersection(withOtherBox:amBoundBox2d):amBoundBox2d
		{
			return null;
		}
		
		private function swapMinMax():void
		{
			var temp:amPoint2d = min;
			min = max;
			max = temp;
		}
		
		public function draw(graphics:srGraphics2d, cornerSize:Number = 0):void
		{
			var sides:Vector.<amLine2d> = asLines();
			for ( var i:int = 0; i < sides.length; i++ )
				sides[i].draw(graphics, cornerSize);
		}
		
		public override function toString():String
			{  return "[amBoundBox2d( " + min.toString() + ", " + max.toString() + " )]";  }
	}	
}