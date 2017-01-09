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
	import qb2.As3Math.consts.AM_EQUALITY_DISTANCE_TO;
	import qb2.As3Math.general.amSettings;
	import qb2.As3Math.general.amUtils;
	import qb2.As3Math.misc.am_intersectionFlags;
	import flash.display.Graphics;
	import qb2.surrender.srGraphics2d;

	public class amLine2d extends amCurve2d
	{
		public static const LINE_TYPE_SEGMENT:uint  = 1;
		public static const LINE_TYPE_INFINITE:uint = 2;
		public static const LINE_TYPE_RAY:uint      = 3;
		
		public var lineType:uint = LINE_TYPE_SEGMENT;

		public var point1:amPoint2d = null;
		public var point2:amPoint2d = null;

		public function amLine2d( initPoint1:amPoint2d = null, initPoint2:amPoint2d = null, type:uint = LINE_TYPE_SEGMENT)
			{  set(initPoint1 ? initPoint1 : new amPoint2d(), initPoint2 ? initPoint2 : new amPoint2d(), type);  }
			
		public static function newFromVec(initBase:amPoint2d, initVector:amVector2d, type:uint = LINE_TYPE_SEGMENT):amLine2d
		{
			var base:amPoint2d = amUtils.fixPoint(initBase);
			return new amLine2d(base, base.translatedBy(initVector), type);
		}

		public function set(newPoint1:amPoint2d, newPoint2:amPoint2d, type:uint = LINE_TYPE_SEGMENT):void
			{  point1 = newPoint1;  point2 = newPoint2;  lineType = type;  }
			
		public function setByCopy(newPoint1:amPoint2d, newPoint2:amPoint2d, type:uint = LINE_TYPE_SEGMENT):void
			{  point1.copy(newPoint1);  point2.copy(newPoint2);  lineType = type;  }
			
		public function asVector():amVector2d
			{  return point2.minus(point1);  }
			
		public function get direction():amVector2d
			{  return asVector().normalize();  }
			
			
			
		public override function copy(otherEntity:amEntity2d):amEntity2d
		{
			if ( otherEntity is amLine2d )
			{
				var otherLine:amLine2d = otherEntity as amLine2d;
				this.point1.copy(otherLine.point1);
				this.point2.copy(otherLine.point2);
				this.lineType = otherLine.lineType;
			}
			return this;
		}
		
		public override function clone():amEntity2d
			{  return new amLine2d(point1.clone(), point2.clone(), lineType);  }
			
		public override function scaleBy(xValue:Number, yValue:Number, origin:amPoint2d = null):amEntity2d
		{
			point1.scaleBy(xValue, yValue, origin);  point2.scaleBy(xValue, yValue, origin);
			return this;
		}
		
		public override function rotateBy(radians:Number, origin:amPoint2d = null):amEntity2d
		{
			point1.rotateBy(radians, origin);  point2.rotateBy(radians, origin);
			return this;
		}
		
		public override function translateBy(vector:amVector2d):amEntity2d
		{
			point1.translateBy(vector);  point2.translateBy(vector);
			return this;
		}
		
		public override function transformBy(matrix:amMatrix2d):amEntity2d
		{
			point1.transformBy(matrix);  point2.transformBy(matrix);
			return this;
		}
		
		public override function mirror(across:amLine2d):amEntity2d
		{
			point1.mirror(across);  point2.mirror(across);
			return this;
		}
		
		public override function equals(otherEntity:amEntity2d, tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean
		{
			if (otherEntity is amLine2d)
			{
				var otherLine:amLine2d = otherEntity as amLine2d;
				return this.lineType == otherLine.lineType && this.point1.equals(otherLine.point1, tolerance, pointEqualityMode) && this.point2.equals(otherLine.point2, tolerance, pointEqualityMode);
			}
			return false;
		}
		
		public override function isOn(point:amPoint2d, tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean
		{
			var distanceToInfinite:Number = distanceToInfiniteLine(point);
	
			if ( lineType == LINE_TYPE_SEGMENT || lineType == LINE_TYPE_RAY )
			{
				if ( point1.equals(point, tolerance, pointEqualityMode) )                                  return true;
				if( lineType == LINE_TYPE_SEGMENT && point2.equals(point, tolerance, pointEqualityMode) )  return true;
			}
			
			return distanceToPoint(point) <= tolerance;
		}
		
		
		
		public override function getStartPoint():amPoint2d
		{
			if ( lineType == LINE_TYPE_RAY || lineType == LINE_TYPE_SEGMENT )
				return point1.clone();
			return null;
		}
		
		public override function getEndPoint():amPoint2d
		{
			if ( lineType == LINE_TYPE_SEGMENT )
				return point2.clone();
			return null;
		}
		
		public override function distanceToCurve(curve:amCurve2d):Number
		{
			if ( curve is amLine2d )
			{
				var asLine:amLine2d = curve as amLine2d;
				
				return -1;
			}
			else
			{
				return -1;
			}
		}
		
		public override function distanceToPoint(point:amPoint2d):Number
		{
			var point1Dist:Number = point1.distanceTo(point);
			var endDist:Number = point2.distanceTo(point);
			var linDist:Number = distanceToInfiniteLine(point);
			var point1ToPoint:amVector2d = point.minus(point1);
			var endToPoint:amVector2d = point.minus(point2);
			var lineVec:amVector2d = asVector();
			
			if ( lineType == LINE_TYPE_SEGMENT )
			{
				if ( lineVec.angleTo(point1ToPoint) <= Math.PI / 2 && lineVec.negate().angleTo(endToPoint) <= Math.PI / 2 )
					return linDist;
				else return Math.min(point1Dist, endDist);
			}
			else if ( lineType == LINE_TYPE_RAY )
			{
				if ( lineVec.angleTo(point1ToPoint) <= Math.PI / 2 )
					return linDist;
				else return point1Dist;
			}
			else if ( lineType == LINE_TYPE_INFINITE )
				return linDist;
				
			return NaN;
		}
		
		public override function closestPointTo(point:amPoint2d):amPoint2d
		{
			var point1Dist:Number = point1.distanceTo(point);
			var angleBtwn:Number = asVector().angleTo(point.minus(point1));
			
			if ( lineType == LINE_TYPE_SEGMENT )
			{
				if ( angleBtwn <= Math.PI / 2 )
				{
					var distanceAlong:Number = Math.cos(angleBtwn) * point1Dist;
					return distanceAlong > length ? point2.clone() : getPointAtDist(distanceAlong);
				}
				else return point1.clone();
			}
			else if ( lineType == LINE_TYPE_RAY )
			{
				if ( angleBtwn <= Math.PI / 2 )
				{
					distanceAlong = Math.cos(angleBtwn) * point1Dist;
					return getPointAtDist(distanceAlong);
				}
				else return point1.clone();
			}
			else if ( lineType == LINE_TYPE_INFINITE )
			{
				if ( angleBtwn <= Math.PI / 2 )
					distanceAlong = Math.cos(angleBtwn) * point1Dist;
				else
					distanceAlong = -Math.cos(Math.PI-angleBtwn)*point1Dist
				return getPointAtDist(distanceAlong);
			}
			return null;
		}
		
		//--- Returns a point on the line at a given distance from the point1inning.
		public override function getPointAtDist(distance:Number):amPoint2d
		{			
			return point1.clone().translateBy(this.direction.scaleBy(distance));
		}
		
		public override function getDistAtPoint(pointOnCurve:amPoint2d):Number
		{
			if ( lineType == LINE_TYPE_INFINITE )  return Infinity;
			
			var point1Dist:Number = point1.distanceTo(pointOnCurve);
			var angleBtwn:Number = asVector().angleTo(pointOnCurve.minus(point1));
			var distanceAlong:Number = 0;
			if ( angleBtwn <= Math.PI / 2 )
				distanceAlong = Math.cos(angleBtwn) * point1Dist;
			else
				distanceAlong = -Math.cos(Math.PI-angleBtwn)*point1Dist
			
			return distanceAlong;
		}
		
		public override function getSubcurve(pointOrDistStart:Object, pointOrDistFinish:Object):amCurve2d
		{
			if ( lineType == LINE_TYPE_INFINITE && ( (pointOrDistStart is Number) || (pointOrDistFinish is Number) ) )  return null;
		
			var toReturn:amLine2d;
			var point1:amPoint2d = new amPoint2d(), point2:amPoint2d = new amPoint2d();
			if ( getSubcurveHelper(pointOrDistStart, pointOrDistFinish, point1, point2) )
			{
				toReturn = new amLine2d(point1, point2, LINE_TYPE_SEGMENT);
			}
			return toReturn;
		}
		
		public override function flip():amCurve2d
		{
			var temp:amPoint2d = point1;
			point1 = point2;
			point2 = temp;
			return this;
		}
		
		public override function get boundBox():amBoundBox2d
		{
			var box:amBoundBox2d = new amBoundBox2d();
			box.set(point1, point1);
			return box.expandToPoint(point2) as amBoundBox2d;
		}
		
		public override function splitAtPoints(splitPoints:Vector.<amPoint2d>, fixedVector:Boolean = true):Vector.<amCurve2d>
		{
			var toReturn:Vector.<amCurve2d> = Vector.<amCurve2d>(splitPoints.length + 1, fixedVector);
			
			var closestPoint:amPoint2d = closestPointTo(splitPoints[0]);
			if ( lineType == LINE_TYPE_INFINITE )
				toReturn[0] = new amLine2d(closestPoint, closestPoint.clone().translateBy(this.direction.negate()), LINE_TYPE_RAY);
			else if ( lineType == LINE_TYPE_RAY || lineType == LINE_TYPE_SEGMENT )
				toReturn[0] = new amLine2d(point1, closestPoint, LINE_TYPE_SEGMENT);
			
			for ( var i:int = 0; i < splitPoints.length-1; i++ )
			{
				toReturn[i + 1] = getSubcurve(splitPoints[i], splitPoints[i + 1]);
			}
			
			closestPoint = closestPointTo(splitPoints[splitPoints.length - 1]);
			if ( lineType == LINE_TYPE_INFINITE || lineType == LINE_TYPE_RAY )
				toReturn[toReturn.length-1] = new amLine2d(closestPoint, closestPoint.clone().translateBy(this.direction), LINE_TYPE_RAY);
			else if ( lineType == LINE_TYPE_SEGMENT )
				toReturn[toReturn.length-1] = new amLine2d(closestPoint, point2, LINE_TYPE_SEGMENT);
			
			return toReturn;
		}
		
		public override function splitAtDists(distances:Vector.<Number>, fixedVector:Boolean = true):Vector.<amCurve2d>
		{
			if ( lineType == LINE_TYPE_INFINITE ) return new Vector.<amCurve2d>(0, fixedVector);
			return super.splitAtDists(distances, fixedVector);
		}
		
		public override function splitAtDist(distance:Number, fixedVector:Boolean = true):Vector.<amCurve2d>
		{
			if ( lineType == LINE_TYPE_INFINITE ) return new Vector.<amCurve2d>(0, fixedVector);
			return super.splitAtDist(distance, fixedVector);
		}
		
		public override function isLinear(outputLine:amLine2d = null, radianTolerance:Number = 0):Boolean
		{
			if ( outputLine )  outputLine.copy(this);
			return true;
		}
		
		public override function get area():Number
			{ return 0; }
		
		public override function get length():Number
			{  return lineType == LINE_TYPE_SEGMENT ? point1.distanceTo(point2) : Infinity;  }
		
			
			
		public function set length(value:Number):void
		{
			var vec:amVector2d = asVector();
			vec.length = value;
			point2.copy(point1).translateBy(vec);
		}
			
		/** Treats the line as infinite no matter what type it is, and returns the distance to the given point.
		 */
		public function distanceToInfiniteLine(point:amPoint2d):Number
		{
			var hyp:Number = point.distanceTo(this.point1);
			var theta:Number = point.minus(point1).angleTo(this.direction);
			theta = theta > Math.PI / 2 ? Math.PI - theta : theta;
			var toReturn:Number = Math.sin(theta) * hyp;
			return isNaN(toReturn) ? 0 : toReturn;
		}
		
		/** Determines if two lines intersect. Overlapping lines return false.
		 * @param otherLine The other line to check against.
		 * @param outputIntPoint Optional output for the intersection point. If non-null, intPnt's x and y will be modified by the function if the function returns true, otherwise it will be unmodified.
		 * @param distanceTolerance The distance, for example, that the end point of one line segment can be from another line segment and still return true for intersection.
		 * @param radianTolerance In the case of two infinite lines, this is the tolerance that determines whether they are parallel.  If they are not parallel, they intersect.
		 * @return Whether or not there is intersection between the two lines.
		 */
		public function intersectsLine( otherLine:amLine2d, outputIntPoint:amPoint2d = null, intersectionTolerance:Number = 0, radianTolerance:Number = 0 ):Boolean
		{
			var pair:Object = intersectionHelper(otherLine);
			if ( pair )
			{
				var intersecting:Boolean = false;
				
				if ( lineType == LINE_TYPE_SEGMENT && otherLine.lineType == LINE_TYPE_SEGMENT && amUtils.isWithin(pair.ua, 0, 1, intersectionTolerance) && amUtils.isWithin(pair.ub, 0, 1, intersectionTolerance) )
					intersecting = true;
				else if ( lineType == LINE_TYPE_RAY && otherLine.lineType == LINE_TYPE_SEGMENT && pair.ua >= 0-intersectionTolerance && amUtils.isWithin(pair.ub, 0, 1, intersectionTolerance) )
					intersecting = true;
				else if ( lineType == LINE_TYPE_SEGMENT && otherLine.lineType == LINE_TYPE_RAY && amUtils.isWithin(pair.ua, 0, 1, intersectionTolerance) && pair.ub >= 0-intersectionTolerance )
					intersecting = true;
				else if ( lineType == LINE_TYPE_RAY && otherLine.lineType == LINE_TYPE_RAY && pair.ua >= 0-intersectionTolerance && pair.ub >= 0-intersectionTolerance )
					intersecting = true;
				else if ( lineType == LINE_TYPE_SEGMENT && otherLine.lineType == LINE_TYPE_INFINITE && amUtils.isWithin(pair.ua, 0, 1, intersectionTolerance) )
					intersecting = true;
				else if ( lineType == LINE_TYPE_INFINITE && otherLine.lineType == LINE_TYPE_SEGMENT && amUtils.isWithin(pair.ub, 0, 1, intersectionTolerance) )
					intersecting = true;
				else if ( lineType == LINE_TYPE_RAY && otherLine.lineType == LINE_TYPE_INFINITE && pair.ua >= 0-intersectionTolerance )
					intersecting = true;
				else if ( lineType == LINE_TYPE_INFINITE && otherLine.lineType == LINE_TYPE_RAY && pair.ub >= 0-intersectionTolerance )
					intersecting = true;
				else if ( lineType == LINE_TYPE_INFINITE && otherLine.lineType == LINE_TYPE_INFINITE && !this.isParallelTo(otherLine, radianTolerance) )
					intersecting = true;
				
				if ( intersecting )
				{
					if ( outputIntPoint )  outputIntPoint.set(this.point1.x + pair.ua * (this.point2.x - this.point1.x), this.point1.y + pair.ua * (this.point2.y - this.point1.y));
					return true;
				}	
			}
			return false;
		}
		
		public function intersectsCircle(circle:amCircle2d, outputPoints:Vector.<amPoint2d>, intersectionTolerance:Number):Boolean
		{
			var lineDir:amVector2d = this.direction;
			var lineOrigin:amPoint2d = this.midpoint;
			
			var data:Object = linetoCircleIntersectionHelper(lineOrigin, lineDir, circle.center, circle.radius, intersectionTolerance);
			var numIntPoints:int = data.rootCount;
			var intersects:Boolean = numIntPoints > 0 ;
			var t:Array = data.t;
			
			if ( intersects && outputPoints)
			{
				if ( lineType == LINE_TYPE_INFINITE )
				{
					// nothing to do here.
				}
				else if ( lineType == LINE_TYPE_RAY )
				{
					if (numIntPoints == 1)
					{
						if (t[0] < 0.0 )
						{
							numIntPoints = 0;
						}
					}
					else
					{
						if (t[1] < 0.0 )
						{
							numIntPoints = 0;
						}
						else if (t[0] < 0.0 )
						{
							numIntPoints = 1;
							t[0] = t[1];
						}
					}
				}
				else if ( lineType == LINE_TYPE_SEGMENT )
				{
					var extent:Number = this.length / 2;
					
					if (numIntPoints == 1)
					{
						if (Math.abs(t[0]) > extent )
						{
							numIntPoints = 0;
						}
					}
					else
					{
						if (t[1] < -extent || t[0] > extent )
						{
							numIntPoints = 0;
						}
						else
						{
							if (t[1] <= extent )
							{
								if (t[0] < -extent )
								{
									numIntPoints = 1;
									t[0] = t[1];
								}
							}
							else
							{
								numIntPoints = (t[0] >= -extent ? 1 : 0);
							}
						}
					}
				}
				
				for (var i:int = 0; i < numIntPoints; i++)
				{
					var point:amPoint2d = lineOrigin.translatedBy(lineDir.scaledBy(t[i]));
					point.userData = am_intersectionFlags.CURVE_TO_CURVE;
					outputPoints.push(point )
				}
			}
			
			return intersects;
		}
		
		private function linetoCircleIntersectionHelper(lineOrigin:amPoint2d, lineDir:amVector2d, circleCenter:amPoint2d, circleRadius:Number, tol:Number):Object
		{
			var diff:amVector2d = lineOrigin.minus(circleCenter);
			var a0:Number = diff.lengthSquared - circleRadius * circleRadius;
			var a1:Number = lineDir.dotProduct(diff);
			var discr:Number = a1 * a1 - a0;
			
			var returnObj:Object = { };
			if ( discr > tol )
			{
				returnObj.rootCount = 2;
				discr = Math.sqrt(discr);
				returnObj.t = [ -a1 - discr, -a1 + discr];
			}
			else if ( discr < -tol )
			{
				returnObj.rootCount = 0;
			}
			else
			{
				returnObj.rootCount = 1;
				returnObj.t = [ -a1];
			}
			
			return returnObj;
			
			/*template <typename Real>
			bool IntrLine2Circle2<Real>::Find (const Vector2<Real>& origin,
				const Vector2<Real>& direction, const Vector2<Real>& center,
				Real radius, int& rootCount, Real t[2])
			{
				// Intersection of a the line P+t*D and the circle |X-C| = R.  The line
				// direction is unit length. The t value is a root to the quadratic
				// equation:
				//   0 = |t*D+P-C|^2 - R^2
				//     = t^2 + 2*Dot(D,P-C)*t + |P-C|^2-R^2
				//     = t^2 + 2*a1*t + a0
				// If two roots are returned, the order is T[0] < T[1].

				Vector2<Real> diff = origin - center;
				Real a0 = diff.SquaredLength() - radius*radius;
				Real a1 = direction.Dot(diff);
				Real discr = a1*a1 - a0;
				if (discr > Math<Real>::ZERO_TOLERANCE)
				{
					rootCount = 2;
					discr = Math<Real>::Sqrt(discr);
					t[0] = -a1 - discr;
					t[1] = -a1 + discr;
				}
				else if (discr < -Math<Real>::ZERO_TOLERANCE)
				{
					rootCount = 0;
				}
				else  // discr == 0
				{
					rootCount = 1;
					t[0] = -a1;
				}

				return rootCount != 0;
			}*/
		}
		
		private function intersectionHelper(otherLine:amLine2d):Object
		{
			var denom:Number  = ((otherLine.point2.y - otherLine.point1.y)*(point2.x - point1.x)) -
                     			((otherLine.point2.x - otherLine.point1.x)*(point2.y - point1.y));

			var nume_a:Number = ((otherLine.point2.x - otherLine.point1.x)*(point1.y - otherLine.point1.y)) -
						   		((otherLine.point2.y - otherLine.point1.y)*(point1.x - otherLine.point1.x));
	
			var nume_b:Number = ((point2.x - point1.x)*(point1.y - otherLine.point1.y)) -
						   		((point2.y - point1.y)*(point1.x - otherLine.point1.x));
	
			if( denom == 0.0)
			{
				if( nume_a == 0.0 && nume_b == 0.0 )
					return { nume_a:nume_a, nume_b:nume_b }; // (coincident)
				return { nume_a:nume_a, nume_b:nume_b };     // (parallel)
			}
			else if ( isFinite(denom) )
			{
				var ua:Number = nume_a / denom;
				var ub:Number = nume_b / denom;
			}
			else
			{
				ua = ub = 0.0;
			}
			
			return { nume_a:nume_a, nume_b:nume_b, ua:ua, ub:ub };
		}
		
		public function isParallelTo(otherLine:amLine2d, radianTolerance:Number = 0):Boolean
			{  return direction.isParallelTo(otherLine.direction, radianTolerance);  }
			
		public function isPerpendicularTo(otherLine:amLine2d, radianTolerance:Number = 0):Boolean
			{  return direction.isPerpendicularTo(otherLine.direction, radianTolerance);  }
			
		public function isCodirectionalTo(otherline:amLine2d, radianTolerance:Number = 0):Boolean
			{  return direction.isCodirectionalTo(otherline.direction, radianTolerance);  }
	
		public function isAntidirectionalTo(otherline:amLine2d, radianTolerance:Number = 0):Boolean
			{  return direction.isAntidirectionalTo(otherline.direction, radianTolerance);  }
		
		/** Determines if the two lines lie on the same imaginary infinite line.  This function doesn't care about overlap.
		 * @param otherLine The other line to test against.
		 * @param radianTolerance The angular discrepancy that's allowed between the lines.
		 * @param isOnTolerance The distance the two lines can be apart. Specifically, how far this line's point1 point can be from an imaginary infinite line passing through otherLine.
		 * @param requireCodirectionality If true, the lines also have to be pointing in the same direction.
		 * @return Whether or not the lines are colinear.
		 */
		public function isColinearTo(otherLine:amLine2d, radianTolerance:Number = 0, isOnTolerance:Number = 0, requireCodirectionality:Boolean = false):Boolean
		{
			if ( requireCodirectionality )
			{
				if ( !isCodirectionalTo(otherLine, radianTolerance) )  return false;
			}
			else
			{
				if ( !isParallelTo(otherLine, radianTolerance) )  return false;
			}
	
			return otherLine.distanceToInfiniteLine(point1) <= isOnTolerance;
		}
		
		/** Determines if this and otherLine are colinear and overlap each other. This is determined differently depending on the lineType's involved. For example, if both lines are segments,
		 * then one line must have one of its endpoints on the other.  However if both lines are infinite, then the only condition to be satisfied is colinearity.
		 * @param otherLine The other line to test against.
		 * @param radianTolerance The angular discrepancy that's allowed between the lines.
		 * @param isOnTolerance The distance the two lines can be apart. Specifically, how far this line's point1 point can be from an imaginary infinite line passing through otherLine.
		 * @param outputLine Optional output for the overlap found, if any. If non-null, outputLine is set with to the line representing the overlap. If no overlap is found, this line remains unchanged.
		 * Note that the outputLine's lineType can vary depending on the two lineType's tested.  Also, if the lineType of outputLine is set to either LINE_TYPE_INFINITE or LINE_TYPE_RAY, then the line's distance from point1 to point2 is set to 1.
		 * @return Whether or not the two lines overlap.
		 */		 
		public function isOverlappedBy(otherLine:amLine2d, radianTolerance:Number = 0, isOnTolerance:Number = 0, outputLine:amLine2d = null):Boolean
		{
			if ( !isColinearTo(otherLine, radianTolerance, isOnTolerance, false) )  return false;
			
			var tempLine:amLine2d;
			
			if ( this.lineType == LINE_TYPE_SEGMENT && otherLine.lineType == LINE_TYPE_SEGMENT )
			{
				if ( otherLine.isOn(this.point1, isOnTolerance) )
				{
					if ( otherLine.isOn(this.point2, isOnTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(this.point1, this.point2, LINE_TYPE_SEGMENT);
						}
						return true;
					}
					
					if ( this.isCodirectionalTo(otherLine, radianTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(this.point1, otherLine.point2, LINE_TYPE_SEGMENT);
						}
						return true;
					}
					else
					{
						if ( outputLine )
						{
							outputLine.set(this.point1, otherLine.point1, LINE_TYPE_SEGMENT);
						}
						return true;
					}
				}
				else if ( otherLine.isOn(this.point2, isOnTolerance) )
				{
					if ( this.isCodirectionalTo(otherLine, radianTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(otherLine.point1, this.point2, LINE_TYPE_SEGMENT);
						}
						return true;
					}
					else
					{
						if ( outputLine )
						{
							outputLine.set(this.point2, otherLine.point2, LINE_TYPE_SEGMENT);
						}
						return true;
					}
				}
				else if ( this.isOn(otherLine.point1, isOnTolerance) )
				{
					if ( outputLine )
					{
						outputLine.set(otherLine.point1, otherLine.point2, LINE_TYPE_SEGMENT);
					}
					return true;
				}
			}
			if ( this.lineType == LINE_TYPE_INFINITE && otherLine.lineType == LINE_TYPE_INFINITE )
			{
				if ( outputLine )
				{
					outputLine.set(point1, point2, LINE_TYPE_INFINITE);
					outputLine.length = 1;
				}
				return true;
			}
			if ( this.lineType == LINE_TYPE_RAY && otherLine.lineType == LINE_TYPE_RAY )
			{
				if ( this.isCodirectionalTo(otherLine, radianTolerance) )
				{
					if ( otherLine.isOn(this.point1, isOnTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(point1, point2, LINE_TYPE_RAY);
							outputLine.length = 1;
						}
						return true;
					}
					if ( this.isOn(otherLine.point1, isOnTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(otherLine.point1, otherLine.point2, LINE_TYPE_RAY);
							outputLine.length = 1;
						}
						return true;
					}
				}
				else
				{
					if ( otherLine.isOn(this.point1, isOnTolerance) )
					{
						if ( outputLine )
						{
							outputLine.set(this.point1, otherLine.point1, LINE_TYPE_SEGMENT);
						}
						return true;
					}
				}
			}
			if ( this.lineType == LINE_TYPE_INFINITE && otherLine.lineType == LINE_TYPE_RAY || this.lineType == LINE_TYPE_RAY && otherLine.lineType == LINE_TYPE_INFINITE )
			{
				tempLine = this.lineType == LINE_TYPE_RAY ? this : otherLine;
				
				if ( outputLine )
				{
					outputLine.set(tempLine.point1, tempLine.point2, LINE_TYPE_RAY);
					outputLine.length = 1;
				}
				return true;
			}
			if ( this.lineType == LINE_TYPE_INFINITE && otherLine.lineType == LINE_TYPE_SEGMENT || this.lineType == LINE_TYPE_SEGMENT && otherLine.lineType == LINE_TYPE_INFINITE )
			{
				tempLine = this.lineType == LINE_TYPE_SEGMENT ? this : otherLine;
				
				if ( outputLine )
				{
					outputLine.set(tempLine.point1, tempLine.point2, LINE_TYPE_SEGMENT);
				}
				return true;
			}
			if ( this.lineType == LINE_TYPE_RAY && otherLine.lineType == LINE_TYPE_SEGMENT || this.lineType == LINE_TYPE_SEGMENT && otherLine.lineType == LINE_TYPE_RAY )
			{
				var ray:amLine2d = this.lineType == LINE_TYPE_RAY ? this : otherLine;
				var seg:amLine2d = this.lineType == LINE_TYPE_SEGMENT ? this : otherLine;
				
				if ( ray.isOn(seg.point1, isOnTolerance) )
				{
					if ( ray.isOn(seg.point2, isOnTolerance) )
					{
						if ( outputLine )
						{
							outputLine.copy(seg);
						}
					}
					else
					{
						if ( outputLine )
						{
							outputLine.set(ray.point1, seg.point1, LINE_TYPE_SEGMENT);
						}
					}
					
					return true;
				}
				else if ( ray.isOn(seg.point2, isOnTolerance) )
				{
					if ( outputLine )
					{
						outputLine.set(ray.point1, seg.point2, LINE_TYPE_SEGMENT);
					}
					return true;
				}
			}
			
			return false;
		}

		public function get midpoint():amPoint2d
			{  return point1.clone().translateBy(point2.minus(point1).scaleBy(.5));  }
		
		//--- Assuming that you have two lines, with the first's end point overlapping the second's point1 point,
		//--- this function finds the line that would split the angle between them. Think of it as if the two lines
		//--- represent pipes of 'diam' diameter. The returned line represents the "elbow joint" between the two pipes.
		public function bisector(other:amLine2d, diam:Number, limit:Number):amLine2d
		{
			//--- Determine the angle between two lines using some simple trigonometry.
			var a:Number = this.point1.distanceTo(other.point2),
				b:Number = this.length,
				c:Number = other.length,
				val:Number = .5 * ( (a * a - b * b - c * c) / (b * c) );
			if ( val > 1 )
				val = 1;
			else if ( val < -1 )
				val = -1;
				
			var alpha:Number = Math.PI - Math.acos(val);
			var finalDiam:Number = diam / Math.sin(alpha / 2.0);
			if ( finalDiam > limit)
				finalDiam = limit;
			
			var backPoint:amPoint2d  = this.point2.translatedBy(this.direction.scaleBy(.1).negate()),
				frontPoint:amPoint2d = this.point2.translatedBy(other.direction.scaleBy(.1));
			var normal:amVector2d    = (frontPoint.minus(backPoint));
			normal.normalize();

			var cross:amVector2d = normal.perpVector();
			cross.scaleBy(finalDiam / 2);
			var pnt1:amPoint2d = this.point2.clone();
			pnt1.translateBy(cross);
			
			cross.negate();
			var pnt2:amPoint2d = this.point2.clone();
			pnt2.translateBy(cross);
			
			return new amLine2d(pnt1, pnt2);
		}

		//--- Draws this line to the given graphics object.
		public function draw(graphics:srGraphics2d, endPointSize:Number = 0 ):void
		{
			if ( endPointSize )
			{
				if ( lineType == LINE_TYPE_SEGMENT )
				{
					point1.draw(graphics, endPointSize);
					point2.draw(graphics, endPointSize);
				}
				else if ( lineType == LINE_TYPE_RAY )
				{
					point1.draw(graphics, endPointSize);
					point2.drawAsArrow(graphics, direction, endPointSize);
				}
				else if ( lineType == LINE_TYPE_INFINITE )
				{
					point1.drawAsArrow(graphics, direction.negate(), endPointSize);
					point2.drawAsArrow(graphics, direction, endPointSize);
				}
			}
			
			var drawBeg:amPoint2d, drawEnd:amPoint2d;
			if ( lineType == LINE_TYPE_SEGMENT )
			{
				drawBeg = point1;  drawEnd = point2;
			}
			else if ( lineType == LINE_TYPE_RAY )
			{
				drawBeg = point1;  drawEnd = point2.translatedBy(direction.scaleBy(amSettings.INFINITE_FOR_DRAWING));
			}
			else if ( lineType == LINE_TYPE_INFINITE )
			{
				drawBeg = point1.translatedBy(direction.scaleBy(-amSettings.INFINITE_FOR_DRAWING));  drawEnd = point2.translatedBy(direction.scaleBy(amSettings.INFINITE_FOR_DRAWING));;
			}
			
			if ( drawBeg )
			{
				graphics.moveTo(drawBeg.x, drawBeg.y);
				graphics.lineTo(drawEnd.x, drawEnd.y);
			}
		}

		public override function toString():String
		{
			var typeString:String = lineType == LINE_TYPE_INFINITE ? "infinite" : lineType == LINE_TYPE_RAY ? "ray" : "segment";
			return "[amLine2d( " + point1.toString() + ", " + point2.toString() + ", type:" + typeString + " )]";
		}
	}
}