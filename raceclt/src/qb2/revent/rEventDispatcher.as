/**
 * Copyright (c) Doug Koellmer
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
	import qb2.revent.*;
	import flash.utils.Dictionary;
	use namespace rev_friend;
	
	/**
	 * Base class for any classes that use revent's event dispatching system.
	 * 
	 * @author Doug Koellmer
	 */
	public class rEventDispatcher implements rIEventDispatcher
	{
		private static const CACHED_REFLECTION_EVENT:rReflectionEvent = new rReflectionEvent();
		
		private var _strongTypeMap:Dictionary = null;
		private var _weakTypeMap:Dictionary   = null;
		
		/**
		 * Registers a listener for a specific event type.
		 * 
		 * @param	type The event type.  This is generally given as a static constant of a subclass of rEvent.
		 * @param	listener The listener function that processes the event. This function must accept an rEvent as its only parameter and return nothing.
		 * @param	listenerOwner The object that owns 'listener' (optional).  If provided, a weak reference to the listener is kept.  A weak reference will allow 'listenerOwner' to be garbage-collected without having to remove the listener.
		 * @param	reserved Determines whether this listener can be removed implicitly by a call to rEventDispatcher::removeAll*().  If true, it cannot be removed implicitly, but only explicitly, by a call to rEventDispatcher::removeEventListener*().
		 */
		public function addEventListener(type:String, listener:Function, listenerOwner:Object = null, reserved:Boolean = false ):void
		{
			pushReflectionSuppression();
			{
				if ( listenerOwner )
				{
					clearListenerFromStrongTypeMap(type, listener);
					
					//--- Add the listener to the weak type map.
					{
						_weakTypeMap = _weakTypeMap ? _weakTypeMap : new Dictionary(false);
						
						var ownerDict:Dictionary = _weakTypeMap[type];
						
						if ( !ownerDict )
						{
							ownerDict = new Dictionary(true);
							_weakTypeMap[type] = ownerDict;
							
							if ( !_typesRemoved )
							{
								addTypeAdded(type);
							}
						}
						
						var weakClosureList:Vector.<rWeakMethodClosure> = ownerDict[listenerOwner];
						
						if ( !weakClosureList )
						{
							weakClosureList = new Vector.<rWeakMethodClosure>();
							ownerDict[listenerOwner] = weakClosureList;
						}
						
						var listenerName:String = rUtils.getFunctionName(listener, listenerOwner);
						
						if ( rUtils.getIndexInWeakClosureList(weakClosureList, listenerName) == -1 )
						{
							var newWeakClosure:rWeakMethodClosure = new rWeakMethodClosure();
							newWeakClosure.listenerName = listenerName;
							newWeakClosure.reserved = reserved;
							weakClosureList.push(newWeakClosure);
						}
					}
				}
				else
				{
					clearListenerFromWeakTypeMapWithoutOwner(type, listener);
					
					{
						_strongTypeMap = _strongTypeMap ? _strongTypeMap : new Dictionary(false);
						
						var strongClosureList:Vector.<rStrongMethodClosure> = _strongTypeMap[type];
						if ( !strongClosureList )
						{
							strongClosureList = new Vector.<rStrongMethodClosure>();
							_strongTypeMap[type] = strongClosureList;
							
							if ( !_typesRemoved )
							{
								addTypeAdded(type);
							}
						}
						
						if ( rUtils.getIndexInStrongClosureList(strongClosureList, listener) == -1 )
						{
							var newStrongClosure:rStrongMethodClosure = new rStrongMethodClosure();
							newStrongClosure.listener = listener;
							newStrongClosure.reserved = reserved;
							strongClosureList.push(newStrongClosure);
						}
					}
				}
				
				_reflectionsRemoved = null;
				_typesRemoved = null;
			}
			popReflectionSuppression();
		}
		
		/**
		 * Registers a listener for any number of event types.
		 * 
		 * @param	types The event types.
		 * @param	listener The listener function that processes the event(s). This function must accept an rEvent as its only parameter and return nothing.
		 * @param	listenerOwner The object that owns 'listener' (optional).  If provided, a weak reference to the listener is kept.  A weak reference will allow 'listenerOwner' to be garbage-collected without having to remove the listener.
		 * @param	reserved Determines whether the listener(s) can be removed implicitly by a call to rEventDispatcher::removeAll*().  If true, it cannot be removed implicitly, but only explicitly, by a call to rEventDispatcher::removeEventListener*().
		 */
		public function addEventListenerForTypes(types:Array, listener:Function, listenerOwner:Object = null, reserved:Boolean = false):void
		{
			pushReflectionSuppression();
			{
				for (var i:int = 0; i < types.length; i++) 
				{
					addEventListener(types[i], listener, listenerOwner, reserved);
				}
			}
			popReflectionSuppression();
		}
		
		/**
		 * Registers any number of listeners for any number of event types.
		 * 
		 * @param	types The event types.
		 * @param	listeners The listener function(s) that processes the event(s). This function(s) must accept an rEvent as its only parameter and return nothing.
		 * @param	listenerOwner The object that owns the 'listeners' (optional).  If provided, weak references to the listener(s) is kept.  A weak reference will allow 'listenerOwner' to be garbage-collected without having to remove the listener.
		 * @param	reserved Determines whether this listener(s) can be removed implicitly by a call to rEventDispatcher::removeAll*().  If true, it cannot be removed implicitly, but only explicitly, by a call to rEventDispatcher::removeEventListener*().
		 */
		public function addEventListeners(types:Array, listeners:Array, listenerOwner:Object = null, reserved:Boolean = false):void
		{
			pushReflectionSuppression();
			{
				processMultiple(types, listeners, true, listenerOwner, reserved);
			}
			popReflectionSuppression();
		}
		
		/**
		 * Removes a listener from the rEventDispatcher object. If there is no matching listener registered with the rEventDispatcher object, a call to this method has no effect.
		 * 
		 * @param	type The event type.
		 * @param	listener The listener function to remove.
		 * @param	listenerOwner The listenr function's owner.  Providing this will help this rEventDispatcher remove the listener more quickly if it was originally added with the owner, but is not necessary.
		 */
		public function removeEventListener(type:String, listener:Function, listenerOwner:Object = null):void
		{
			pushReflectionSuppression();
			{
				clearListenerFromWeakTypeMapWithOwner(type, listener, listenerOwner);
				clearListenerFromStrongTypeMap(type, listener);
			}
			popReflectionSuppression();
		}
		
		public function removeEventListenerForTypes(types:Array, listener:Function, listenerOwner:Object = null):void
		{
			pushReflectionSuppression();
			{
				for (var i:int = 0; i < types.length; i++) 
				{
					removeEventListener(types[i], listener, listenerOwner);
				}
			}
			popReflectionSuppression();
		}
		
		public function removeEventListeners(types:Array, listeners:Array, listenerOwner:Object = null):void
		{
			pushReflectionSuppression();
			{
				processMultiple(types, listeners, false, listenerOwner, false);
			}
			popReflectionSuppression();
		}
		
		public function removeAllEventListenersForType(type:String):void
		{
			pushReflectionSuppression(true);
			{
				removeAllWeakEventListenersForType(type);
				removeAllStrongEventListenersForType(type);
			}
			popReflectionSuppression();
		}
		
		public function removeAllEventListenersForTypes(types:Array):void
		{
			pushReflectionSuppression(true);
			{
				for (var i:int = 0; i < types.length; i++) 
				{
					removeAllEventListenersForType(types[i]);
				}
			}
			popReflectionSuppression();
		}
		
		public function removeAllEventListeners():void
		{
			pushReflectionSuppression(true);
			{
				var typeMapKeys:Array = rUtils.getKeysFromDict(_weakTypeMap);
				for (var i:int = 0; i < typeMapKeys.length; i++) 
				{
					removeAllWeakEventListenersForType(typeMapKeys[i]);
				}
				
				typeMapKeys = rUtils.getKeysFromDict(_strongTypeMap);
				for ( i = 0; i < typeMapKeys.length; i++) 
				{
					removeAllStrongEventListenersForType(typeMapKeys[i]);
				}
				
			}
			popReflectionSuppression();
		}
		
		private function removeAllWeakEventListenersForType(type:String):void
		{
			if ( _weakTypeMap )
			{
				var ownerDict:Dictionary = _weakTypeMap[type];
				var ownerArray:Array = rUtils.getKeysFromDict(_weakTypeMap[type]);
				for (var i:int = 0; i < ownerArray.length; i++) 
				{
					var weakClosureList:Vector.<rWeakMethodClosure> = ownerDict[ownerArray[i]];
		
					for (var j:int = weakClosureList.length - 1; j >= 0; j-- ) 
					{
						var listenerName:String = weakClosureList[j].listenerName;
						clearListenerFromWeakTypeMapWithOwner(type, listenerName, ownerArray[i]);
					}
				}
			}
		}
		
		private function removeAllStrongEventListenersForType(type:String):void
		{
			if ( _strongTypeMap )
			{
				var strongClosureList:Vector.<rStrongMethodClosure> = _strongTypeMap[type];
				if ( strongClosureList )
				{
					for ( var i:int = strongClosureList.length-1; i >= 0; i-- )
					{
						clearListenerFromStrongTypeMap(type, strongClosureList[i].listener);
					}
				}
			}
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return _strongTypeMap && _strongTypeMap[type] || _weakTypeMap && _weakTypeMap[type] ? true : false;
		}
		
		public function hasEventListenerForTypes(types:Array, mustHaveAllTypes:Boolean = false):Boolean
		{
			for (var i:int = 0; i < types.length; i++) 
			{
				if ( hasEventListener(types[i]) )
				{
					if ( !mustHaveAllTypes )
					{
						return true;
					}
				}
				else
				{
					if ( mustHaveAllTypes )
					{
						return false;
					}
				}
			}
			
			if ( mustHaveAllTypes )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function pushDispatchBlock(listener:Function):void
		{
			_dispatchCancellationDict = _dispatchCancellationDict ? _dispatchCancellationDict : new Dictionary();
			
			_dispatchCancellationDict[listener] = _dispatchCancellationDict[listener] ? _dispatchCancellationDict[listener] : 0;
			
			_dispatchCancellationDict[listener]++;
		}
		
		public function popDispatchBlock(listener:Function):void
		{
			if ( !_dispatchCancellationDict )  return;
			
			if ( !_dispatchCancellationDict[listener] )  return;
			
			_dispatchCancellationDict[listener]--;
			
			if ( _dispatchCancellationDict[listener] <= 0 )
			{
				delete _dispatchCancellationDict[listener];
				
				if ( rUtils.isEmpty(_dispatchCancellationDict) )
				{
					_dispatchCancellationDict = null;
				}
			}
		}
		
		private var _dispatchCancellationDict:Dictionary = null;
		
		public function dispatchEvent(event:rEvent):void
		{
			if ( !(event as rReflectionEvent) && !_strongTypeMap && !_weakTypeMap )  return;
			
			if ( event.inUse )  throw new Error("This event is currently in use.");
			
			event._dispatcher = this;
			event._inUse      = true;
			{
				if ( _strongTypeMap )
				{
					var strongClosureList:Vector.<rStrongMethodClosure> = _strongTypeMap[event.type];
					
					if ( strongClosureList )
					{
						for (var i:int = 0; i < strongClosureList.length; i++) 
						{
							var listener:Function = strongClosureList[i].listener;
							
							if ( _dispatchCancellationDict && _dispatchCancellationDict[listener] )  continue;
							
							listener(event);
						}
					}
				}
				
				if ( _weakTypeMap )
				{
					var ownerDict:Dictionary = _weakTypeMap[event.type];
					
					if ( ownerDict )
					{
						for ( var key:* in ownerDict )
						{
							var weakClosureList:Vector.<rWeakMethodClosure> = ownerDict[key];
					
							for ( i = 0; i < weakClosureList.length; i++) 
							{
								listener = key[weakClosureList[i].listenerName];
								
								if ( _dispatchCancellationDict && _dispatchCancellationDict[listener] )  continue;
								
								listener(event);
							}
						}
					}
				}
				
				if ( _reflectionsRemoved && event.type == rReflectionEvent.EVENT_TYPES_REMOVED )
				{
					for (var j:int = 0; j < _reflectionsRemoved.length; j++) 
					{
						var object:* = _reflectionsRemoved[j];
						
						if ( object as rStrongMethodClosure )
						{
							listener = (object as rStrongMethodClosure).listener;
							
							if ( _dispatchCancellationDict && _dispatchCancellationDict[listener] )  continue;
							
							listener(event);
						}
						else
						{
							var owner:Object = _reflectionsRemoved[j + 1];
							
							listener = owner[(object as rWeakMethodClosure).listenerName]
							
							if ( _dispatchCancellationDict && _dispatchCancellationDict[listener] )  continue;
							
							listener(event);
							
							j++;
						}
					}
				}
			}
			event._inUse      = false;
			event._dispatcher = null;
		}
		
		private function clearListenerFromWeakTypeMapWithoutOwner(type:String, listener:Function):void
		{
			if ( _weakTypeMap )
			{
				var ownerArray:Array = rUtils.getKeysFromDict(_weakTypeMap[type]);
				for (var i:int = 0; i < ownerArray.length; i++) 
				{
					clearListenerFromWeakTypeMapWithOwner(type, listener, ownerArray[i]);
				}
				
			}
		}
		
		private function clearListenerFromWeakTypeMapWithOwner(type:String, listener_String_or_Function:*, listenerOwner:Object):void
		{
			if ( _weakTypeMap )
			{
				var ownerDict:Dictionary = _weakTypeMap[type];
				
				if ( ownerDict )
				{
					var closureList:Vector.<rWeakMethodClosure> = ownerDict[listenerOwner] as Vector.<rWeakMethodClosure>;
						
					if ( closureList )
					{
						var listenerName:String = listener_String_or_Function as Function ? rUtils.getFunctionName(listener_String_or_Function as Function, listenerOwner) : listener_String_or_Function as String;
						var index:int = rUtils.getIndexInWeakClosureList(closureList, listenerName);
				
						if ( index >= 0 )
						{
							if ( !(closureList[index].reserved && _implicitlyRemoving) )
							{
								if ( type == rReflectionEvent.EVENT_TYPES_REMOVED )
								{
									addWeakReflectionListenerRemoved(listenerOwner, closureList[index]);
								}
								
								closureList.splice(index, 1);
								
								if ( closureList.length == 0 )
								{
									delete ownerDict[listenerOwner];
								}
							}
						}
					}
					
					if ( rUtils.isEmpty(ownerDict) )
					{
						delete _weakTypeMap[type];
						
						addTypeRemoved(type);
					}
				}
				
				if ( rUtils.isEmpty(_weakTypeMap) )
				{
					_weakTypeMap = null;
				}
			}
		}
		
		private function clearListenerFromStrongTypeMap(type:String, listener:Function):void
		{
			//--- Clear the listener from the strong type map if it exists.
			if ( _strongTypeMap )
			{
				var closureList:Vector.<rStrongMethodClosure> = _strongTypeMap[type];
				
				if ( closureList )
				{
					var index:int = rUtils.getIndexInStrongClosureList(closureList, listener);
					
					if ( index >= 0 )
					{						
						if ( !(closureList[index].reserved && _implicitlyRemoving) )
						{
							if ( type == rReflectionEvent.EVENT_TYPES_REMOVED )
							{
								addStrongReflectionListenerRemoved(closureList[index]);
							}
							
							closureList.splice(index, 1);
							
							if ( closureList.length == 0 )
							{
								delete _strongTypeMap[type];
							
								addTypeRemoved(type);
							}
						}
					}
				}
				
				if ( rUtils.isEmpty(_strongTypeMap) )
				{
					_strongTypeMap = null;
				}
			}
		}
		
		private function processMultiple(types:Array, listeners:Array, adding:Boolean, listenerOwner:Object, reserved:Boolean):void
		{
			var lastCallback:Function = null;
			var lastType:String = null;
			var typesLength:int = types.length;
			var listenersLength:int = listeners.length;
			var longestLength:int = Math.max(typesLength, listenersLength);
			
			for (var i:int = 0; i < longestLength; i++) 
			{
				var ithType:String = null;
				var ithCallback:Function = null;
				
				if ( i < typesLength )
				{
					ithType = types[i];
				}
				else
				{
					ithType = lastType;
				}
				
				if ( i < listenersLength )
				{
					ithCallback = listeners[i];
				}
				else
				{
					ithCallback = lastCallback;
				}
				
				if ( adding )
				{
					addEventListener(ithType, ithCallback, listenerOwner, reserved);
				}
				else
				{
					removeEventListener(ithType, ithCallback, listenerOwner);
				}
				
				lastType     = ithType;
				lastCallback = ithCallback;
			}
		}
		
		private var _suppressionTracker:int = 0;
		private var _typesAdded:Dictionary   = null;
		private var _typesRemoved:Dictionary = null;
		private var _reflectionsRemoved:Array = null;
		private var _implicitlyRemoving:Boolean = false;
		
		private function pushReflectionSuppression(implictRemoval:Boolean = false):void
		{
			if ( implictRemoval )
			{
				_implicitlyRemoving = true;
			}
			_suppressionTracker++;
		}
		
		private function popReflectionSuppression():void
		{
			_suppressionTracker--;
			
			if ( _suppressionTracker <= 0 )
			{
				_suppressionTracker = 0;
				_implicitlyRemoving = false;
				
				dispatchReflectionEvent();
			}
		}
		
		private function addTypeAdded(type:String):void
		{
			_typesAdded = _typesAdded ? _typesAdded : new Dictionary(false);
			
			_typesAdded[type] = true;
		}
		
		private function addTypeRemoved(type:String):void
		{
			_typesRemoved = _typesRemoved ? _typesRemoved : new Dictionary(false);
			
			_typesRemoved[type] = true;
		}
		
		private function addStrongReflectionListenerRemoved(closure:rStrongMethodClosure):void
		{
			_reflectionsRemoved = _reflectionsRemoved ? _reflectionsRemoved : [];
			
			_reflectionsRemoved.push(closure);
		}
		
		private function addWeakReflectionListenerRemoved(owner:Object, closure:rWeakMethodClosure):void
		{
			_reflectionsRemoved = _reflectionsRemoved ? _reflectionsRemoved : [];
			
			_reflectionsRemoved.push(closure);
			_reflectionsRemoved.push(owner);
		}
		
		private function dispatchReflectionEvent():void
		{
			if ( _typesAdded )
			{
				dispatchReflectionEvent_helper(_typesAdded, rReflectionEvent.EVENT_TYPES_ADDED);
			}
			else if ( _typesRemoved )
			{
				dispatchReflectionEvent_helper(_typesRemoved, rReflectionEvent.EVENT_TYPES_REMOVED);
			}
			
			function dispatchReflectionEvent_helper(dict:Dictionary, type:String):void
			{
				var reflectionEvent:rReflectionEvent = CACHED_REFLECTION_EVENT._inUse ? new rReflectionEvent() : CACHED_REFLECTION_EVENT;
				reflectionEvent.type = type;
				reflectionEvent._dict = dict;
				dispatchEvent(reflectionEvent);
				reflectionEvent._dict = _typesAdded = _typesRemoved = null;
				_reflectionsRemoved = null;
			}
		}
		
		public function toString():String
		{
			return null;
		}
	}
}

