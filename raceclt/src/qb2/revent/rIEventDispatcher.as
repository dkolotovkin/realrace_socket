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

package qb2.revent
{
	public interface rIEventDispatcher
	{
		function addEventListener(type:String,            listener:Function, listenerOwner:Object = null, reserved:Boolean = false):void;
		
		function addEventListenerForTypes(types:Array,    listener:Function, listenerOwner:Object = null, reserved:Boolean = false):void;
		
		function addEventListeners(types:Array,           listeners:Array,   listenerOwner:Object = null, reserved:Boolean = false):void;
		
		function removeEventListener(type:String,         listener:Function, listenerOwner:Object = null):void;
		
		function removeEventListenerForTypes(types:Array, listener:Function, listenerOwner:Object = null):void;
		
		function removeEventListeners(types:Array,        listeners:Array,   listenerOwner:Object = null):void;
		
		function removeAllEventListenersForType(type:String):void;
		
		function removeAllEventListenersForTypes(types:Array):void;
		
		function removeAllEventListeners():void;
		
		function hasEventListener(type:String):Boolean;
		
		function hasEventListenerForTypes(types:Array, mustHaveAllTypes:Boolean = false):Boolean;
		
		function dispatchEvent(event:rEvent):void;
		
		function pushDispatchBlock(listener:Function):void;
		
		function popDispatchBlock(listener:Function):void;
	}
}