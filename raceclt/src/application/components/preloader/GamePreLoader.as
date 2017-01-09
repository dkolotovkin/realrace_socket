package application.components.preloader 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	import mx.preloaders.DownloadProgressBar;
	import mx.preloaders.SparkDownloadProgressBar;
	
	public class GamePreLoader extends SparkDownloadProgressBar
	{		
		private var _displayStartCount:uint = 0;
		private var _initProgressCount:uint = 0;
		private var _downloadComplete:Boolean = false;
		private var _showingDisplay:Boolean = false;
		private var _startTime:int;
		private var preloaderDisplay:PreLoaderMC;
		private var numberRslTotal:Number = 1;
		private var numberRslCurrent:Number = 1;
		
		private var _gf:GlowFilter = new GlowFilter(0x000000, 1, 20, 20, 2);		
		private var colors:Array = [0x0F1312, 0x032F38, 0x000308];
		private var alphas:Array = [1, 1, 1];
		private var ratios:Array = [0, 125, 255];
		private var matr:Matrix = new Matrix();
		
		public function GamePreLoader()
		{
			super();
		}
		
		override protected function initCompleteHandler(event:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		override protected function createChildren():void
		{
			matr.createGradientBox(stageWidth, stageHeight, -Math.PI / 2, 0, 0);
			
			var mc:MovieClip = new BackGround();
			var overmc:Sprite = new Sprite();
			overmc.graphics.beginFill(0x0, .8);
			overmc.graphics.drawRect(0, 0, mc.width, mc.height);
			overmc.graphics.endFill();
			mc.addChild(overmc);
			var bitmapData:BitmapData = new BitmapData(mc.width, mc.height);
			bitmapData.draw(mc);
			
			graphics.clear();			
			graphics.beginBitmapFill(bitmapData);
			graphics.drawRect(0, 0, stageWidth, stageHeight);
			graphics.endFill();
			
			if (!preloaderDisplay) {
				preloaderDisplay = new PreLoaderMC();
				
				var startX:Number = Math.round((stageWidth - preloaderDisplay.width) / 2);
				var startY:Number = Math.round((stageHeight - preloaderDisplay.height) / 2);
				
				preloaderDisplay.x = startX;
				preloaderDisplay.y = startY;
				addChild(preloaderDisplay);
			}
		}
		
		override protected function progressHandler(evt:ProgressEvent):void {
			if (preloaderDisplay) {
				var progressApp:Number = Math.round((evt.bytesLoaded/evt.bytesLoaded)*100);
				
				preloaderDisplay["percent_txt"].text = "Загрузка " + progressApp + "%";
				preloaderDisplay["percent_mc"].width = 186 * progressApp / 100;
			}else{
				show();
			}
		}
		
		override protected function rslProgressHandler(evt:RSLEvent):void {
			if (evt.rslIndex && evt.rslTotal) {				
				var progressRsl:Number = Math.round((evt.bytesLoaded/evt.bytesTotal)*100);
				
				preloaderDisplay["percent_txt"].text = "Загрузка " + progressRsl + "%";
				preloaderDisplay["percent_mc"].width = 186 * progressRsl / 100;
			}
		}
		
		
		override protected function setDownloadProgress(completed:Number, total:Number):void {
			if (preloaderDisplay) {
			}
		}
		
		override protected function setInitProgress(completed:Number, total:Number):void {
			if (preloaderDisplay) {
				var progress:Number = Math.round((completed / total) * 100);
				
				preloaderDisplay["percent_txt"].text = "Загрузка " + progress + "%";
				preloaderDisplay["percent_mc"].width = 186 * progress / 100;
			}
		} 
		
		override protected function initProgressHandler(event:Event):void {
			var elapsedTime:int = getTimer() - _startTime;
			_initProgressCount++;
			
			if (!_showingDisplay &&	showDisplayForInit(elapsedTime, _initProgressCount)) {
				_displayStartCount = _initProgressCount;
				show();
				setDownloadProgress(100, 100);
			}
			
			if (_showingDisplay) {
				if (!_downloadComplete) {
					setDownloadProgress(100, 100);
				}
				setInitProgress(_initProgressCount, initProgressTotal);
			}
		}
		
		private function show():void
		{
			if (stageWidth == 0 && stageHeight == 0)
			{
				try
				{
					stageWidth = stage.stageWidth;
					stageHeight = stage.stageHeight
				}
				catch (e:Error)
				{
					stageWidth = loaderInfo.width;
					stageHeight = loaderInfo.height;
				}
				if (stageWidth == 0 && stageHeight == 0)
					return;
			}
			
			_showingDisplay = true;
			createChildren();
		}
	}
}