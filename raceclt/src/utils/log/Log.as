package utils.log
{
	import mx.collections.ArrayCollection;

	public class Log
	{
		public static const maxMessagesCount:int = 100;
		
		[Bindable]
		public static var messages:ArrayCollection = new ArrayCollection();
		
		public function Log()
		{ 
		}
		
		public static function add(text:String):void{
			messages.addItem(text);
			if(messages.length > maxMessagesCount){
				messages.removeItemAt(0);
			}
		}
		
		public static function clear():void{
			messages = new ArrayCollection();
		}
	}
}