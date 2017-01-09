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
	import qb2.As3Math.geo2d.amPoint2d;
	import qb2.As3Math.consts.*;
	import flash.display.Graphics;
	
	public class amUtils
	{
		public static function getRandInt(startValue:int, endValue:int):int
			{  return Math.round(Math.random() * (endValue - startValue) + startValue);  }
		
		public static function getRandFloat(startValue:Number, endValue:Number):Number
			{  return Math.round(Math.random() * (endValue - startValue) + startValue);  }

		public static function equals( var1:Number, var2:Number, tolerance:Number = .001 ):Boolean
			{  return isWithin(var1, var2 - tolerance, var2 + tolerance);  }
		
		public static function isWithin(testNum:Number, low:Number, high:Number, tolerance:Number = 0):Boolean
			{  return testNum >= low-tolerance && testNum <= high+tolerance;  }
			
		public static function isBetween(testNum:Number, low:Number, high:Number, tolerance:Number = 0):Boolean
			{  return testNum > low-tolerance && testNum < high+tolerance;  }
		
		public static function areWithin(testNums:Array, low:Number, high:Number, tolerance:Number = 0):Boolean
		{
			for( var i:int = 0; i < testNums.length; i++ )
				if( !isWithin(testNums[i], low, high, tolerance) )
					return false;
			return true;
		}
		
		public static function sign(number:Number):Number
			{  return number / (number ? Math.abs(number) : 1);  }
		
		public static function get randomSign():Number
			{  return Math.random() > .5 ? 1 : -1;  }
		
		public static function constrain(value:Number, lowerLimit:Number, upperLimit:Number):Number
			{  return value < lowerLimit ? lowerLimit : (value > upperLimit ? upperLimit : value);  }
		
		public static function toRad(degrees:Number):Number
			{  return degrees * TO_RAD;  }

		public static function toDeg(radians:Number):Number
			{  return radians * TO_DEG;  }
			
		public static function fixPoint(somePoint:amPoint2d):amPoint2d
			{  return !somePoint ? new amPoint2d() : somePoint;  }
	}
}