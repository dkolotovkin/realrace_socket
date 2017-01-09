package utils.models
{
	import application.GameApplication;
	
	import flash.display.StageQuality;

	public class SettingsModel
	{
		[Bindable]
		public var gameRunning:Boolean;
		public var presentMessagesVisible:Boolean;
		public var systemMessagesVisible:Boolean;
		public var banMessagesVisible:Boolean;
		public var privateMessagesVisible:Boolean;
		public var userTitlesInGameVisible:Boolean;
		
		public var stageQuality:String;
		[Bindable]
		public var chatVisible:Boolean;
		[Bindable]
		public var soundsOn:Boolean;
		[Bindable]
		public var musicOn:Boolean;
		[Bindable]
		public var musicVolume:Number;
		
		public var exitFromGameWarning:Boolean;
		
		public var showDecoration:Boolean;
		
		public function SettingsModel(){
		}
		
		public function init():void{
			if(GameApplication.app.so.data["presentMessagesVisible"] == undefined || GameApplication.app.so.data["presentMessagesVisible"] == "undefined"){
				presentMessagesVisible = true;
			}else{
				presentMessagesVisible = Boolean(GameApplication.app.so.data["presentMessagesVisible"]);
			}
			
			if(GameApplication.app.so.data["systemMessagesVisible"] == undefined || GameApplication.app.so.data["systemMessagesVisible"] == "undefined"){
				systemMessagesVisible = true;
			}else{
				systemMessagesVisible = Boolean(GameApplication.app.so.data["systemMessagesVisible"]);
			}
			
			if(GameApplication.app.so.data["banMessagesVisible"] == undefined || GameApplication.app.so.data["banMessagesVisible"] == "undefined"){
				banMessagesVisible = true;
			}else{
				banMessagesVisible = Boolean(GameApplication.app.so.data["banMessagesVisible"]);
			}
			
			if(GameApplication.app.so.data["privateMessagesVisible"] == undefined || GameApplication.app.so.data["privateMessagesVisible"] == "undefined"){
				privateMessagesVisible = true;
			}else{
				privateMessagesVisible = Boolean(GameApplication.app.so.data["privateMessagesVisible"]);
			}
			
			if(GameApplication.app.so.data["userTitlesInGameVisible"] == undefined || GameApplication.app.so.data["userTitlesInGameVisible"] == "undefined"){
				userTitlesInGameVisible = true;
			}else{
				userTitlesInGameVisible = Boolean(GameApplication.app.so.data["userTitlesInGameVisible"]);
			}
			
			if(GameApplication.app.so.data["stageQuality"] == undefined || GameApplication.app.so.data["stageQuality"] == "undefined"){
				stageQuality = StageQuality.HIGH;
			}else{
				stageQuality = String(GameApplication.app.so.data["stageQuality"]);
			}
			
			if(GameApplication.app.so.data["chatVisible"] == undefined || GameApplication.app.so.data["chatVisible"] == "undefined"){
				chatVisible = true;
			}else{
				chatVisible = Boolean(GameApplication.app.so.data["chatVisible"]);
			}
			
			if(GameApplication.app.so.data["soundsOn"] == undefined || GameApplication.app.so.data["soundsOn"] == "undefined"){
				soundsOn = true;
			}else{
				soundsOn = Boolean(GameApplication.app.so.data["soundsOn"]);
			}
			
			if(GameApplication.app.so.data["musicOn"] == undefined || GameApplication.app.so.data["musicOn"] == "undefined"){
				musicOn = true;
			}else{
				musicOn = Boolean(GameApplication.app.so.data["musicOn"]);
			}
			
			if(GameApplication.app.so.data["musicVolume"] == undefined || GameApplication.app.so.data["musicVolume"] == "undefined"){
				musicVolume = 50;
			}else{
				musicVolume = Number(GameApplication.app.so.data["musicVolume"]);
			}
			
			if(GameApplication.app.so.data["exitFromGameWarning"] == undefined || GameApplication.app.so.data["exitFromGameWarning"] == "undefined"){
				exitFromGameWarning = true;
			}else{
				exitFromGameWarning = Boolean(GameApplication.app.so.data["exitFromGameWarning"]);
			}
			
			if(GameApplication.app.so.data["showDecoration"] == undefined || GameApplication.app.so.data["showDecoration"] == "undefined"){
				showDecoration = true;
			}else{
				showDecoration = Boolean(GameApplication.app.so.data["showDecoration"]);
			}
		}
	}
}