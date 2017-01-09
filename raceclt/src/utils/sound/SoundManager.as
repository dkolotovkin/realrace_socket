package utils.sound
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Tween;

	public class SoundManager
	{
		private var bgSoundClasses:ArrayCollection;
		private var gameSoundClass:Class;
		
		private var bgSound:Sound;
		private var bgSoundChannel:SoundChannel;
		private var bgSoundTransform:SoundTransform;
		
		private var gameSound:Sound;
		private var gameSoundChannel:SoundChannel;
		private var gameSoundTransform:SoundTransform;
		
		private var soundTween:Tween;
		
		private var musicLoaded:Boolean;
		
		private var bgSoundInterval:int = -1;
		
		public function SoundManager()
		{
//			bgSoundClasses = new ArrayCollection();
//			
//			ChangeWatcher.watch(GameApplication.app.models.settings, "musicOn", onChangeMusicOn);
//			ChangeWatcher.watch(GameApplication.app.models.settings, "musicVolume", onChangeMusicVolume);
//			ChangeWatcher.watch(GameApplication.app.models.settings, "gameRunning", onChangeGameRunning);
//			
//			var loader:Loader = new Loader();
//			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
//			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
//			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
//			loader.load(new URLRequest("http://cs6086.userapi.com/u3450745/a1356881812a55.zip"));
		}
		
		private function onError(e:Event):void{
		}
		
		private function onLoad(e:Event):void{
//			bgSoundClasses.addItem((e.target as LoaderInfo).applicationDomain.getDefinition("bgSound1") as Class);
//			bgSoundClasses.addItem((e.target as LoaderInfo).applicationDomain.getDefinition("bgSound2") as Class);
//			gameSoundClass = (e.target as LoaderInfo).applicationDomain.getDefinition("gameSound") as Class;
//			musicLoaded = true;
//			
//			backGroundSoundStart();
		}
		
		private function onChangeGameRunning(value:Event):void
		{
//			if(GameApplication.app.models.settings.gameRunning){
//				backGroundSoundStart();
//			}else{
//				backGroundSoundStop();
//			}
		}
		
		private function onChangeMusicOn(value:Event):void
		{
//			if(GameApplication.app.models.settings.musicOn){
//				backGroundSoundStart();
//			}else{
//				backGroundSoundStop();
//			}
		}
		
		private function onChangeMusicVolume(value:Event):void
		{
//			if(bgSoundChannel){	
//				bgSoundTransform = bgSoundChannel.soundTransform;
//				bgSoundTransform.volume = GameApplication.app.models.settings.musicVolume / 100;				
//				bgSoundChannel.soundTransform = bgSoundTransform;
//			}
		}
		
		private function backGroundSoundStart():void{
//			if(bgSoundInterval != -1){
//				clearInterval(bgSoundInterval);
//				bgSoundInterval = -1;
//			}
//			
//			if(musicLoaded && GameApplication.app.models.settings.gameRunning && GameApplication.app.models.settings.musicOn){
//				var musicClass:Class = bgSoundClasses.getItemAt(Math.round(Math.random() * (bgSoundClasses.length - 1))) as Class;
//				bgSound = new musicClass();
//				
//				if(bgSoundChannel){
//					bgSoundChannel.stop();
//				}
//				bgSoundChannel = bgSound.play(0, 2);
//				bgSoundChannel.addEventListener(Event.SOUND_COMPLETE, onBgSoundComplete);
//				
//				bgSoundTransform = bgSoundChannel.soundTransform;
//				var volume:Number = 0;
//				if(!GameApplication.app.gamemanager.gameMode){
//					volume = GameApplication.app.models.settings.musicVolume / 100;
//				}
//				bgSoundTransform.volume = volume;
//				bgSoundChannel.soundTransform = bgSoundTransform;
//			}
		}
		
		private function onBgSoundComplete(e:Event):void{
//			if(bgSoundInterval != -1){
//				clearInterval(bgSoundInterval);
//				bgSoundInterval = -1;
//			}
//			
//			bgSoundInterval = setInterval(backGroundSoundStart, (30 + Math.round(Math.random() * 30)) * 1000);
		}
		
		public function backGroundSoundStop():void{
//			if(bgSoundInterval != -1){
//				clearInterval(bgSoundInterval);
//				bgSoundInterval = -1;
//			}
//			
//			if(bgSoundChannel){
//				bgSoundChannel.stop();
//			}
		}
		
		public function gameSoundStart():void{
//			if(GameApplication.app.models.settings.musicOn){
//				if(soundTween){	
//					soundTween.stop();
//					soundTween = null;
//				}
//				
//				bgSoundTransform = bgSoundChannel.soundTransform;
//				bgSoundTransform.volume = 0;				
//				bgSoundChannel.soundTransform = bgSoundTransform;
//				
//				if(musicLoaded && GameApplication.app.models.settings.gameRunning){
//					gameSound = new gameSoundClass();
//					
//					if(gameSoundChannel){
//						gameSoundChannel.stop();
//					}
//					gameSoundChannel = gameSound.play(0, int.MAX_VALUE);
//					
//					gameSoundTransform = gameSoundChannel.soundTransform;
//					gameSoundTransform.volume = GameApplication.app.models.settings.musicVolume / 100;
//					gameSoundChannel.soundTransform = gameSoundTransform;
//				}
//			}
		}
		
		public function gameSoundEnd():void{
//			if(GameApplication.app.models.settings.musicOn){
//				if(soundTween){
//					soundTween.stop();
//					soundTween = null;
//				}
//				soundTween = new Tween(bgSoundChannel.soundTransform, 0, GameApplication.app.models.settings.musicVolume / 100, 2000, -1, onBgVolumeChange, endTweenBgChange);
//				
//				if(gameSoundChannel){
//					gameSoundChannel.stop();
//				}
//			}
		}
		
		private function onBgVolumeChange(value:Number):void{
//			if(bgSoundChannel){	
//				bgSoundTransform = bgSoundChannel.soundTransform;
//				bgSoundTransform.volume = value;				
//				bgSoundChannel.soundTransform = bgSoundTransform;
//			}
		}
		
		private function endTweenBgChange(value:Number):void{
//			onBgVolumeChange(value);
//			
//			if(soundTween){	
//				soundTween.stop();
//				soundTween = null;
//			}
		}
		
		public function play(type:int):void{
//			if(GameApplication.app.models.settings.soundsOn){
//				var sound:Sound;
//				if(type == SoundType.CLICK){
//					sound = new ClickSound();
//				}else if(type == SoundType.SEND_MESSAGE){
//					sound = new SendMessageSound();
//				}else if(type == SoundType.RECIVE_MESSAGE){
//					sound = new MessageSound();
//				}else if(type == SoundType.GAME_USER_ACTION){
//					sound = new GameUserActionSound();
//				}else if(type == SoundType.FIND_SOURCE){
//					sound = new GameSourceSound();
//				}else if(type == SoundType.FIND_EXIT){
//					sound = new GameExitSound();
//				}else if(type == SoundType.QUESTION_SOUND){
//					sound = new QuestionSound()
//				}
//				
//				if(sound){
//					var channel:SoundChannel = sound.play(0, 1);								
//					
//					var stransform:SoundTransform = channel.soundTransform;
//					stransform.volume = GameApplication.app.models.settings.musicVolume / 100;
//					channel.soundTransform = stransform;
//				}
//			}
		}
	}
}