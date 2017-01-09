package application.components.usertitle
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	public class UserTitle extends Sprite
	{
		private var _tf:TextField = new TextField();
		private var _source:MovieClip;
		
		public function set sourcevisible(value:Boolean):void{
			_source.visible = value;
		}
		
		public function set titlevisible(value:Boolean):void{
			_tf.visible = value;
		}
		
		public function UserTitle(title:String, level:int, ismyuser:Boolean)
		{
			super();
			
			var tfn:TextFormat = new TextFormat();
			tfn.align = TextAlign.CENTER;
			if(ismyuser){
				tfn.bold = true;
				tfn.color = "0xCCFF66";
			}else{
				tfn.color = "0x999999";
			}
			tfn.size = 12;
			
			var tfl:TextFormat = new TextFormat();
			if(ismyuser){
				tfl.bold = true;
				tfl.color = "0x00FFFF";
			}else{
				tfl.color = "0xcccccc";
			}			
			tfl.size = 12;
			
			_tf.selectable = false		
			_tf.text = title + " [" + String(level) + "]";
			_tf.setTextFormat(tfn, 0, title.length);
			_tf.setTextFormat(tfl, title.length, _tf.text.length);		
			
			addChild(_tf);
			
			_source = new CheeseSkin();
			_source.width = 15;
			_source.height = 9;
			addChild(_source);
			_source.x = _tf.width / 2;
			_source.y = 23;
			_source.visible = false;
		}
	}
}