package application.components.popup.rentCar
{
	import application.components.popup.PopUpTitled;
	
	import utils.models.car.CarPrototypeModel;
	
	public class PopUpRentCar extends PopUpTitled
	{
		private var content:RentCarContent;
		private var prototype:CarPrototypeModel;
		
		public function PopUpRentCar(p:CarPrototypeModel)
		{
			super();
			
			prototype = p;
			
			content = new RentCarContent();
			content.prototype = prototype;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(content);
		}
	}
}