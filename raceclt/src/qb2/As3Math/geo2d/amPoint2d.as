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
	import qb2.As3Math.general.amSettings;
	import qb2.As3Math.general.amEntity;
	import qb2.As3Math.general.amUpdateEvent;
	import flash.display.Graphics;
	import qb2.As3Math.geo2d.amVector2d;
	import qb2.As3Math.*;
	import qb2.As3Math.consts.*;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import qb2.surrender.srGraphics2d;
	
	import qb2.As3Math.am_friend;
	use namespace am_friend;

	public class amPoint2d extends amEntity
	{
		public var userData:* = null;
		
		am_friend var _x:Number, _y:Number;
		
		public static const reusable:amPoint2d = new amPoint2d(0, 0);
		private static const internalReusable:amPoint2d = new amPoint2d();
		
		
		private var freezeSendings:Boolean = false;
		
		public function amPoint2d( initX:Number = 0, initY:Number = 0 ):void
		{
			_x = initX;  _y = initY;
		}
		
		private function sendCallbacks():void
		{
			if ( freezeSendings )  return;
			
			var evt:amUpdateEvent = CACHED_UPDATE_EVENT.inUse ? new amUpdateEvent() : CACHED_UPDATE_EVENT;
			evt.type = amUpdateEvent.ENTITY_UPDATED;
			evt._entity = this;
			dispatchEvent(evt);
		}
		
		public static function newPoint(initX:Number = 0, initY:Number = 0):amPoint2d
			{  return new amPoint2d(initX, initY);  }
			
		public function set( newX:Number = 0, newY:Number = 0 ):amPoint2d
		{
			_x = newX;  _y = newY;
			sendCallbacks();
			return this;
		}
			
		public function get x():Number
			{  return _x;  }
		public function set x(value:Number):void
		{
			_x = value;
			sendCallbacks();
		}
		public function get y():Number
			{  return _y;  }
		public function set y(value:Number):void
		{
			_y = value;
			sendCallbacks();
		}
		
		public function setX(value:Number):amPoint2d
			{  return set(value, _y);  }
		public function setY(value:Number):amPoint2d
			{  return set(_x, value);  }
			
		public function incX(value:Number):amPoint2d
			{  return set(_x + value, _y );  }
		public function incY(value:Number):amPoint2d
			{  return set(_x, _y + value);  }

		
		public function add(otherPoint:amPoint2d):amPoint2d  // (returns this + otherVector)
		{
			_x += otherPoint._x;  _y += otherPoint._y;
			sendCallbacks();
			return this;
		}
		
		public function subtract(otherPoint:amPoint2d):amPoint2d  // (returns this + otherVector)
		{
			_x -= otherPoint._x;  _y -= otherPoint._y;
			sendCallbacks();
			return this;
		}
			
		public function copy(otherPoint:amPoint2d):amPoint2d
		{
			if ( otherPoint )
			{
				_x = otherPoint._x;  _y = otherPoint._y;
			}
			else
			{
				_x = 0;  _y = 0;
			}
			
			sendCallbacks();
			return this;
		}
		
		public function copyObject(otherPointObject:Object):amPoint2d
		{
			_x = otherPointObject.x;  _y = otherPointObject.y;
			sendCallbacks();
			return this;
		}
		
		public function clone():amPoint2d
			{  return new amPoint2d(x, y);  }
		
		public function copyFlashPoint(flashPoint:flash.geom.Point):amPoint2d
		{
			_x = flashPoint.x;  _y = flashPoint.y;
			sendCallbacks();
			return this;
		}		
		
		public function asVector():amVector2d
			{  return new amVector2d(_x, _y);  }
			
		public function asFlashPoint():Point
			{  return new Point(_x, _y);  };
			
		
		
		public static function newFromFlash(somePoint:flash.geom.Point):amPoint2d
			{  return new amPoint2d(somePoint.x, somePoint.y);  }
			
		public function orthoProjectedToLine(line:amLine2d):amPoint2d
		{
			var saveType:uint = line.lineType;
			line.lineType = amLine2d.LINE_TYPE_INFINITE;
			var point:amPoint2d = line.closestPointTo(this);
			line.lineType = saveType;
			return point;
		}

		public function translateBy(vector:amVector2d ):amPoint2d
		{
			_x += vector.x;  _y += vector.y;
			sendCallbacks();
			return this;
		}
			
		public function translatedBy(vector:amVector2d ):amPoint2d
			{  return this.clone().translateBy(vector);  }
			
		public function scaleBy(xValue:Number, yValue:Number, origin:amPoint2d = null):amPoint2d
		{
			freezeSendings = true;
			
			if ( origin )
			{
				var vec:amVector2d = internalReusable.set().minus(origin);
				this.translateBy(vec);
				_x *= xValue;  _y *= yValue;
				this.translateBy(vec.negate());
			}
			else
			{
				_x *= xValue;  _y *= yValue;
			}
			
			freezeSendings = false;
			sendCallbacks();
			
			return this;
		}

		public function scaledBy(xValue:Number, yValue:Number, origin:amPoint2d = null):amPoint2d
			{  return this.clone().scaleBy(xValue, yValue, origin);  }
			
		public function rotateBy(radians:Number, origin:amPoint2d = null):amPoint2d
		{
			origin = origin ? origin : internalReusable.set();
			
			const sinRad:Number = Math.sin(radians);
			const cosRad:Number = Math.cos(radians);
			const newVertX:Number = origin._x + cosRad * (this._x - origin._x) - sinRad * (this._y - origin._y);
			const newVertY:Number = origin._y + sinRad * (this._x - origin._x) + cosRad * (this._y - origin._y);
			
			_x = newVertX;
			_y = newVertY;
			
			sendCallbacks();

			return this;
		}
		
		public function rotatedBy(radians:Number, origin:amPoint2d = null):amPoint2d
			{  return this.clone().rotateBy(radians, origin);  }
			
		public function transformBy(matrix:amMatrix2d):amPoint2d
		{
			sendCallbacks();
			return this;
		}
			
		public function transformedBy(matrix:amMatrix2d):amPoint2d
			{  return this.clone().transformBy(matrix);  }
			
		/** Mirrors the point across the given line. The line is treated as infinite no matter its lineType.
		 */
		public function mirror(across:amLine2d):amPoint2d
		{
			var saveType:uint = across.lineType;
			across.lineType = amLine2d.LINE_TYPE_INFINITE;
			var closestPnt:amPoint2d = across.closestPointTo(this);
			across.lineType = saveType;
			var vec:amVector2d = this.minus(closestPnt).negate();
			return copy(closestPnt.translateBy(vec)); // calls sendCallbacks()
		}
		
		public function mirrored(across:amLine2d):amPoint2d
			{  return this.clone().mirror(across);  }
			
		public function minus( otherPoint:amPoint2d ):amVector2d
			{  return new amVector2d(x - otherPoint._x, y - otherPoint._y);  }
			
		public function midwayPoint(betweenOtherPoint:amPoint2d):amPoint2d
			{  return this.clone().translateBy(betweenOtherPoint.minus(this).scaleBy(.5));  }

		public function distanceTo( otherPoint:amPoint2d ):Number
			{  return this.minus(otherPoint).length;  }
			
		public function manhattanDistanceTo(otherPoint:amPoint2d):Number
			{  return Math.abs(otherPoint._x - this._x) + Math.abs(otherPoint._y - this._y);  }
			
			
			
			
		public static function translateBy(points:Vector.<amPoint2d>, vector:amVector2d):Vector.<amPoint2d>
		{
			for ( var i:int = 0; i < points.length; i++ )
				points[i].translateBy(vector);
			return points;
		}
		
		public static function scaleBy(points:Vector.<amPoint2d>, xValue:Number, yValue:Number, origin:amPoint2d = null):Vector.<amPoint2d>
		{
			for ( var i:int = 0; i < points.length; i++ )
				points[i].scaleBy(xValue, yValue, origin);
			return points;
		}
		
		public static function rotateBy(points:Vector.<amPoint2d>, radians:Number, origin:amPoint2d = null):Vector.<amPoint2d>
		{
			for ( var i:int = 0; i < points.length; i++ )
				points[i].rotateBy(radians, origin);
			return points;
		}
		
		public static function transformBy(points:Vector.<amPoint2d>, matrix:amMatrix2d):Vector.<amPoint2d>
		{
			for ( var i:int = 0; i < points.length; i++ )
				points[i].transformBy(matrix);
			return points;
		}
		
		public static function mirror(points:Vector.<amPoint2d>, across:amLine2d):Vector.<amPoint2d>
		{
			for ( var i:int = 0; i < points.length; i++ )
				points[i].mirror(across);
			return points;
		}
		
		
 
		public function equals(aPoint:amPoint2d, tolerance:Number = 0, equalityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean
		{
			if( tolerance == 0 )
				return aPoint.x == x && aPoint.y == y;
			else
			{
				if ( AM_EQUALITY_MANHATTAN_TO )
					return Math.abs(_x - aPoint.x) <= tolerance && Math.abs(_y - aPoint.y) <= tolerance;
				else if( AM_EQUALITY_DISTANCE_TO )
					return this.distanceTo(aPoint) <= tolerance;
			}
			return false;
		}

		public function draw(graphics:srGraphics2d, radius:Number = 5, drawCrossHairs:Boolean = true ):void
		{
			graphics.drawCircle(x, y, radius);
			
			if ( !drawCrossHairs )  return;
			
			graphics.moveTo(x - radius, y);
			graphics.lineTo(x + radius, y);
			graphics.lineTo(x, y - radius);
			graphics.lineTo(x, y + radius);
		}
		
		public function drawAsArrow(graphics:srGraphics2d, direction:amVector2d, size:Number = 5 ):void
		{
			var pnt:amPoint2d = this.clone();
			var vec:amVector2d = direction.normal.negate().scaleBy(size).rotateBy(RAD_45);
			pnt.translateBy(vec);
			graphics.moveTo(_x, _y);
			graphics.lineTo(pnt.x, pnt.y);
			pnt.copy(this);
			vec.rotateBy( -RAD_90);
			pnt.translateBy(vec);
			graphics.moveTo(_x, _y);
			graphics.lineTo(pnt.x, pnt.y);
		}
		
		public override function toString():String
			{  return "[amPoint2d(" + _x.toFixed(amSettings.tracePrecision) + ", " + _y.toFixed(amSettings.tracePrecision) + ")]";  }
			
		public static function tracePoints(points:Vector.<amPoint2d>):void
		{
			var string:String = "{";
			for ( var i:int = 0; i < points.length; i++ )
			{
				string += points[i].toString() + (i < points.length - 1 ? ", " : "");
			}
			string += "}";
			
			trace(string);
		}
	}
}