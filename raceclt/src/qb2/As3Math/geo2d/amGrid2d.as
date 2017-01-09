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
	import qb2.As3Math.general.amUtils;
	import flash.display.Graphics;

	public class amGrid2d
	{
		private var _width:Number, _height:Number;
		protected var a:uint, d:uint;
		public var x:Number = 0, y:Number = 0;
		
		private var coords:Vector.<Vector.<uint>>;
		
		public var trackChanged:Boolean  = false;
		public var onlyTrackIf:Vector.<uint> = new Vector.<uint>();
		protected var tracked:Vector.<uint> = new Vector.<uint>();
		
		public static const EMPTY:uint   =  0;
		public static const FILLED:uint  =  1;
		public static const INVALID:uint =  uint.MAX_VALUE;
		
		private static const dec:Number = .2;
	
		public function amGrid2d(__across:uint, __down:uint, __width:Number = 0, __height:Number = 0)
		{
			_width = __width;  _height = __height;
			set(__across, __down);
		}
		
		public function set(__across:uint, __down:uint):void
		{
			//--- Clear the 2d array if it exists already...
			if ( coords )
			{
				coords.length = 0;
				coords = null;
			}
			
			a = __across;
			d = __down;
		}
		
		public function getTracked():Vector.<uint>
			{  return tracked;  }
		
		public function setTracked(value:uint, clearArrayToo:Boolean = false ):void
		{
			var save:Boolean = trackChanged;
			trackChanged = false;
			for ( var i:uint = 0; i < tracked.length; i += 2 )
			{
				fillQuad(tracked[i], tracked[i + 1], value);
			}
			trackChanged = save;
			
			if ( clearArrayToo )  clearTracked();
		}
		
		public function clearTracked():void
			{  tracked.length = 0;  }
		
		public function numTracked():uint
			{  return tracked.length / 2;  }

		public function fill(value:uint):void
		{
			for ( var i:uint = 0; i < a; i++ )
				for ( var j:uint = 0; j < d; j++ )
					fillQuad(i, j, value);
		}
		
		public static const BIT_MODE_SET:uint = 0;
		public static const BIT_MODE_ADD:uint = 1;
		public static const BIT_MODE_SUB:uint = 2;
		public static const BIT_MODE_IGN:uint = 3;
		
		public var bitMode:uint = BIT_MODE_SET;
		
		public function fillQuad(m:uint, n:uint, value:uint):void
		{
			if ( m >= a || n >= d )  return;
			
			if ( bitMode != BIT_MODE_IGN)
			{
				if( !coords )
					coords = new Vector.<Vector.<uint>>(a, true);
				if ( !coords[m] )
					coords[m] = new Vector.<uint>(d, true);
			}
			
			if ( trackChanged )
			{
				var track:Boolean = false;

				if ( onlyTrackIf.length )
				{
					for each( var toTrack:uint in onlyTrackIf )
						if ( coords[m][n] == toTrack )
							{  track = true;  break;  }
				}
				else  track = true;

				if ( track )  tracked.push(m, n);
			}

			if( bitMode == BIT_MODE_ADD )
				coords[m][n] |= value;
			else if ( bitMode == BIT_MODE_SUB )
				coords[m][n] &= ~value;
			else if( bitMode == BIT_MODE_SET) 
				coords[m][n] = value;
		}
		
		public function fillBoundBox(box:amBoundBox2d, value:uint, insideToo:Boolean = false ):void
		{
			var quadWid:Number = _width / a;
			var quadHei:Number = _height / d;
			var divWid:Number = quadWid - dec;
			var divHei:Number = quadHei - dec;
			
			var top:amLine2d = box.topEdge;
			var bot:amLine2d = box.bottomEdge;
			var lef:amLine2d = box.leftEdge;
			var rig:amLine2d = box.rightEdge;

			var horLen:Number = top.length;
			var verLen:Number = lef.length;
			var numAcross:uint = Math.floor(horLen / divWid) + 1;
			var numDown:uint   = Math.floor(verLen / divHei) + 1;
			var horStep:Number = horLen / numAcross;
			var verStep:Number = verLen / numDown;
			
			if ( !insideToo )
			{
				var currX:Number = box.min.x;
				var pnt:amPoint2d = new amPoint2d();
				for ( var i:uint = 0; i < numAcross; i++ )
				{
					pnt.x = currX;  pnt.y = box.min.y;
					fillPointPriv(pnt, value);
					pnt.y = box.max.y;
					fillPointPriv(pnt, value);
					
					currX += horStep;
				}
				
				var currY:Number = box.min.y;
				for ( i = 0; i < numDown; i++ )
				{
					pnt.x = box.min.x;  pnt.y = currY;
					fillPointPriv(pnt, value);
					pnt.x = box.max.x;
					fillPointPriv(pnt, value);
					
					currY += verStep;
				}
			}
			//--- For the fill, numAcross/Down must be incremented by 1. The !insideToo case's maximum
			//--- coordinates are filled because you use the boundary lines themselves, not an incrementing for-loop.
			else
			{
				currX = box.min.x;
				pnt = new amPoint2d();
				for ( i = 0; i < numAcross+1; i++ )
				{
					currY = box.min.y;
					for ( var j:uint = 0; j < numDown+1; j++ )
					{
						pnt.x = currX;  pnt.y = currY;
						fillPointPriv(pnt, value);
						
						currY += verStep;
					}
					
					currX += horStep;
				}
			}
		}
		
		public function fillLine(line:amLine2d, value:uint = FILLED, thickness:uint = 1):void
		{
			var norm:amVector2d = line.direction;

			if ( _height <= 0 || _width <= 0 || a == 0 || d == 0 )  return;
			
			if ( thickness == 0 )  thickness = 1;
			
			var quadWid:Number = _width / a;
			var quadHei:Number = _height / d;
			var len:Number = line.length;
			var div:Number = Math.min(quadWid, quadHei) - dec;
			var num:uint = Math.floor(len / div);
			
			var lineDir:amVector2d = norm.scaledBy(line.length);
			var perpL:amVector2d = lineDir.perpVector().normalize();
			var perpR:amVector2d = perpL.clone().negate();
			var lines:Vector.<amLine2d> = new Vector.<amLine2d>();
			var baseL:amPoint2d = line.point1.clone(), baseR:amPoint2d = line.point1.clone();

			lines.push(line);
			perpL.scaleBy(div / 2);  perpR.scaleBy(div / 2);
			baseL.translateBy(perpL);     baseR.translateBy(perpR);
			for ( var i:uint = 0; i < thickness*2; i += 2 )
			{
				var endL:amPoint2d = baseL.clone().translateBy(lineDir);
				var endR:amPoint2d = baseR.clone().translateBy(lineDir);
				lines.push(new amLine2d(baseL.clone(), endL));
				lines.push(new amLine2d(baseR.clone(), endR));

				baseL.translateBy(perpL);     baseR.translateBy(perpR);
			}
			lines.pop();  lines.pop();
	
			
			var step:Number = len / (num + 1);
			var pnt:amPoint2d = new amPoint2d();
			for ( i= 0; i < num+1; i++ )
			{
				//--- amLine2d:getPointAtDist could be used here, but calculations are done locally for a slight speed boost,
				//--- because of not having to calculate the normal of the line every time.
				for ( var j:uint = 0; j < lines.length; j++ )
				{
					pnt.set(lines[j].point1.x, lines[j].point1.y);
					pnt.translateBy(norm.scaledBy(i * step));
					fillPointPriv(pnt, value);
				}
			}
			for ( j = 0; j < lines.length; j++ )
			{
				pnt = lines[j].point2;
				fillPointPriv(pnt, value);
			}
		}
		
		public function fillPoint(point:amPoint2d, value:uint):Object
		{
			if ( _height <= 0 || _width <= 0 || a == 0 || d == 0 )  return null;
			
			return fillPointPriv(point, value);
		}
		
		public function fillCircle(circle:amCircle2d, value:uint, insideToo:Boolean = false):void
		{	
			var radius:Number = circle.radius;
			var circum:Number = Math.PI * radius * 2;
			var quadWid:Number = _width / a;
			var quadHei:Number = _height / d;
			var div:Number = Math.min(quadWid, quadHei) / 1.5;
			var num:uint = Math.floor(circum / div) + 1;
			
			var rotPnt:amPoint2d = circle.center.clone();
			rotPnt.y += circle.radius;
			var step:Number = amUtils.toRad(360) / num;
			for ( var i:uint = 0; i < num; i++ )
			{
				fillPointPriv(rotPnt, value);
				rotPnt.rotateBy(step, circle.center);
			}
			
			if ( !insideToo )  return;
			
			var len:Number = radius;
			var radDiv:Number = Math.min(quadWid, quadHei) - dec;
			var radNum:uint = Math.floor(radius / radDiv);
			
			fillPointPriv(circle.center, value);
			
			var radStep:Number = len / (radNum + 1);
			var currRad:Number = radStep;
			for ( i = 0; i < radNum; i++ )
			{
				circum = Math.PI * currRad * 2;
				num = Math.floor(circum / div) + 1;
				
				rotPnt.x = circle.center.x;
				rotPnt.y = circle.center.y + currRad;
				step = amUtils.toRad(360) / num;
				for ( var j:uint = 0; j < num; j++ )
				{
					fillPointPriv(rotPnt, value);
					rotPnt.rotateBy(step, circle.center);
				}
				
				currRad += radStep;
			}	
		}
		
		public var skipOutliers:Boolean = true;

		private function fillPointPriv(point:amPoint2d, value:uint):Object
		{
			var coords:Object = getGridCoords(point);
			if ( !coords )  return null;
			fillQuad(coords.m, coords.n, value);
			return coords;
		}
		
		public function getPnt(m:uint, n:uint):amPoint2d
		{
			return new amPoint2d(x + m * (_width / a), y + n * (_height / d));
		}
		
		public function getGridCoords(point:amPoint2d):Object
		{
			var corrX:Number = point.x;
			var corrY:Number = point.y;

			if ( outOfBounds(point) )
			{
				return null;
				/*if ( !accountForOutOfBoundPoints )	
					return null;
				else
				{
					corrX = corrX < x ? x : corrX;
					corrX = corrX > x + width ? x + width : corrX;
					
					corrY = corrY < y ? y : corrY;
					corrY = corrY > y + height ? y + height : corrY;
				}*/
			}
			var quadWid:Number = _width / a;
			var quadHei:Number = _height / d;
			var relX:Number = corrX - x;
			var relY:Number = corrY - y;
			var m:uint = Math.floor(relX / quadWid);
			var n:uint = Math.floor(relY / quadHei);
			
			/*if ( accountForOutOfBoundPoints )
			{
				if ( m >= a )  m = a - 1;
				if ( n >= d )  n = d - 1;
			}*/
		
			return { m:m, n:n };
		}
		
		private function outOfBounds(pnt:amPoint2d):Boolean
		{
			return (pnt.x < x || pnt.x > x + _width || pnt.y < y || pnt.y > y + _height);
		}
		
		public function get across():uint
			{  return a;  }
		
		public function get down():uint
			{  return d;  }
			
		public function get width():Number
			{  return _width;  }
			
		public function set width(value:Number):void
		{
			_width = value;
		}
		
		public function set height(value:Number):void
		{
			_height = value;
		}

		
		public function get height():Number
			{  return _height;  }
			
		public function get quadWidth():Number
		{
			if ( _width <= 0 )  return -1;
			return _width / a;
		}
		
		public function get quadHeight():Number
		{
			if ( _height <= 0 )  return -1;
			return _height / d;
		}
		
		public function getFill(m:uint, n:uint):uint
		{	
			if ( m >= a || n >= d )  return amGrid2d.INVALID;
			
			if ( !coords || !coords[m] ) return amGrid2d.INVALID;
			
			return coords[m][n];
		}
		
		public function getFillAtPnt(point:amPoint2d):uint
		{
			var mn:Object = getGridCoords(point);
			if ( !mn )  return amGrid2d.EMPTY;
			return getFill(mn.m, mn.n);
		}
		
		public static const DRAW_RULE_STRICT:uint = 0;
		public static const DRAW_RULE_BITWISE:uint = 1;
		
		public var drawRule:uint = DRAW_RULE_STRICT;
			
		public function drawFills(graphics:Graphics, fillDef:uint = amGrid2d.FILLED, fillByColor:Boolean = false, onlyConsiderTracked:Boolean = false, alpha:Number = 1 ):void
		{
			if ( _height <= 0 || _width <= 0 || a == 0 || d == 0 )  return;
			
			var quadWid:Number = _width / a;
			var quadHei:Number = _height / d;

			if ( onlyConsiderTracked )
			{
				for ( var i:uint = 0; i < tracked.length; i+=2 )
				{
					var val:uint = coords[tracked[i]][tracked[i + 1]];
					if ( fillByColor  )
					{
						if ( val != fillDef )
						{
							var xPos:Number = x + tracked[i]   * quadWid;
							var yPos:Number = y + tracked[i+1] * quadHei;
							graphics.beginFill(val, alpha);
							graphics.drawRect(xPos, yPos, quadWid, quadHei);
						}
					}
					else if ( val == fillDef && drawRule == DRAW_RULE_STRICT || (val & fillDef) && drawRule == DRAW_RULE_BITWISE )
					{
						xPos = x + tracked[i] * quadWid;
						yPos = y + tracked[i+1] * quadHei;
						graphics.drawRect(xPos, yPos, quadWid, quadHei);
					}
				}
			}
			else
			{
				for ( i = 0; i < a; i++ )
				{
					for ( var j:uint = 0; j < d; j++ )
					{
						if ( fillByColor  )
						{
							if ( coords[i][j] != fillDef )
							{
								xPos = x + i * quadWid;
								yPos = y + j * quadHei;
								graphics.beginFill(coords[i][j], alpha);
								graphics.drawRect(xPos, yPos, quadWid, quadHei);
							}
						}
						else if ( coords[i][j] == fillDef && drawRule == DRAW_RULE_STRICT || (coords[i][j] & fillDef) && drawRule == DRAW_RULE_BITWISE )
						{
							xPos = x + i * quadWid;
							yPos = y + j * quadHei;
							graphics.drawRect(xPos, yPos, quadWid, quadHei);
						}
					}
				}
			}
		}
		
		public function drawLines(graphics:Graphics, less1ForLast:Boolean = false):void
		{
			var quadWid:Number = _width / a;
			var quadHei:Number = _height / d;

			graphics.moveTo(x + 0, y + 0);
			graphics.lineTo(x + 0, y + _height);
			var num:uint = less1ForLast ? a - 1 : a;
			for ( var i:uint = 0; i < num; i++ )
			{
				graphics.moveTo( x + (i + 1) * quadWid, y + 0);
				graphics.lineTo( x + (i + 1) * quadWid, y + _height);
			}
			if ( less1ForLast )
			{
				graphics.moveTo(x + _width-1, y + 0);
				graphics.lineTo(x + _width-1, y + _height);
			}
			
			graphics.moveTo(x + 0, y + 0);
			graphics.lineTo(x + _width, y + 0);
			num = less1ForLast ? d - 1 : d;
			for ( i = 0; i < num; i++ )
			{
				graphics.moveTo( x + 0,      y + (i + 1) * quadHei);
				graphics.lineTo( x + _width, y + (i + 1) * quadHei);
			}
			if ( less1ForLast )
			{
				graphics.moveTo(x + 0,       y +  _height-1);
				graphics.lineTo(x + _width-1, y + _height-1);
			}
		}
	}
}