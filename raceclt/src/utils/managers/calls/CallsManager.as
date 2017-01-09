package utils.managers.calls
{
	import application.GameApplication;
	
	import flash.errors.IOError;
	import flash.net.Responder;
	import flash.net.Socket;
	
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;
	import utils.vk.api.serialization.json.JSON;

	public class CallsManager
	{
		private var _socket:Socket;
		private var _callBacks:Object;
		
		public function CallsManager(s:Socket)
		{
			_socket = s;
			_callBacks = new Object();
		}
		
		public function call(command:int, callback:Function, 
							 p1:* = null, p2:* = null, p3:* = null, p4:* = null, p5:* = null, 
							 p6:* = null, p7:* = null, p8:* = null, p9:* = null, p10:* = null, p11:* = null):void{
			var jsonObj:Object = new Object();
			
			addParam(jsonObj, ProtocolKeys.COMMAND, command);
			addParam(jsonObj, ProtocolKeys.PARAM1, p1);
			addParam(jsonObj, ProtocolKeys.PARAM2, p2);
			addParam(jsonObj, ProtocolKeys.PARAM3, p3);
			addParam(jsonObj, ProtocolKeys.PARAM4, p4);
			addParam(jsonObj, ProtocolKeys.PARAM5, p5);
			addParam(jsonObj, ProtocolKeys.PARAM6, p6);
			addParam(jsonObj, ProtocolKeys.PARAM7, p7);
			addParam(jsonObj, ProtocolKeys.PARAM8, p8);
			addParam(jsonObj, ProtocolKeys.PARAM9, p9);
			addParam(jsonObj, ProtocolKeys.PARAM10, p10);
			addParam(jsonObj, ProtocolKeys.PARAM11, p11);
			
			if(callback != null){
				var callBackId:int;
				do{					
					callBackId = Math.round(Math.random() * 1000000);
				}while(_callBacks[callBackId] || callBackId == 0);
				
				_callBacks[callBackId] = callback;
				addParam(jsonObj, ProtocolKeys.CALLBACKID, callBackId);
			}
			
			if(_socket){
				try{
					_socket.writeUTFBytes(JSON.encode(jsonObj) + GameApplication.app.config.lineSeparator);
					_socket.flush();
				}
				catch(e:IOError){
					trace(e);
				}
			}
			
//			trace("CallsManager: " + JSON.encode(jsonObj) + GameApplication.app.config.lineSeparator);
			return;
		}
		
		private function addParam(jsonObj:Object, key:String, value:*):void{
			var type:String = typeof(value);
			if(type == "number"){
				jsonObj[key] = value;
			}else{
				if(value)
					jsonObj[key] = value;				
			}
		}
		
		public function callBack(cbid:int, obj:*):void{
			var callbackFunction:Function = _callBacks[cbid];
			if(callbackFunction != null){
				delete _callBacks[cbid];
				callbackFunction(obj);
			}
		}
	}
}