import flash.utils.Dictionary;
import qb2.revent.*;
import flash.utils.describeType;

internal class rStrongMethodClosure
{
	rev_friend var listener:Function;
	rev_friend var reserved:Boolean;
}

internal class rWeakMethodClosure
{
	rev_friend var listenerName:String;
	rev_friend var reserved:Boolean;
}

internal class rUtils
{
	use namespace rev_friend;
	
	private static const _cachedArray:Array = [];
	
	rev_friend static function getKeysFromDict(dictionary:Dictionary):Array
	{
		_cachedArray.length = 0;
		
		if ( dictionary )
		{
			for ( var key:* in dictionary )
			{
				_cachedArray.push(key);
			}
		}
		
		return _cachedArray;
	}
	rev_friend static function isEmpty(dictionary:Dictionary):Boolean
	{
		for ( var key:* in dictionary )
		{
			return false;
		}
		
		return true;
	}
	
	private static const methodNamesCache:Dictionary = new Dictionary(false);
	
	rev_friend static function getFunctionName(listener:Function, listenerOwner:Object):String
	{
		var classDef:Class = (listenerOwner as Object).constructor;
		var methodNames:Vector.<String> = methodNamesCache[classDef];
		
		var listenerName:String = null;
		
		if ( !methodNames )
		{
			methodNames = new Vector.<String>;
			var list:XMLList = describeType(classDef)..method; // <- not a typo...this is xml syntax.
			var listLength:int = list.length();
			for ( var i:int = 0; i < listLength; i++ )
			{
				var name:String = list[i].@name;
				methodNames.push(name);
				
				if ( listenerOwner[name] == listener )
				{
					listenerName = name;
				}
			}
			
			methodNamesCache[classDef] = methodNames;
		}
		
		if ( !listenerName )
		{
			var numNames:int = methodNames.length;
			for ( i = 0; i < numNames; i++ )
			{
				if ( listenerOwner[methodNames[i]] == listener )
				{
					listenerName = name;
					break;
				}
			}
		}
		
		if ( !listenerName )
		{
			throw new Error("The given listener is not a member of listenerOwner.");
		}
		
		return listenerName;
	}

	rev_friend static function getIndexInStrongClosureList(list:Vector.<rStrongMethodClosure>, listener:Function):int
	{
		var listLength:int = list.length;
		for (var i:int = 0; i < listLength; i++) 
		{
			if ( list[i].listener == listener )
			{
				return i;
			}
		}
		
		return -1;
	}
	
	rev_friend static function getIndexInWeakClosureList(list:Vector.<rWeakMethodClosure>, listenerName:String):int
	{
		var listLength:int = list.length;
		for (var i:int = 0; i < listLength; i++) 
		{
			if ( list[i].listenerName == listenerName )
			{
				return i;
			}
		}
		
		return -1;
	}
}