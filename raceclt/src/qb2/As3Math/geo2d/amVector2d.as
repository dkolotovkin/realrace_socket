/**
 * Copyright (c) 2010 Johnson Center for Simulation at Pine Technical College
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * in the Software without restriction, including without limitation the rights
 * of this software and associated documentation files (the "Software"), to deal
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
	import qb2.As3Math.consts.AM_EQUALITY_ANGLE_TO;
	import qb2.As3Math.consts.AM_EQUALITY_DISTANCE_TO;
	import qb2.As3Math.consts.AM_EQUALITY_MANHATTAN_TO;
	import qb2.As3Math.general.amSettings;
	import qb2.As3Math.general.amUtils;
	import qb2.As3Math.general.amEntity;
	import qb2.As3Math.general.amUpdateEvent;
	import flash.display.Graphics;
	import qb2.surrender.srGraphics2d;
	
	import qb2.As3Math.am_friend;
	use namespace am_friend;

	public final class amVector2d extends amEntity
	{
		public var userData:* = null;
		
		am_friend var _x:Number, _y:Number;
		
		public static const xVec:amVector2d     = new amVector2d(1, 0);
		public static const yVec:amVector2d     = new amVector2d(0, 1);
		public static const reusable:amVector2d = new amVector2d(0, 0);

		public function amVector2d( initX:Number = 0, initY:Number = 0 ):void
			{  set(initX, initY);  }
			
		public static function newVector(initX:Number = 0, initY:Number = 0):amVector2d
			{  return new amVector2d(initX, initY)  }
			
		//--- Returns a vector rotated from the base vector.
		public static function newRotVector(baseX:Number, baseY:Number, radians:Number):amVector2d
		{
			var newVec:amVector2d = new amVector2d(baseX, baseY);
			newVec.rotateBy(radians);
			return newVec;
		}
		
		public static function newXVec():amVector2d
			{  return xVec.clone();  }
			
		public static function newYVec():amVector2d
			{  return yVec.clone();  }
			
		private function sendCallbacks():void
		{
			var evt:amUpdateEvent = CACHED_UPDATE_EVENT.inUse ? new amUpdateEvent() : CACHED_UPDATE_EVENT;
			evt.type = amUpdateEvent.ENTITY_UPDATED;
			evt._entity = this;
			dispatchEvent(evt);
		}
		
		public function set( newX:Number = 0, newY:Number = 0 ):amVector2d
			{  _x = newX;  _y = newY;  sendCallbacks();  return this;  }
			
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
		
		public function copy(otherVector:amVector2d):amVector2d
		{
			if ( otherVector )
			{
				_x = otherVector._x;  _y = otherVector._y;
			}
			else
			{
				_x = 0;  _y = 0;
			}
			
			sendCallbacks();
			return this;
		}
			
		public function clone():amVector2d
			{  return new amVector2d(_x, _y);  }
			
		public function asPoint():amPoint2d
			{  return new amPoint2d(_x, _y);  }
		
		
		public function zeroOut():amVector2d
			{  _x = _y = 0;  sendCallbacks();  return this;  }
			
		public function isZeroLength(tolerance:Number = 0):Boolean
			{  return amUtils.equals(length, 0, tolerance);  }

		public function get normal():amVector2d
			{  var mag:Number = this.length;  return new amVector2d(_x / mag, _y / mag);  }

		public function normalize():amVector2d
		{
			var mag:Number = this.length;
			if ( mag )
			{
				_x /= mag;  _y /= mag;
				sendCallbacks();
			}
		
			return this;
		}

		public function dotProduct(otherVector:amVector2d):Number
			{  return _x * otherVector._x + _y * otherVector._y;  }

		public function perpVector(direction:int = 1):amVector2d  // (returns a vector perpendicular to this one)
			{  return this.clone().setToPerpVector(direction);  }
			
		public function setToPerpVector(direction:int = 1):amVector2d
		{
			//--- Because in flash and many other 2d graphics rendering systems the y-axis is flipped, flip the direction internally.
			direction = -direction;
			
			var tempX:Number = _x;
			var tempY:Number = _y;
			
			if ( direction >= 0 )
			{
				_y = -tempX;
				_x = tempY;
			}
			else
			{
				_y = tempX;
				_x = -tempY;
			}
			
			sendCallbacks();
			return this;
		}

		public function equals(otherVector:amVector2d, tolerance:Number = 0, equalityMode:uint = AM_EQUALITY_ANGLE_TO):Boolean
		{
			if ( tolerance == 0 )
			{
				return _x == otherVector._x && _y == otherVector._y;
			}
			else if ( equalityMode == AM_EQUALITY_MANHATTAN_TO )
			{
				return amUtils.equals(_x, otherVector._x, tolerance) && amUtils.equals(_y, otherVector._y, tolerance);
			}
			else if ( equalityMode == AM_EQUALITY_DISTANCE_TO )
			{
				return this.asPoint().equals(otherVector.asPoint(), tolerance, AM_EQUALITY_DISTANCE_TO);
			}
			else if ( equalityMode == AM_EQUALITY_ANGLE_TO )
			{
				return this.angleTo(otherVector) <= tolerance;
			}
			return false;
		}
		
		public function isNaNVec():Boolean
			{  return isNaN(_x) || isNaN(_y);  }
			
		public function isUnitLength(tolerance:Number = 0):Boolean
		{  return amUtils.equals(1, this.length, tolerance);  }

		public function isCodirectionalTo(otherVector:amVector2d, radianTolerance:Number = 0):Boolean
			{  return this.angleTo(otherVector) <= radianTolerance;  }

		public function isAntidirectionalTo(otherVector:amVector2d, radianTolerance:Number = 0):Boolean
			{  return this.angleTo(otherVector) >= Math.PI - radianTolerance;  }
			
		public function isParallelTo(otherVector:amVector2d, radianTolerance:Number = 0):Boolean
		{
			var angle:Number = this.angleTo(otherVector);
			return angle <= radianTolerance || angle >= Math.PI - radianTolerance;
		}
		
		public function isPerpendicularTo(otherVector:amVector2d, radianTolerance:Number = 0):Boolean
			{  return amUtils.equals(this.angleTo(otherVector), Math.PI / 2, radianTolerance);  }

		// normal must be unit length vector
		public function mirror(acrossNormal:amVector2d):amVector2d
		{
			var dot:Number = -_x * acrossNormal._x - _y * acrossNormal._y;
			_x = _x + 2 * acrossNormal._x * dot;
			_y = _y + 2 * acrossNormal._y * dot;
			return negate();
		}
		
		public function mirrored(acrossNormal:amVector2d):amVector2d
			{  return this.clone().mirror(acrossNormal);  }

		public function negate():amVector2d
			{  _x *= -1;  _y *= -1;  sendCallbacks();  return this;  }
			
		public function square():amVector2d
			{  scaleBy(length);  return this;  }
			
		public function squared():amVector2d
			{  return this.clone().square();  }

		public function negated():amVector2d
			{  return this.clone().negate();  }

		public function scaleBy(value:Number):amVector2d
			{  _x *= value;  _y *= value;  sendCallbacks();  return this;  }

		public function scaledBy(value:Number):amVector2d
			{  return this.clone().scaleBy(value);  }
			
		public function transformBy(matrix:amMatrix2d):amVector2d
		{
			sendCallbacks();
			return this;
		}
		
		public function transformedBy(matrix:amMatrix2d):amVector2d
			{  return this.clone().transformBy(matrix);  }
			
		public function rotateBy(radians:Number):amVector2d
		{
			var xOld:Number = _x, yOld:Number = _y;
			const sinRad:Number = Math.sin(radians);
			const cosRad:Number = Math.cos(radians);
			_x = xOld * cosRad - yOld * sinRad;
			_y = xOld * sinRad + yOld * cosRad;
			sendCallbacks();
			return this;
		}
		public function rotatedBy(angle:Number):amVector2d
			{  return this.clone().rotateBy(angle);  }

		public function signedAngleTo(otherVector:amVector2d):Number
		{
			var clockwise:Number = clockwiseAngleTo(otherVector);
			return clockwise > Math.PI ? -(Math.PI * 2 - clockwise) : clockwise;
		}
		
		public function angleTo(otherVector:amVector2d):Number
		{
			var a:Number = this.length,
				b:Number = otherVector.length,
				c:Number = this.minus(otherVector).length;
			var value:Number = (a*a + b*b - c*c) / (2*a*b);

			//--- If the value is out of the range of {-1, 1}, then
			//--- there was a round-off error, so just correct it.
			if( value < -1 )
				value = -1;
			else if( value > 1 )
				value = 1;

			return Math.acos( value );
		}
		
		public function clockwiseAngleTo(otherVector:amVector2d):Number
		{
			//--- Get the angle between the two vectors.
			var angleBetween:Number = angleTo(otherVector);
			
			//--- Get the angle of this vector to the noon vector (0, -1).
			var angleToNoon:Number = angleTo(amVector2d.yVec.negated());
			if( _x > 0 )  angleToNoon = -angleToNoon;

			//--- Clone the input vector and rotate by the angle to noon.
			var otherVectorCopy:amVector2d = otherVector.clone();
			otherVectorCopy.rotateBy(angleToNoon);
			
			if( otherVectorCopy.x < 0 )
				angleBetween = Math.PI + (Math.PI - angleBetween);
			return angleBetween == Math.PI * 2 ? 0 : angleBetween;
		}
			
		public function plus(otherVector:amVector2d):amVector2d
			{  return new amVector2d(_x + otherVector._x, _y + otherVector._y);  }
		
		public function minus(otherVector:amVector2d):amVector2d
			{  return new amVector2d(_x - otherVector._x, _y - otherVector._y);  }
			
		public function add(otherVector:amVector2d):amVector2d  // (returns this + otherVector)
		{
			_x += otherVector._x;  _y += otherVector._y;
			sendCallbacks();
			return this;
		}
		
		public function subtract(otherVector:amVector2d):amVector2d  // (returns this + otherVector)
		{
			_x -= otherVector._x;  _y -= otherVector._y;
			sendCallbacks();
			return this;
		}
		
		public function get length():Number
			{  return Math.sqrt(_x*_x + _y*_y);  }
		public function set length(value:Number):void
		{
			//normalize() is not used so that sendCallbacks is not called twice.
			var mag:Number = this.length;
			if ( mag )
			{
				_x /= mag;  _y /= mag;
			}
			scaleBy(value);  // calls sendCallbacks()
		}
		
		public function setLength(value:Number):amVector2d
		{
			this.length = value;
			return this;
		}
		
		public function get lengthSquared():Number
			{  return _x * _x + _y * _y;  }

		/** Returns the clockwise rotation in radians of this vector with respect to the *negative* y-axis, i.e. (0, -1).
		 * This axis is chosen as opposed to the more common (0, 1) because it corresponds to the default "up vector" of most display objects.
		 */
		public function get angle():Number
		{
			if( _x >= 0 )
				return angleTo(new amVector2d(0, -1));
			else
				return Math.PI + (Math.PI - angleTo(new amVector2d(0, -1)));
		}
		
		public function draw(graphics:srGraphics2d, base:amPoint2d, baseRadius:Number = 0, arrowSize:Number = 5, scale:Number = 1, makeBaseTheEndOfTheVector:Boolean = false ):void
		{
			var beg:amPoint2d, end:amPoint2d;
			var vec:amVector2d = scale == 1 ? this : this.scaledBy(scale);
			if ( makeBaseTheEndOfTheVector )
			{
				beg = base.translatedBy(vec.negated());
				end = base;
			}
			else
			{
				beg = base;
				end = base.translatedBy(vec);
			}
			
			graphics.moveTo(beg.x, beg.y);  graphics.lineTo(end.x, end.y);
			beg.draw(graphics, baseRadius);
			end.drawAsArrow(graphics, this, arrowSize);
		}
		
		public override function toString():String
			{  return "[amVector2d(" + _x.toFixed(amSettings.tracePrecision) + ", " + _y.toFixed(amSettings.tracePrecision) + ")]";  }
	}
}