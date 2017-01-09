package utils.models.car
{
	import application.GameApplication;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class CarModel
	{
		public var id:int;
		public var prototype:CarPrototypeModel;
		[Bindable]
		public var color:int;
		[Bindable]
		public var durability:Number;
		public var durabilityMax:Number = 100;
		
		public var rented:uint = 0;
		
		private var rentTimer:Timer;
		
		private var _rentTime:int = 0;
		
		[Bindable]
		public function get rentTime():int{
			return _rentTime;
		}
		
		public function set rentTime(value:int):void{
			if(value == 0)
			{
				if(rented == 1)
				{
					removeThis();
				}
				return;
			}
			
			_rentTime = value;
			
			if(rentTimer){
				rentTimer.removeEventListener(TimerEvent.TIMER, onRentTimer);
				rentTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onRentTimerComplete);
				rentTimer.reset();
				rentTimer = null;
			}
			
			rentTimer = new Timer(1000, _rentTime);
			rentTimer.addEventListener(TimerEvent.TIMER, onRentTimer, false, 0, true);
			rentTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onRentTimerComplete, false, 0, true);
			rentTimer.start();
		}
		
		
		public function CarModel()
		{
		}
		
		private function onRentTimer(e:TimerEvent):void{
			rentTime--;
		}
		
		private function onRentTimerComplete(e:TimerEvent):void{
			if(rented == 1)
			{
				removeThis();
			}
		}
		
		private function removeThis():void{
			if(GameApplication.app.userinfomanager.myuser.activeCar){
				if(GameApplication.app.userinfomanager.myuser.activeCar.id == id){
					GameApplication.app.userinfomanager.myuser.activeCar = GameApplication.app.userinfomanager.myuser.cars.getItemAt(0) as CarModel;
				}
			}
			
			var cm:CarModel;
			for(var i:int = 0; i < GameApplication.app.userinfomanager.myuser.cars.length; i++){
				cm = GameApplication.app.userinfomanager.myuser.cars.getItemAt(i) as CarModel;
				if(cm && cm.id == id){
					GameApplication.app.userinfomanager.myuser.cars.removeItemAt(i);
					return;
				}
			}
		}
	}
}