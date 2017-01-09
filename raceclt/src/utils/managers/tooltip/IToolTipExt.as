package utils.managers.tooltip {

	import mx.core.IToolTip;
	
	public interface IToolTipExt extends IToolTip{
		
		function set target (value:IToolTiped):void;
		
		function show(dx : int,dy : int) : void;
		
	}
}
