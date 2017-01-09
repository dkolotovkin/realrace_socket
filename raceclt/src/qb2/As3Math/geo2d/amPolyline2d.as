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
	import flash.display.Graphics;
	import qb2.As3Math.geo2d.amPoint2d;
	import qb2.surrender.srGraphics2d;
	
	import qb2.As3Math.am_friend;
	use namespace am_friend;

	public class amPolyline2d extends amCurve2d
	{
		private const verts:Vector.<amPoint2d> = new Vector.<amPoint2d>();
		private const lines:Vector.<amLine2d>  = new Vector.<amLine2d>();
		
		private var _length:Number;

		public function amPolyline2d(vertices:Vector.<amPoint2d> = null)
			{  set(vertices);  }

		public function set(vertices:Vector.<amPoint2d>):amPolyline2d
		{
			verts.length = 0;
			
			if ( !vertices )
			{
				update(true);
				return this;
			}
		
			for ( var i:int = 0; i < vertices.length; i++ )
				verts.push(vertices[i]);
				
			update(true);
			
			return this;
		}
		
		public function setByClone(vertices:Vector.<amPoint2d>):amPolyline2d
		{
			var newVerts:Vector.<amPoint2d> = new Vector.<amPoint2d>(vertices.length, true);
			for ( var i:int = 0; i < vertices.length; i++ )
				newVerts[i] = vertices[i].clone();
			
			return set(newVerts);
		}
		
		public function asLines():Vector.<amLine2d>
		{
			var toReturn:Vector.<amLine2d> = new Vector.<amLine2d>(lines.length, true);
			for ( var i:int = 0; i < lines.length; i++ )
				toReturn.push(lines[i].clone());
			return toReturn;
		}
		
		public function asPoints():Vector.<amPoint2d>
		{
			var toReturn:Vector.<amPoint2d> = new Vector.<amPoint2d>(verts.length, true);
			for ( var i:int = 0; i < verts.length; i++ )
				toReturn.push(verts[i].clone());
			return toReturn;
		}
		
		public function getLineAt(index:uint):amLine2d
			{  return lines[index].clone() as amLine2d;  }
		
		public function addVertex(vertex:amPoint2d):amPolyline2d
			{  verts.push(vertex);  update(true);  return this;  }
			
		public function getVertexAt(index:uint):amPoint2d
			{  return verts[index].clone();  }
		
		public function setVertexAt(index:uint, point:amPoint2d):amPolyline2d
			{  verts[index] = point;  update(true);  return this;  }
			
		public function insertVertexAt(index:uint, point:amPoint2d):amPolyline2d
			{  verts.splice(index, 0, point);  update(true);  return this;  }
		
		public function removeVertex(vertex:amPoint2d):amPoint2d
			{  return removeVertexAt(verts.indexOf(vertex));  }
		
		public function removeVertexAt(index:uint):amPoint2d
		{
			var vertex:amPoint2d = verts.splice(index, 1)[0];
			update(true);
			return vertex;
		}
		
		public function removeAllVertices():Vector.<amPoint2d>
		{
			var toReturn:Vector.<amPoint2d> = verts.splice(0, verts.length);
			update(true);
			return toReturn;
		}
		
		public function get numVertices():uint
			{  return verts.length;  }
			
		public function get numSegments():uint
			{  return lines.length;  }
			
		private function update(updateLines:Boolean):void
		{
			_length = 0;
			if( updateLines )  lines.length = 0;
			for ( var i:int = 0; i < verts.length - 1; i++ )
			{
				if( updateLines )  lines.push(new amLine2d(verts[i], verts[i + 1]));
				_length += verts[i].distanceTo(verts[i + 1]);
			}
		}
		
		
			
		public override function copy(otherEntity:amEntity2d):amEntity2d
		{
			if ( otherEntity is amPolyline2d )
			{
				var otherPoly:amPolyline2d = otherEntity as amPolyline2d;
				setByClone(otherPoly.verts);
			}
			return this;
		}
		
		public override function clone():amEntity2d
			{  return new amPolyline2d(this.asPoints());  }
		
		public override function scaleBy(xValue:Number, yValue:Number, origin:amPoint2d = null):amEntity2d
		{
			for ( var i:int = 0; i < verts.length; i++ )
				verts[i].scaleBy(xValue, yValue, origin);
			update(false);
			return this;
		}
		
		public override function rotateBy(radians:Number, origin:amPoint2d = null):amEntity2d
		{
			for ( var i:int = 0; i < verts.length; i++ )
				verts[i].rotateBy(radians, origin);
			return this;
		}
		
		public override function translateBy(vector:amVector2d):amEntity2d
		{
			for ( var i:int = 0; i < verts.length; i++ )
				verts[i].translateBy(vector);
			return this;
		}
		
		public override function transformBy(matrix:amMatrix2d):amEntity2d
		{
			for ( var i:int = 0; i < verts.length; i++ )
				verts[i].transformBy(matrix);
			update(false);
			return this;
		}
		
		public override function mirror(across:amLine2d):amEntity2d
		{
			for ( var i:int = 0; i < verts.length; i++ )
				verts[i].mirror(across);
			return this;
		}
		
		public override function equals(otherEntity:amEntity2d, tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean
		{
			if ( otherEntity is amPolyline2d )
			{
				var otherPoly:amPolyline2d = otherEntity as amPolyline2d;
				if ( otherPoly.numVertices != this.numVertices )  return false;
				
				for ( var i:int = 0; i < verts.length; i++ )
				{
					if ( !this.verts[i].equals(otherPoly.verts[i], tolerance, pointEqualityMode) )
					{
						return false;
					}
				}
			}
			
			return true;
		}
		
		public override function isOn(point:amPoint2d, tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean
		{
			for ( var i:int = 0; i < lines.length; i++ )
			{
				if ( lines[i].isOn(point, tolerance, pointEqualityMode) )
					return true;
			}
			
			return false;
		}
		
		
		
		public override function getStartPoint():amPoint2d
			{  return verts.length ? verts[0].clone() : null}
		
		public override function getEndPoint():amPoint2d
			{  return verts.length ? verts[verts.length-1].clone() : null;  }
		
		public override function distanceToPoint(point:amPoint2d):Number
		{
			var lowestDist:Number = Infinity;
			for ( var i:int = 0; i < lines.length; i++ )
			{
				var distance:Number = lines[i].distanceToPoint(point);
				if ( distance < lowestDist )
					lowestDist = distance;
			}
			return lowestDist;
		}
		
		public override function closestPointTo(point:amPoint2d):amPoint2d
		{
			var lowestDist:Number = Infinity;
			var lowestIndex:int = -1;
			for ( var i:int = 0; i < lines.length; i++ )
			{
				var distance:Number = lines[i].distanceToPoint(point);
				if ( distance < lowestDist )
				{
					lowestIndex = i;
					lowestDist = distance;
				}
			}
			return lines[lowestIndex].closestPointTo(point);
		}
		
		public override function getPointAtDist(distanceAlongCurve:Number):amPoint2d
		{
			var distLeft:Number = distanceAlongCurve;
			for( var i:int = 0; i < lines.length; i++ )
			{
				if( distLeft <= lines[i].length )
				{
					return lines[i].getPointAtDist(distLeft);
				}
				distLeft -= lines[i].length;
			}
			
			return lines[lines.length - 1].getPointAtDist(lines[lines.length - 1].length + distLeft);
		}
		
		public override function getDistAtPoint(pointOnCurve:amPoint2d):Number
		{
			var segIndex:int = closestSegmentTo(pointOnCurve);
			if ( segIndex == -1 )   return NaN;

			var dist:Number = lines[segIndex].getDistAtPoint(pointOnCurve);
			
			for( var i:int = 0; i < segIndex; i++ )
				dist += lines[i].length;
			return dist;
		}
		
		public override function getSubcurve(pointOrDistStart:Object, pointOrDistFinish:Object):amCurve2d
		{
			var toReturn:amPolyline2d;
			var point1:amPoint2d = new amPoint2d(), point2:amPoint2d = new amPoint2d();
			if ( getSubcurveHelper(pointOrDistStart, pointOrDistFinish, point1, point2) )
			{
				var index1:int = this.closestSegmentTo(point1);
				var index2:int = this.closestSegmentTo(point2);
				if ( index1 >= 0 && index2 >= 0 )
				{
					if ( index1 == index2 )
					{
						return lines[index1].getSubcurve(pointOrDistStart, pointOrDistFinish);
					}
					else if( index1 < index2 )
					{
						toReturn = new amPolyline2d();
						toReturn.addVertex(point1);
						for( var i:int = index1; i < index2; i++ )
						{
							toReturn.addVertex(lines[i].point2.clone());
						}
						toReturn.addVertex(point2);
						
						var startLine:amLine2d = lines[index1];
						var endLine:amLine2d   = lines[index2];
					}
				}
			}
			return toReturn;
		}
		
		public override function flip():amCurve2d
		{
			verts.reverse();  lines.reverse();
			for ( var i:int = 0; i < lines.length; i++ )
				lines[i].flip();
			return this;
		}
		
		public override function get boundBox():amBoundBox2d
		{
			var box:amBoundBox2d = new amBoundBox2d();
			if ( !verts.length )  return box;
		
			box.set(verts[i].clone(), verts[i].clone());
			for ( var i:int = 1; i < verts.length; i++ )
			{
				box.expandToPoint(verts[i]);
			}
			return box;
		}
		
		public override function isLinear(outputLine:amLine2d = null, radianTolerance:Number = 0):Boolean
		{
			for ( var i:int = 0; i < lines.length-1; i++ )
			{
				if ( !lines[i].isColinearTo(lines[i + 1], radianTolerance) )
					return false;
			}
			
			if ( outputLine )  outputLine.set(verts[0], verts[verts.length - 1], amLine2d.LINE_TYPE_SEGMENT);
			return true;
		}
		
		public override function get area():Number { return 0; }
		
		public override function get length():Number
			{  return _length;  }
		
	
		
		public function closestSegmentTo(point:amPoint2d):int
		{
			var lowestDist:Number = Infinity;
			var lowestIndex:int = -1;
			for ( var i:int = 0; i < lines.length; i++ )
			{
				var distance:Number = lines[i].distanceToPoint(point);
				if ( distance < lowestDist )
				{
					lowestIndex = i;
					lowestDist = distance;
				}
			}
			return lowestIndex;
		}
		
		public override function selfIntersects(outputPoints:Vector.<amPoint2d> = null, stopAtFirstPointFound:Boolean = true, distanceTolerance:Number = 0, radianTolerance:Number = 0):Boolean
		{
			var intersecting:Boolean = false;
			for( var i:int = 0; i < lines.length; i++ )
			{
				for( var j:int = i+1; j < lines.length; j++ )
				{
					var outputPoint:amPoint2d = outputPoints ? new amPoint2d() : null;
					if ( lines[i].intersectsLine(lines[j], outputPoint, distanceTolerance, radianTolerance) )
					{
						if ( outputPoints )  outputPoints.push(outputPoint);
						intersecting = true;
						
						if ( stopAtFirstPointFound )  return true;
					}
				}
			}
			
			return intersecting;
		}

		//--- Draws this polyline to the given graphics object.
		public function draw(graphics:srGraphics2d, vertexRadius:Number = 5 ):void
		{
			if ( verts.length == 1)
			{
				verts[0].draw(graphics, vertexRadius);
				return;
			}
			
			for ( var i:int = 0; i < lines.length; i++ )
				lines[i].draw(graphics, vertexRadius);
		}
		
		public function drawAsQuadraticSpline(graphics:Graphics, startNormal:amVector2d, proportionality:Number = .5, drawKnots:Boolean = false, vertexRadius:Number = 0):void
		{			
			if ( verts.length < 2 )  return;
			
			graphics.moveTo(verts[0].x, verts[0].y);
			var lastNormal:amVector2d = startNormal.normal;
			for (var i:int = 1; i < verts.length; i++) 
			{
				var startAnchor:amPoint2d = verts[i - 1];
				var endAnchor:amPoint2d = verts[i];
				var control:amPoint2d = startAnchor.translatedBy(lastNormal.scaleBy(endAnchor.distanceTo(startAnchor) * proportionality));
				graphics.curveTo(control.x, control.y, endAnchor.x, endAnchor.y);
				
				if ( i < verts.length - 1 )  lastNormal = endAnchor.minus(control).normal;
			}
		}
		
		public function drawAsCubicSpline(graphics:Graphics, knots:Vector.<amVector2d>, drawKnots:Boolean = false, vertexRadius:Number = 0):void
		{
			
		}

		public override function toString():String
		{
			var retString:String = "[amPolyline2d(";
			for ( var i:int = 0; i < lines.length; i++ )
			{
				retString = retString.concat(" " + verts[i].toString());
				if ( i < lines.length - 1 )  retString = retString.concat(", ");
			}
			retString = retString.concat(" )]");
			return retString;
		}
	}
}