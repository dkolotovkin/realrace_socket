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
	import qb2.As3Math.general.amGraphics;
	import qb2.As3Math.general.amSettings;
	import qb2.As3Math.general.amEntity;
	import qb2.As3Math.general.amUpdateEvent;
	import qb2.As3Math.misc.am_intersectionFlags;
	import flash.display.Graphics;
	import qb2.surrender.srGraphics2d;
	
	import qb2.As3Math.am_friend;
	use namespace am_friend;
	
	public class amPolygon2d extends amEntity2d
	{
		am_friend const verts:Vector.<amPoint2d> = new Vector.<amPoint2d>();
		am_friend const intersections:Vector.<geInternalPolygonIntersection> = new Vector.<geInternalPolygonIntersection>();
		am_friend const normals:Vector.<amVector2d> = new Vector.<amVector2d>();
		
		private var _inertia:Number = 0;
		private var _area:Number = 0;
		private var _perimeter:Number = 0;
		am_friend const _centerOfMass:amPoint2d = new amPoint2d();
		private var _convex:Boolean = false;
		
		private var generalPropsValidated:Boolean = false;
		private var intersectionsValidated:Boolean = false;
		private var centroidValidated:Boolean = false;
		private var normalsValidated:Boolean = false;
		
		private var freezeCallbacks:Boolean = false;
		
		public function amPolygon2d(vertices:Vector.<amPoint2d> = null) 
			{  set(vertices);  }
			
		public function get convex():Boolean
		{
			validateGeneralProps();
			return _convex;
		}
		
		public function get isCounterClockwise():Boolean
		{
			validateGeneralProps();
			return _area > 0;
		}
			
		public function get perimeter():Number
		{
			validateGeneralProps();
			return _perimeter;
		}
		
		public function get area():Number
		{
			validateGeneralProps();
			return Math.abs(_area);
		}
		
		public function get centerOfMass():amPoint2d
		{
			validateCentroid();
			return _centerOfMass.clone();
		}
		
		public function get inertia():Number
		{
			validateCentroid();
			return _inertia;
		}
		
		public function get selfIntersects():Boolean
		{
			validateIntersections();
			return intersections.length >= 1;
		}

		public function get numSelfIntersections():uint
		{
			validateIntersections();
			return intersections.length;
		}
			
		public function getSelfIntersectionAt(index:uint):amPoint2d
		{
			validateIntersections();
			return intersections[index].point.clone();
		}
		
		public function getNormalAt(index:uint):amVector2d
		{
			validateNormals();
			return normals[index].clone();
		}

		public function set(vertices:Vector.<amPoint2d>):amPolygon2d
		{
			freezeCallbacks = true;
			{
				//--- Can't call removeAllVertices here because sendCallbacks() would get called twice.
				for ( var i:int = 0; i < verts.length; i++ )
					removeVertexAt(i--);

				if ( vertices )
				{
					for ( i = 0; i < vertices.length; i++ )
						addVertex(vertices[i]);
				}
			}
			freezeCallbacks = false;
			
			invalidate();
			sendCallbacks();
			
			return this;
		}
		
		private function sendCallbacks():void
		{
			if ( freezeCallbacks )  return;
		
			var evt:amUpdateEvent = CACHED_UPDATE_EVENT.inUse ? new amUpdateEvent() : CACHED_UPDATE_EVENT;
			evt.type = amUpdateEvent.ENTITY_UPDATED;
			dispatchEvent(evt);
		}
		
		private function pointUpdated(evt:amUpdateEvent):void
		{
			invalidate();
			sendCallbacks();
		}		
		
		public function setByClone(vertices:Vector.<amPoint2d>):amPolygon2d
		{
			var newVerts:Vector.<amPoint2d> = new Vector.<amPoint2d>(vertices.length, true);
			for ( var i:int = 0; i < vertices.length; i++ )
				newVerts[i] = vertices[i].clone();
			
			return set(newVerts);
		}
		
		
		
		public function asPoints():Vector.<amPoint2d>
		{
			var toReturn:Vector.<amPoint2d> = new Vector.<amPoint2d>(verts.length, true);
			for ( var i:int = 0; i < verts.length; i++ )
				toReturn[i] = verts[i].clone();
			return toReturn;
		}
		
		public function asLines():Vector.<amLine2d>
		{
			var toReturn:Vector.<amLine2d> = new Vector.<amLine2d>(verts.length, true);
			for ( var i:int = 0; i < verts.length; i++ )
			{
				var ith:amPoint2d = verts[i];
				var next:amPoint2d = (i + 1) < verts.length ? verts[i + 1] : verts[0];
				toReturn[i] = new amLine2d(ith.clone(), next.clone());
			}
			return toReturn;
		}
		
		public function asPolyline(closed:Boolean = true):amPolyline2d
		{
			var polyline:amPolyline2d = new amPolyline2d(asPoints());
			if ( closed )  polyline.addVertex(verts[0].clone());
			return polyline;
		}
		
		
		
		public override function copy(otherEntity:amEntity2d):amEntity2d
		{
			if ( otherEntity is amPolygon2d )
			{
				var otherPoly:amPolygon2d = otherEntity as amPolygon2d;
				setByClone(otherPoly.verts);
			}
			return this;
		}
		
		public override function clone():amEntity2d
			{  return new amPolygon2d(this.asPoints());  }
			
		public override function get boundBox():amBoundBox2d
		{
			var box:amBoundBox2d = new amBoundBox2d();
			if ( !verts.length )  return box;
		
			box.set(verts[0].clone(), verts[0].clone());
			for ( var i:int = 1; i < verts.length; i++ )
			{
				box.expandToPoint(verts[i]);
			}
			return box;
		}
		
		public function setAsRect(centerPnt:amPoint2d, width:Number, height:Number, angleInRadians:Number = 0):amPolygon2d
		{
			var newVerts:Vector.<amPoint2d> = new Vector.<amPoint2d>(4, true);
			newVerts[0] = new amPoint2d(centerPnt.x - width / 2, centerPnt.y - height / 2);
			newVerts[1] = new amPoint2d(centerPnt.x + width / 2, centerPnt.y - height / 2);
			newVerts[2] = new amPoint2d(centerPnt.x + width / 2, centerPnt.y + height / 2);
			newVerts[3] = new amPoint2d(centerPnt.x - width / 2, centerPnt.y + height / 2);
			set(newVerts);
			rotateBy(angleInRadians, centerPnt);
			return this;
		}
		
		public override function scaleBy(xValue:Number, yValue:Number, origin:amPoint2d = null):amEntity2d
		{
			freezeCallbacks = true;
			{
				for ( var i:int = 0; i < verts.length; i++ )
					verts[i].scaleBy(xValue, yValue, origin);  // this calls pointUpdated, which in turn calls update()...that's why update is frozen.
			}
			freezeCallbacks = false;
			
			_centerOfMass.scaleBy(xValue, yValue, origin);
			
			for ( i = 0; i < intersections.length; i++ )
				intersections[i].point.scaleBy(xValue, yValue, origin);
			
			generalPropsValidated = false;  // this function invalidates perimeter and area.
			sendCallbacks();
			
			return this;
		}
		
		public override function rotateBy(radians:Number, origin:amPoint2d = null):amEntity2d
		{
			freezeCallbacks = true;
			{
				for ( var i:int = 0; i < verts.length; i++ )
					verts[i].rotateBy(radians, origin);
			}
			freezeCallbacks = false;
			
			_centerOfMass.rotateBy(radians, origin);
			
			for ( i = 0; i < intersections.length; i++ )
				intersections[i].point.rotateBy(radians, origin);
			
			normalsValidated = false; // rotating messes up normals
			sendCallbacks();
			
			return this;
		}
		
		public override function translateBy(vector:amVector2d):amEntity2d
		{
			freezeCallbacks = true;
			{
				for ( var i:int = 0; i < verts.length; i++ )
					verts[i].translateBy(vector);
			}
			freezeCallbacks = false;
		
			_centerOfMass.translateBy(vector);
			
			for ( i = 0; i < intersections.length; i++ )
				intersections[i].point.translateBy(vector);
			
			sendCallbacks();
			
			return this;
		}
		
		public override function transformBy(matrix:amMatrix2d):amEntity2d
		{
			freezeCallbacks = true;
			{
				for ( var i:int = 0; i < verts.length; i++ )
					verts[i].transformBy(matrix);
			}
			freezeCallbacks = false;
			
			_centerOfMass.transformBy(matrix);
			
			for ( i = 0; i < intersections.length; i++ )
				intersections[i].point.transformBy(matrix);
			
			generalPropsValidated = false;
			normalsValidated = false;
			sendCallbacks();
			
			return this;
		}
		
		public override function mirror(across:amLine2d):amEntity2d
		{
			freezeCallbacks = true;
			{
				for ( var i:int = 0; i < verts.length; i++ )
					verts[i].mirror(across);
			}
			freezeCallbacks = false;
		
			_centerOfMass.mirror(across);
			
			for ( i = 0; i < intersections.length; i++ )
				intersections[i].point.mirror(across);
			
			generalPropsValidated = false;
			normalsValidated = false;
			sendCallbacks();
			
			return this;
		}
		
		public function reverseVertices():amPolygon2d
		{
			verts.reverse();
			
			//--- Reverse the indeces of intersection in the array...this is obviously much quicker than invalidating all the intersections.
			for ( var i:int = 0; i < intersections.length; i++ )
			{
				intersections[i].index1 = (verts.length - 1) - intersections[i].index1;
				intersections[i].index2 = (verts.length - 1) - intersections[i].index2;
			}
			
			generalPropsValidated = false;
			normalsValidated = false;
			sendCallbacks();
			
			return this;
		}
		
		public function addVertex(... oneOrMoreVertices):amPolygon2d
		{
			for ( var i:int = 0; i < oneOrMoreVertices.length; i++ )
			{
				verts.push(oneOrMoreVertices[i] as amPoint2d);
				(oneOrMoreVertices[i] as amPoint2d).addEventListener(amUpdateEvent.ENTITY_UPDATED, pointUpdated);
			}
			
			invalidate();
			sendCallbacks();
			
			return this;
		}

		public function getVertexAt(index:uint):amPoint2d
			{  return verts[index];  }
			
		public function getEdgeAt(index:uint):amLine2d
			{  return new amLine2d(verts[index].clone(), (index + 1) < verts.length ? verts[index + 1].clone() : verts[0].clone());  }
		
		public function setVertexAt(index:uint, point:amPoint2d):amPolygon2d
		{
			freezeCallbacks = true;
				removeVertexAt(index);
			freezeCallbacks = false;
			
			return insertVertexAt(index, point);  // calls sendCallbacks()
		}
			
		public function insertVertexAt(index:uint, point:amPoint2d):amPolygon2d
		{
			point.addEventListener(amUpdateEvent.ENTITY_UPDATED, pointUpdated);
			verts.splice(index, 0, point);
			
			invalidate();
			sendCallbacks();
			
			return this;
		}
		
		public function removeVertex(vertex:amPoint2d):amPolygon2d
			{  removeVertexAt(verts.indexOf(vertex));  return this}
		
		public function removeVertexAt(index:uint):amPoint2d
		{
			var vertex:amPoint2d = verts.splice(index, 1)[0];
			vertex.removeEventListener(amUpdateEvent.ENTITY_UPDATED, pointUpdated);
			
			invalidate();
			sendCallbacks();
			
			return vertex;
		}
			
		public function removeAllVertices():Vector.<amPoint2d>
		{
			var toReturn:Vector.<amPoint2d> = new Vector.<amPoint2d>();
			
			freezeCallbacks = true;
			{
				for ( var i:int = 0; i < verts.length; i++ )
					toReturn.push(removeVertexAt(i--));
			}
			freezeCallbacks = false;
			
			invalidate();
			sendCallbacks();
			
			return toReturn;
		}
		
		public function get numVertices():uint
			{  return verts.length;  }	
		
		private function invalidate():void
		{
			generalPropsValidated = false;
			intersectionsValidated = false;
			centroidValidated = false;
			normalsValidated = false;
		}
		
		private function validateNormals():void
		{
			normals.length = 0;
			
			for (var i:int = 0; i < verts.length; i++)
			{
				var ithPnt:amPoint2d = verts[i];
				var nextPnt:amPoint2d = verts[ i == verts.length - 1 ? 0 : i + 1];
				normals.push( nextPnt.minus(ithPnt).normalize());
			}
			
			normalsValidated = true;
		}
		
		private function validateCentroid():void
		{
			if ( centroidValidated )  return;

			const k_inv3:Number = 1.0 / 3.0;
			var numVerts:uint = verts.length;
			_centerOfMass.set();
			_inertia = 0;
			var totalArea:Number = 0;
			
			for (var i:int = 0; i < numVerts; i++)
			{
				var ithPnt:amPoint2d = verts[i];
				var nextPnt:amPoint2d = (i + 1) < numVerts ? verts[i + 1] : verts[0];
				
				var D:Number = ithPnt.x * nextPnt.y - ithPnt.y * nextPnt.x;
	
				var triangleArea:Number = 0.5 * D;
				totalArea += triangleArea;
				
				_centerOfMass.x += triangleArea * k_inv3 * (ithPnt.x + nextPnt.x);
				_centerOfMass.y += triangleArea * k_inv3 * (ithPnt.y + nextPnt.y);
				
				var px:Number = 0;
				var py:Number = 0;
				var ex1:Number = ithPnt.x/30;
				var ey1:Number = ithPnt.y/30;
				var ex2:Number = nextPnt.x / 30;
				var ey2:Number = nextPnt.y/30;
				
				var intx2:Number = k_inv3 * (0.25 * (ex1*ex1 + ex2*ex1 + ex2*ex2) + (px*ex1 + px*ex2)) + 0.5*px*px;
				var inty2:Number = k_inv3 * (0.25 * (ey1*ey1 + ey2*ey1 + ey2*ey2) + (py*ey1 + py*ey2)) + 0.5*py*py;
				
				var modD:Number = ex1 * ey2 - ey1 * ex2;
				_inertia += modD * (intx2 + inty2);
			}
			
			if ( totalArea )
			{
				_centerOfMass.x *= 1.0 / totalArea;
				_centerOfMass.y *= 1.0 / totalArea;
			}
			else
			{
				_centerOfMass.set();
			}
			
			centroidValidated = true;
		}

		private function validateGeneralProps():void
		{
			if ( generalPropsValidated )  return;
		
			_area = _perimeter = 0;
			var isConvex:Boolean = true, isPositive:Boolean = false;
			const k_inv3:Number = 1.0 / 3.0;
			var numVerts:uint = verts.length;
			
			for (var i:int = 0; i < numVerts; i++)
			{
				var prevPnt:amPoint2d = i == 0 ? verts[numVerts - 1] : verts[i - 1];
				var ithPnt:amPoint2d = verts[i];
				var nextPnt:amPoint2d = (i + 1) < numVerts ? verts[i + 1] : verts[0];
				
				//--- Determine if polygon remains convex at the i-th corner.
				if ( isConvex )
				{
					var vec1:amVector2d = ithPnt.minus(prevPnt);
					var vec2:amVector2d = nextPnt.minus(ithPnt);
					var cross:Number = vec1.x * vec2.y - vec2.x * vec1.y;
					var subIsPositive:Boolean = cross > 0;
					if (i == 0)
						isPositive = subIsPositive;
					else if (isPositive != subIsPositive)
						isConvex = false;
				}
				
				var D:Number = ithPnt.x * nextPnt.y - ithPnt.y * nextPnt.x;
	
				var triangleArea:Number = 0.5 * D;
				_area += triangleArea;
				
				_perimeter += ithPnt.distanceTo(nextPnt);
			}
			
			if ( verts.length >= 3 )
				_convex = isConvex;
			else
				_convex = false;
			
			generalPropsValidated = true;
		}
		
		private function validateIntersections():void
		{
			if ( intersectionsValidated )  return;
			
			const iLine:amLine2d = new amLine2d(), jLine:amLine2d = new amLine2d();
		
			intersections.length = 0;
			for ( var i:int = 0; i < verts.length; i++)
			{
				var ith:amPoint2d = verts[i];
				var iNext:amPoint2d = (i + 1) < verts.length ? verts[i + 1] : verts[0];
				iLine.setByCopy(ith, iNext);
				// Test against not the next line, but 2 lines after...it's impossible for adjacent lines to intersect.
				var cap:int = i == 0 ? verts.length - 1 : verts.length; // don't want to compare first and last lines.
				for ( var j:int = i+2; j < cap; j++)
				{
					var jth:amPoint2d = verts[j];
					var jNext:amPoint2d = (j + 1) < verts.length ? verts[j + 1] : verts[0];
					jLine.setByCopy(jth, jNext);
					
					var intPoint:amPoint2d = new amPoint2d();
					
					if ( iLine.intersectsLine(jLine, intPoint) )
					{
						intersections.push(new geInternalPolygonIntersection(intPoint, i, j));
					}
				}
			}
			
			intersectionsValidated = true;
		}
		
		private static var utilLine:amLine2d = new amLine2d();
		private static var utilPoint:amPoint2d = new amPoint2d();
		
		public function intersectsLine(line:amLine2d, outputPoints:Vector.<amPoint2d>, intersectionTolerance:Number = 0, distanceToPointTolerance:Number = 0):Boolean
		{
			var numVerts:int = verts.length;
			for (var j:uint = 0; j < numVerts; j++) 
			{
				var edgeBeg:amPoint2d = verts[j];
				var edgeEnd:amPoint2d = verts[(j + 1) % numVerts];
				utilLine.set(edgeBeg, edgeEnd);
				
				if ( line.intersectsLine(utilLine, utilPoint, intersectionTolerance) )
				{
					if ( !outputPoints )
					{
						return true;
					}
					
					var newIntPoint:amPoint2d = utilPoint.clone();
					outputPoints.push(newIntPoint);
					
					newIntPoint.userData = am_intersectionFlags.CURVE_TO_CURVE;
					var intIndex:uint = j;
					
					//--- Determine if the slice line goes through a vertex or the "meat" of an edge.
					if ( newIntPoint.distanceTo(edgeBeg) < distanceToPointTolerance )
					{
						newIntPoint.userData |= am_intersectionFlags.CURVE_TO_POINT;
					}
					else if ( newIntPoint.distanceTo(edgeEnd) < distanceToPointTolerance )
					{
						newIntPoint.userData |= am_intersectionFlags.CURVE_TO_POINT;
						intIndex = ++j;
					}
					
					newIntPoint.userData |= intIndex << 16;
				}
			}
			
			return outputPoints && outputPoints.length;
		}
		
		public override function equals(otherEntity:amEntity2d, tolerance:Number = 0, pointEqualityMode:uint = AM_EQUALITY_DISTANCE_TO):Boolean
		{
			if ( otherEntity is amPolygon2d )
			{
				var otherPoly:amPolygon2d = otherEntity as amPolygon2d;
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
			/*var tVec:b2Vec2;
		
			//b2Vec2 pLocal = b2MulT(xf.R, p - xf.position);
			var tMat:b2Mat22 = xf.R;
			var tX:Number = p.x - xf.position.x;
			var tY:Number = p.y - xf.position.y;
			var pLocalX:Number = (tX*tMat.col1.x + tY*tMat.col1.y);
			var pLocalY:Number = (tX*tMat.col2.x + tY*tMat.col2.y);*/
			
			for (var i:int = 0; i < verts.length; ++i)
			{
				var ithPnt:amPoint2d = verts[i];
				var tX:Number = point.x - ithPnt.x;
				var tY:Number = point.y - ithPnt.y;
				var ithNormal:amVector2d = getNormalAt(i);
				var dot:Number = (-ithNormal.x * tX + -ithNormal.y * tY);
				if ( dot > 0.0 )
				{
					return false;
				}
				
				/*tVec = m_vertices[i];
				tX = pLocalX - tVec.x;
				tY = pLocalY - tVec.y;
				tVec = m_normals[i];
				var dot:Number = (tVec.x * tX + tVec.y * tY);
				if (dot > 0.0)
				{
					return false;
				}*/
			}
			
			return true;
		}
		
		public function draw(graphics:Graphics, vertexRadius:Number = 0 ):void
		{
			if ( !verts.length )  return;
			
			graphics.moveTo(verts[0].x, verts[0].y);
			for ( var i:int = 1; i < verts.length; i++ )
			{
				graphics.lineTo(verts[i].x, verts[i].y);
			}
			graphics.lineTo(verts[0].x, verts[0].y);
		}
		
		public function drawAsSpline(graphics:srGraphics2d, vertexRadius:Number = 0 ):void
		{
			if ( !verts.length )  return;
			
			amGraphics.drawClosedCubicSpline(graphics, verts, false);
		}
		
		private static const splineRatio:Number = .5;
		
		public override function toString():String
		{
			var retString:String = "[amPolygon2d( [numVerts=" + numVertices + "], [area=" + area + "], [counterclockwise=" + isCounterClockwise + "], [convex=" + _convex + "], [selfIntersects=" + selfIntersects + "],\n       ";
			for ( var i:int = 0; i < verts.length; i++ )
			{
				retString = retString.concat(" " + verts[i].toString());
				if ( i < verts.length - 1 )  retString = retString.concat(",");
			}
			retString = retString.concat(" )]");
			return retString;
		}
	}
}

import qb2.As3Math.geo2d.amPoint2d;

final internal class geInternalPolygonIntersection
{
	public var point:amPoint2d;
	public var index1:uint, index2:uint;
	
	public function geInternalPolygonIntersection(initPoint:amPoint2d, initIndex1:uint, initIndex2:uint):void
	{
		point = initPoint;
		index1 = initIndex1;
		index2 = initIndex2;
	}
}