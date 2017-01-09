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

package qb2.As3Math.general
{
	import qb2.As3Math.consts.*;
	import qb2.As3Math.geo2d.*;
	import flash.display.*;
	import qb2.surrender.srGraphics2d;
	
	public class amGraphics
	{
		private static var closedSplineRatio:Number = .41414141414141;
		private static const refVec:amVector2d = new amVector2d(0, -1);
		
		public static function drawCubicSpline(graphics:srGraphics2d, startTangent:amVector2d, endTangent:amVector2d, points:Vector.<amPoint2d>, doMoveTo:Boolean = true):void
		{
			if( doMoveTo )  graphics.moveTo(points[0].x, points[0].y);
			
			var lineWidth:Number = .1;
			
			points.unshift(points[0].translatedBy(startTangent.negated()));
			points.push(points[points.length - 1].translatedBy(endTangent));
			
			for ( var i:int = 2; i < points.length-2; i++) 
			{
				var prevPrevPoint:amPoint2d = points[ i >= 2 ? i - 2 : points.length + (i - 2) ];
				var ithPoint:amPoint2d = points[i];
				var prevPoint:amPoint2d = points[i > 0 ? i - 1 : points.length - 1];   
				var nextPoint:amPoint2d = points[i < points.length-1 ? i + 1 : 0]; 
				var nextNextPoint:amPoint2d = points[i < points.length - 2 ? i + 2 : (i + 2) % points.length]; 
				
				
				var prevVec:amVector2d = prevPoint.minus(ithPoint);
				var nextVec:amVector2d = nextPoint.minus(ithPoint);
				var ithAngle:Number = nextVec.clockwiseAngleTo(prevVec);
				var ithConcave:Boolean = ithAngle <= AM_PI;
				var ithTangent:amVector2d = nextVec.rotatedBy( ithAngle / 2).setToPerpVector( -amUtils.sign(ithAngle));
				
				
				
				var prevVec2:amVector2d = ithPoint.minus(nextPoint);
				var nextVec2:amVector2d = nextNextPoint.minus(nextPoint);
				var nextAngle:Number = nextVec2.clockwiseAngleTo(prevVec2);
				var nextConcave:Boolean = nextAngle <= AM_PI;
				var nextTangent:amVector2d = nextVec2.rotatedBy( nextAngle / 2).setToPerpVector( -amUtils.sign(nextAngle));
				
				//--- This is close enough visually to just draw a straight line...if we allow smaller angle differences then things can glitch out.
				if ( ithTangent.isCodirectionalTo(nextTangent, RAD_1) )
				{
					graphics.lineTo(nextPoint.x, nextPoint.y);
					continue;
				}
			
				
				//--- Find the vector bisecting the ith and next tangent lines.
				var angleDiff:Number = ithTangent.signedAngleTo(nextTangent);
				var rot:Number = angleDiff / 2;
				
				var ithSegVec:amVector2d = nextVec.normalize();
				var midwayPoint:amPoint2d = ithPoint.midwayPoint(nextPoint);
				var splitterVec:amVector2d = ithTangent.rotatedBy(rot);
				var ithEdge:amLine2d = new amLine2d(ithPoint, nextPoint);
				
				/*if ( nextTangent.angleTo(splitterVec) > RAD_90 )
				{
					nextTangent.negate();
					splitterVec.mirror(nextTangent);
				}*/
				
				var ithTangentLine:amLine2d = new amLine2d(ithPoint, ithPoint.translatedBy(ithTangent), amLine2d.LINE_TYPE_INFINITE);
				var nextTangentLine:amLine2d = new amLine2d(nextPoint, nextPoint.translatedBy(nextTangent), amLine2d.LINE_TYPE_INFINITE);
				var ghostVertex:amPoint2d = new amPoint2d();
				ithTangentLine.intersectsLine(nextTangentLine, ghostVertex);
				
				
				
				if ( ithConcave == nextConcave )
				{
					var distToEdge:Number = ithEdge.distanceToInfiniteLine(ghostVertex);
					
					midwayPoint.translateBy(ithSegVec.perpVector(ithConcave ? -1 : 1).scaleBy(distToEdge *closedSplineRatio ));
					
					var vec1:amVector2d = splitterVec.negated();
					var vec2:amVector2d = splitterVec.mirrored(ithSegVec);
					var mirroring:Boolean = false;
					var clockAngle:Number = vec2.clockwiseAngleTo(vec1);
					if ( clockAngle < AM_PI && ithConcave || clockAngle >= AM_PI && !ithConcave )
					{
						mirroring = true;
						vec1.mirror(ithSegVec);
						vec2.mirror(ithSegVec);
					}
					var hitLine1:amLine2d = new amLine2d(midwayPoint, midwayPoint.translatedBy(vec1), amLine2d.LINE_TYPE_INFINITE);
					var hitLine2:amLine2d = new amLine2d(midwayPoint, midwayPoint.translatedBy(vec2), amLine2d.LINE_TYPE_INFINITE);
					
					
					var controlIntPoint1:amPoint2d = new amPoint2d();
					var controlIntPoint2:amPoint2d = new amPoint2d();
					ithTangentLine.intersectsLine(hitLine1, controlIntPoint1);
					nextTangentLine.intersectsLine(hitLine2, controlIntPoint2);
					var anchor:amPoint2d = controlIntPoint1.midwayPoint(controlIntPoint2);
					
					//graphics.lineStyle(lineWidth, 0x00ff00);
					graphics.curveTo(controlIntPoint1.x, controlIntPoint1.y, anchor.x, anchor.y);
					graphics.curveTo(controlIntPoint2.x, controlIntPoint2.y, nextPoint.x, nextPoint.y);
				}
				else
				{
					splitterVec.mirror(ithSegVec);
					var hitLine:amLine2d = new amLine2d(midwayPoint, midwayPoint.translatedBy(splitterVec), amLine2d.LINE_TYPE_INFINITE);
					
					
					controlIntPoint1 = new amPoint2d();
					controlIntPoint2 = new amPoint2d();
					ithTangentLine.intersectsLine(hitLine, controlIntPoint1);
					nextTangentLine.intersectsLine(hitLine, controlIntPoint2);
					anchor = controlIntPoint1.midwayPoint(controlIntPoint2);
					
					//graphics.lineStyle(lineWidth, 0xff0000);
					graphics.curveTo(controlIntPoint1.x, controlIntPoint1.y, anchor.x, anchor.y);
					graphics.curveTo(controlIntPoint2.x, controlIntPoint2.y, nextPoint.x, nextPoint.y);
				}
			}
		}
	
		public static function drawClosedCubicSpline(graphics:srGraphics2d, points:Vector.<amPoint2d>, drawSplineTangents:Boolean = false ):void
		{
			graphics.moveTo(points[0].x, points[0].y);
			
			var lineWidth:Number = .1;
			
			var ithTangents:Vector.<amVector2d> = new Vector.<amVector2d>();
			
			var tracer:String = "";
			
			for ( var i:int = 0; i < points.length; i++) 
			{
				var prevPrevPoint:amPoint2d = points[ i >= 2 ? i - 2 : points.length + (i - 2) ];
				var ithPoint:amPoint2d = points[i];
				var prevPoint:amPoint2d = points[i > 0 ? i - 1 : points.length - 1];   
				var nextPoint:amPoint2d = points[i < points.length-1 ? i + 1 : 0]; 
				var nextNextPoint:amPoint2d = points[i < points.length - 2 ? i + 2 : (i + 2) % points.length]; 
				
				
				
				/*var prevPrevVec:amVector2d = prevPrevPoint.minus(prevPoint);
				var prevNextVec:amVector2d = ithPoint.minus(prevPoint);
				var prevPrevAngle:Number = prevNextVec.clockwiseAngleTo(prevPrevVec);
				var prevTangent:amVector2d = prevNextVec.rotatedBy(prevPrevAngle / 2).setToPerpVector( -amUtils.sign(prevPrevAngle));*/
				
				
				
				var prevVec:amVector2d = prevPoint.minus(ithPoint);
				var nextVec:amVector2d = nextPoint.minus(ithPoint);
				var ithAngle:Number = nextVec.clockwiseAngleTo(prevVec);
				var ithConcave:Boolean = ithAngle <= AM_PI;
				var ithTangent:amVector2d = nextVec.rotatedBy( ithAngle / 2).setToPerpVector( -amUtils.sign(ithAngle));
				
				
				
				var prevVec2:amVector2d = ithPoint.minus(nextPoint);
				var nextVec2:amVector2d = nextNextPoint.minus(nextPoint);
				var nextAngle:Number = nextVec2.clockwiseAngleTo(prevVec2);
				var nextConcave:Boolean = nextAngle <= AM_PI;
				var nextTangent:amVector2d = nextVec2.rotatedBy( nextAngle / 2).setToPerpVector( -amUtils.sign(nextAngle));
				
				
				if ( ithAngle != 0 && ithTangent.clockwiseAngleTo(prevVec2) < ithTangent.clockwiseAngleTo(nextVec2) )
				{//trace("first violated", i, refVec1.clockwiseAngleTo(prevVec), refVec1.clockwiseAngleTo(nextVec) );
					//trace("VIO");
					//nextTangent.negate();
					//nextConcave = !nextConcave;
					
					//ithTangent.negate();
					//ithConcave = !ithConcave;
					
				}
				
				/*if ( nextAngle != 0 && nextTangent.clockwiseAngleTo(prevVec) > nextTangent.clockwiseAngleTo(nextVec) )
				{//trace("first violated", i, refVec1.clockwiseAngleTo(prevVec), refVec1.clockwiseAngleTo(nextVec) );
					//trace("VIO");
					ithTangent.negate();
					ithConcave = !ithConcave;
					
					//ithTangent.negate();
					//ithConcave = !ithConcave;
					
				}*/
				
				
				/*if ( prevPrevAngle != 0 && prevTangent.clockwiseAngleTo(prevVec) < prevTangent.clockwiseAngleTo(nextVec) )
				{//trace("first violated", i, refVec1.clockwiseAngleTo(prevVec), refVec1.clockwiseAngleTo(nextVec) );
					//trace("VIO");
					ithTangent.negate();
					ithConcave = !ithConcave;
					
					//ithTangent.negate();
					//ithConcave = !ithConcave;
					
				}*/
				
				
				
				
				
				
				
				
				
				var secondVio:Boolean = false;
				if ( nextAngle != 0 && nextTangent.clockwiseAngleTo(prevVec2) < nextTangent.clockwiseAngleTo(nextVec2) )
				{//trace("next violated", i);
					//nextTangent.negate();
					//nextConcave = !nextConcave;
					
					//secondVio = true;
				}
				
				
				//--- Find the vector bisecting the ith and next tangent lines.
				var angleDiff:Number = ithTangent.signedAngleTo(nextTangent);
				var rot:Number = angleDiff / 2;
				
				var ithSegVec:amVector2d = nextVec.normalize();
				var midwayPoint:amPoint2d = ithPoint.midwayPoint(nextPoint);
				var splitterVec:amVector2d = ithTangent.rotatedBy(rot);
				var ithEdge:amLine2d = new amLine2d(ithPoint, nextPoint);
				
				/*if ( nextTangent.angleTo(splitterVec) > RAD_90 )
				{
					nextTangent.negate();
					splitterVec.mirror(nextTangent);
				}*/
				
				var ithTangentLine:amLine2d = new amLine2d(ithPoint, ithPoint.translatedBy(ithTangent), amLine2d.LINE_TYPE_INFINITE);
				var nextTangentLine:amLine2d = new amLine2d(nextPoint, nextPoint.translatedBy(nextTangent), amLine2d.LINE_TYPE_INFINITE);
				var ghostVertex:amPoint2d = new amPoint2d();
				ithTangentLine.intersectsLine(nextTangentLine, ghostVertex);
				
				if ( drawSplineTangents  )
				{
					/*if ( firstVio && secondVio )
						graphics.lineStyle(lineWidth, 0x0000ff);
					else  if ( firstVio )
						graphics.lineStyle(lineWidth, 0xff0000);
					else if ( secondVio )
						graphics.lineStyle(lineWidth, 0x00ff00);
					else*/
						graphics.setLineStyle(lineWidth, 0xffffff);
					ithEdge.draw(graphics);
					
					graphics.setLineStyle(lineWidth, 0x0000ff);
					splitterVec.draw(graphics, ghostVertex);
					
					graphics.setLineStyle(lineWidth, 0xffff00);
					ithTangent.draw(graphics, ghostVertex);
					
					graphics.setLineStyle(lineWidth, 0xff0000);
					nextTangent.draw(graphics, ghostVertex);
				}
				
				
				
				//if( 
				
				tracer += i + "-" + ithConcave + "-" + nextConcave + " ";
				
				//if ( ithConcave ) insideConcave = true;
				//if ( !nextConcave ) insideConcave = false;
				
				if ( ithConcave == nextConcave )
				{
					var distToEdge:Number = ithEdge.distanceToInfiniteLine(ghostVertex);
					
					midwayPoint.translateBy(ithSegVec.perpVector(ithConcave ? -1 : 1).scaleBy(distToEdge *closedSplineRatio ));
					
					var vec1:amVector2d = splitterVec.negated();
					var vec2:amVector2d = splitterVec.mirrored(ithSegVec);
					var mirroring:Boolean = false;
					var clockAngle:Number = vec2.clockwiseAngleTo(vec1);
					if ( clockAngle < AM_PI && ithConcave || clockAngle >= AM_PI && !ithConcave )
					{
						mirroring = true;
						vec1.mirror(ithSegVec);
						vec2.mirror(ithSegVec);
					}
					var hitLine1:amLine2d = new amLine2d(midwayPoint, midwayPoint.translatedBy(vec1), amLine2d.LINE_TYPE_INFINITE);
					var hitLine2:amLine2d = new amLine2d(midwayPoint, midwayPoint.translatedBy(vec2), amLine2d.LINE_TYPE_INFINITE);
					
					if ( drawSplineTangents  )
					{
						/*graphics.lineStyle(lineWidth, mirroring ? 0xff0000 : 0xffffff);
						hitLine1.asVector().draw(graphics, midwayPoint);
						hitLine2.asVector().draw(graphics, midwayPoint);*/
					
						graphics.moveTo(ithPoint.x, ithPoint.y);
					}
					
					var controlIntPoint1:amPoint2d = new amPoint2d();
					var controlIntPoint2:amPoint2d = new amPoint2d();
					ithTangentLine.intersectsLine(hitLine1, controlIntPoint1);
					nextTangentLine.intersectsLine(hitLine2, controlIntPoint2);
					var anchor:amPoint2d = controlIntPoint1.midwayPoint(controlIntPoint2);
					
					//graphics.lineStyle(lineWidth, 0x00ff00);
					graphics.curveTo(controlIntPoint1.x, controlIntPoint1.y, anchor.x, anchor.y);
					graphics.curveTo(controlIntPoint2.x, controlIntPoint2.y, nextPoint.x, nextPoint.y);
				}
				else
				{
					splitterVec.mirror(ithSegVec);
					var hitLine:amLine2d = new amLine2d(midwayPoint, midwayPoint.translatedBy(splitterVec), amLine2d.LINE_TYPE_INFINITE);
					
					if ( drawSplineTangents )
					{
						graphics.setLineStyle(lineWidth, 0xffffff);
						splitterVec.draw(graphics, midwayPoint);
						
						graphics.moveTo(ithPoint.x, ithPoint.y);
					}
					
					controlIntPoint1 = new amPoint2d();
					controlIntPoint2 = new amPoint2d();
					ithTangentLine.intersectsLine(hitLine, controlIntPoint1);
					nextTangentLine.intersectsLine(hitLine, controlIntPoint2);
					anchor = controlIntPoint1.midwayPoint(controlIntPoint2);
					
					//graphics.lineStyle(lineWidth, 0xff0000);
					graphics.curveTo(controlIntPoint1.x, controlIntPoint1.y, anchor.x, anchor.y);
					graphics.curveTo(controlIntPoint2.x, controlIntPoint2.y, nextPoint.x, nextPoint.y);
				}
				
				ithTangents.push(ithTangent);
			}
			
			//trace(tracer);
		}
	}
}