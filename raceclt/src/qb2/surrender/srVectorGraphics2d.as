/**
 * Copyright (c) 2010 Doug Koellmer
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

package qb2.surrender
{
	import flash.display.Graphics;
	
	/**
	 * Wraps the Flash Graphics object to be compatible with srGraphics2d.
	 * 
	 * @author Doug Koellmer
	 */
	public class srVectorGraphics2d extends srGraphics2d
	{
		public var flashGraphicsObject:Graphics = null;
		
		public function srVectorGraphics2d(flashGraphicsObject:Graphics):void
		{
			this.flashGraphicsObject = flashGraphicsObject;
		}
		
		public override function clear():void
		{
			flashGraphicsObject.clear();
		}
		
		private static const NORMAL_SCALE_MODE:String = "normal";
		private static const CAPS_STYLE:String = "none";
		
		public override function setLineStyle(thickness:Number = 0, color:uint = 0x000000, alpha:Number = 1.0 ):void
		{
			if ( thickness )
			{
				flashGraphicsObject.lineStyle(thickness, color, alpha, false, NORMAL_SCALE_MODE, CAPS_STYLE);
			}
			else
			{
				flashGraphicsObject.lineStyle();
			}
		}
		
		public override function beginFill(color:uint = 0, alpha:Number = 1.0):void
		{
			flashGraphicsObject.beginFill(color, alpha);
		}
		
		public override function endFill():void
		{
			flashGraphicsObject.endFill();
		}
		
		public override function moveTo(x:Number, y:Number):void
		{
			flashGraphicsObject.moveTo(x, y);
		}
		
		public override function lineTo(x:Number, y:Number):void
		{
			flashGraphicsObject.lineTo(x, y);
		}
		
		public override function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void
		{
			flashGraphicsObject.curveTo(controlX, controlY, anchorX, anchorY);
		}
		
		public override function drawCircle(centerX:Number, centerY:Number, radius:Number):void
		{
			flashGraphicsObject.drawCircle(centerX, centerY, radius);
		}
	}

}