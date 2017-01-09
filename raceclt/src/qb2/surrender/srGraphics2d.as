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
	/**
	 * 
	 * @author Doug Koellmer
	 */
	public class srGraphics2d
	{
		public virtual function clear():void {}
		
		public virtual function setLineStyle(thickness:Number = 0, color:uint = 0x000000, alpha:Number = 1.0):void {}
		
		public virtual function beginFill(color:uint = 0, alpha:Number = 1.0):void {}
		public virtual function endFill():void {}
		
		public virtual function moveTo(x:Number, y:Number):void {}
		public virtual function lineTo(x:Number, y:Number):void {}
		public virtual function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void {}
		
		public virtual function drawCircle(centerX:Number, centerY:Number, radius:Number):void {}
		
		public function drawLine(begX:Number, begY:Number, endX:Number, endY:Number):void 
		{
			moveTo(begX, begY);
			lineTo(endX, endY);
		}
	}
}