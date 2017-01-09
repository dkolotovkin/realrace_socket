package utils.showinterval {

	/**
	 * @author dkolotovkin
	 */
	public class ShowInterval {
		
		public var min:int;
		
		
		public function ShowInterval(min:int = 0, max:int = 0) {
			this.min = min;
		}
		
		
		public function contains (index:int):Boolean{
			return index >= min && index <= max;
		}
		
		
		
		
		public function toString() : String {
			return "{ min:"+min+", max:"+max+" }";
		}
		
		
	}
}