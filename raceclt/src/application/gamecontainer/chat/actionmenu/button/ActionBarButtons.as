package application.gamecontainer.chat.actionmenu.button {
	/**
	 * @author dkolotovkin
	 */
	public class ActionBarButtons {
		
		private static var _hash:Object;
		
		public static function getClassByType (type:String):Class {
			if (!_hash){
				init ();
			}
			return _hash[type];
		}
		
		private static function init() : void {
			_hash = new Object ();
			/*_hash[Actions.MOVE_THING] = ButtonMoveThing;
			_hash[Actions.RESTORE] = AButtonRestore;
			_hash[Actions.CLEAN] = AButtonClean;
			_hash[Actions.SALE] = AButtonSale;*/
		}
	}
}