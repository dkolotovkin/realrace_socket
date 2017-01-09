package utils.brush
{
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;

	public class BrushManager
	{
		public function BrushManager()
		{
		}
		
		public static function brush(color:uint, dObject:DisplayObject):void{
			var matrix:Array = new Array();
			matrix = matrix.concat([(color >> 16) / 0xff, 0, 0, 0, 0]);
			matrix = matrix.concat([0, ((color >> 8) & 0xff) / 0xff, 0, 0, 0]);
			matrix = matrix.concat([0, 0, (color & 0x00ff) / 0xff, 0, 0]);
			matrix = matrix.concat([0, 0, 0, 1, 0]);
			dObject.filters = [new ColorMatrixFilter(matrix)];
		}
		
		public static function unBrush(dObject:DisplayObject):void{
			dObject.filters = [];
		}
	}
}