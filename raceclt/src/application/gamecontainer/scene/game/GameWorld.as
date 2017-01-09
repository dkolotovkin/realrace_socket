package application.gamecontainer.scene.game
{
	import application.GameApplication;
	import application.gamecontainer.scene.catalog.article.LibraryMovieClass;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import mx.core.UIComponent;
	
	import qb2.As3Math.consts.TO_DEG;
	import qb2.As3Math.consts.TO_RAD;
	import qb2.As3Math.geo2d.amPoint2d;
	import qb2.As3Math.geo2d.amVector2d;
	import qb2.Box2DAS.Common.V2;
	import qb2.Box2DAS.Dynamics.Joints.b2Joint;
	import qb2.Box2DAS.Dynamics.b2Body;
	import qb2.QuickB2.debugging.drawing.qb2_debugDrawSettings;
	import qb2.QuickB2.events.qb2UpdateEvent;
	import qb2.QuickB2.misc.acting.qb2FlashSpriteActor;
	import qb2.QuickB2.objects.tangibles.qb2World;
	import qb2.QuickB2.stock.qb2StageWalls;
	import qb2.QuickB2.stock.qb2TripSensor;
	import qb2.TopDown.objects.tdCarBody;
	import qb2.surrender.srVectorGraphics2d;
	
	import spark.components.VGroup;
	import spark.layouts.HorizontalAlign;
	
	import utils.game.GameContactListener;
	import utils.game.GameManagerEvent;
	import utils.game.action.GameType;
	import utils.interfaces.ISceneContent;
	import utils.models.car.CarModel;
	import utils.models.game.GameStatus;
	import utils.user.User;
	
	public class GameWorld extends VGroup implements ISceneContent
	{
		public const cameraPoint:amPoint2d = new amPoint2d();
		public const cameraTargetPoint:amPoint2d = new amPoint2d();
		
		public static var pressButtons:Object;
		
		public var qb2world:qb2World;
		public var worldBounds:Rectangle;
		
		private var bgBounds:Rectangle;
		
		public var roomID:int;
		public var districtID:int;
		public var keyBoardReaction:Boolean;
		public var iIsMember:Boolean;
		
		private var commongr:UIComponent;
		private var users:Array;
		private var cars:Array;
		private var colors:Array;
		private var carDriving:CarDriving;
		
		private var bgLayer:Sprite;
		private var rdLayer:Sprite;
		private var pmLayer:Sprite;
		private var decorLayer:Sprite;
		private var debugLayer:Sprite;
		private var roundTimer:MovieClip;
		private var roundTimerShadow:Sprite;
		
		private var _gameContainer:Sprite;
		
		private var startSensor:qb2TripSensor;
		private var finishSensor:qb2TripSensor;
		private var additionalZoneSensor:qb2TripSensor;
		private var myCar:tdCarBody;
		
		private var carBodies:Object;
		
		private var miniMapSid:int = -1;
		
		public function get gameContainer():Sprite
		{
			return _gameContainer;
		}
		
		private var _cameraRotation:Number = 0;
		
		public function get cameraRotation():Number 
		{  
			return _cameraRotation * TO_RAD;  
		}
		
		public function set cameraRotation(value:Number):void 
		{  
			_cameraRotation = value * TO_DEG;  
		}
		
		private var _cameraTargetRotation:Number = 0;
		
		public function get cameraTargetRotation():Number 
		{  
			return _cameraTargetRotation * TO_RAD;  
		}
		
		public function set cameraTargetRotation(value:Number):void
		{
			value = value * TO_DEG
			var modulus:Number = value >= 0 ? 360 : -360;
			var newValue:Number = value % modulus + 360;
			
			if (Math.abs(_cameraRotation - newValue) > 180)
			{
				if(_cameraRotation - newValue < 0)
					_cameraRotation += 360;
				else
					cameraRotation -= 360;
			}
			
			_cameraTargetRotation = newValue;
		}
		
		private var _stageWalls:qb2StageWalls = null;
		
		public function get stageWalls():qb2StageWalls 
		{  
			return _stageWalls;  
		}
		
		private var _locationXML:XML;
		
		public function get locationXML():XML
		{
			return _locationXML;
		}
		
		public function set locationXML(value:XML):void{
			_locationXML = value;
		}
		
		public function GameWorld(roomID:int, districtID:int, users:Array, cars:Array, colors:Array, gt:int):void
		{
			super();
			
			this.roomID = roomID;
			this.districtID = districtID;
			
			this.users = users;
			this.cars = cars;
			this.colors = colors;
			
			carBodies = new Object();
			
			GameApplication.app.models.gameModel.gameType = gt;
			if(gt == GameType.TEST_CONSTRUCTOR){
				this.locationXML = GameApplication.app.models.map.constructorMap;
			}else if(gt == GameType.TEST_TUTORIAL){
				this.locationXML = GameApplication.app.models.map.getMapXMLByID(0);
			}else{
				this.locationXML = GameApplication.app.models.map.getMapXMLByID(GameApplication.app.models.gameModel.mapID);
			}
			
			bgBounds = new Rectangle();
			bgBounds.width = GameApplication.app.models.gameModel.sceneVisibleWidth;
			bgBounds.height = GameApplication.app.models.gameModel.sceneVisibleHeight;
			
			worldBounds = new Rectangle();
			worldBounds.width = GameApplication.app.models.gameModel.sceneVisibleWidth;
			worldBounds.height = GameApplication.app.models.gameModel.sceneVisibleHeight;
			
			for(var i:int = 0; i < users.length; i++)
			{
				if(users[i] == GameApplication.app.userinfomanager.myuser.id)
				{
					iIsMember = true;
				}
			}

			qb2world = new qb2World();
			
			var contactListener:GameContactListener = new GameContactListener(this);
			qb2world.b2_world.SetContactListener(contactListener);
			
			commongr = new UIComponent();
			commongr.scrollRect = worldBounds;
			_gameContainer = new Sprite();
			
			bgLayer = new Sprite();
			_gameContainer.addChild(bgLayer);
			rdLayer = new Sprite();
			_gameContainer.addChild(rdLayer);
			debugLayer = new Sprite();
			_gameContainer.addChild(debugLayer);
			pmLayer = new Sprite();
			_gameContainer.addChild(pmLayer);
			decorLayer = new Sprite();
			_gameContainer.addChild(decorLayer);
			
//			_start = false;
			
			roundTimer = new TimerToStartMc();
			roundTimer.x = int(GameApplication.app.models.gameModel.sceneVisibleWidth / 2);
			roundTimer.y = int(GameApplication.app.models.gameModel.sceneVisibleHeight / 2);
			
			roundTimerShadow = new Sprite();
			roundTimerShadow.graphics.clear();
			roundTimerShadow.graphics.beginFill(0x0, .7);
			roundTimerShadow.graphics.drawRect(0, 0, GameApplication.app.models.gameModel.sceneVisibleWidth, GameApplication.app.models.gameModel.sceneVisibleHeight);
			roundTimerShadow.graphics.endFill();
			
			pressButtons = new Object();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddToStage, false, 0, true);
		}
		
		private function onTimeUpdate(e:GameManagerEvent):void{
			if(roundTimer){
				if(roundTimer.currentFrame == 1){
					roundTimer.gotoAndStop(2);
				}else if(roundTimer.currentFrame == 2){
					roundTimer.gotoAndStop(3);
				}else if(roundTimer.currentFrame == 3){
					roundTimer.gotoAndStop(4);
				}else if(roundTimer.currentFrame == 4){
					roundTimer.gotoAndStop(5);
				}else if(roundTimer.currentFrame == 5){
					roundTimer.gotoAndStop(6);
				}else{
					removeRoundTimer();
				}
			}
		}
		
		public function removeRoundTimer():void{
			if(roundTimer){
				if(commongr.contains(roundTimer)){
					commongr.removeChild(roundTimer);
				}
				if(commongr.contains(roundTimerShadow)){
					commongr.removeChild(roundTimerShadow);
				}
				roundTimer.stop();
				roundTimer = null;
				roundTimerShadow = null;
			}
		}
		
		private function onAddToStage(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);

			GameApplication.app.gamemanager.addEventListener(GameManagerEvent.TIMER_UPDATE, onTimeUpdate, false, 0, true);
			if(iIsMember)
			{
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
			visible = false;
			
			cameraPoint.set(worldBounds.width / 2, worldBounds.height / 2);
			cameraTargetPoint.copy(cameraPoint);
			
			qb2world.debugDragSource = this;
			qb2world.actor = gameContainer.addChild(new qb2FlashSpriteActor()) as qb2FlashSpriteActor;
			var debugDrawSprite:Sprite = (debugLayer.addChild(new Sprite()) as Sprite);
			debugDrawSprite.mouseEnabled = false;
			qb2world.debugDrawGraphics = new srVectorGraphics2d(debugDrawSprite.graphics);
			qb2world.realtimeUpdate = true;
			qb2world.maximumRealtimeStep = 1.0 / 10.0;
			qb2world.gravity.y = 10;
			qb2world.defaultPositionIterations = 10;
			qb2world.defaultVelocityIterations = 10;
			qb2world.start();
			qb2world.addEventListener(qb2UpdateEvent.POST_UPDATE, update);
			
			qb2_debugDrawSettings.boundBoxStartDepth = qb2_debugDrawSettings.boundBoxEndDepth = 2;
			qb2_debugDrawSettings.centroidStartDepth = qb2_debugDrawSettings.centroidEndDepth = 2;
			qb2_debugDrawSettings.boundCircleStartDepth = qb2_debugDrawSettings.boundCircleEndDepth = 2;
			qb2_debugDrawSettings.dynamicOutlineColor = qb2_debugDrawSettings.staticOutlineColor = 0x000000;
			
			if(GameApplication.app.models.gameModel.gameType != GameType.TEST_CONSTRUCTOR){
				qb2_debugDrawSettings.fillAlpha = 0;
				qb2_debugDrawSettings.outlineAlpha = 0;
			}
			
			_stageWalls = new qb2StageWalls(stage)
			_stageWalls.contactMaskFlags = 0;
			qb2world.addObject(_stageWalls);
			
			setTimeout(makeVisible, 5);

			carDriving = new CarDriving(this, qb2world);
			qb2world.addObject(carDriving);
			
			carDriving.world.gravity.set(0, 0);
			carDriving.world.gravityZ = 9.8;
			
			createWorldFromXML();
			
			var bmd:BitmapData = new BitmapData(bgBounds.width, bgBounds.height, true, 0xff0000)
			bmd.draw(rdLayer);
			GameApplication.app.gameContainer.chat.miniMapPanel.drawBg(bmd);
			
			var user:User;
			var carModel:CarModel;
			var myCarIndex:int = 0;
			for(var i:int = 0; i < users.length; i++)
			{		
				user = GameApplication.app.gameContainer.chat.getUserByRoomIdByUserId(roomID, (users[i]));
				if(user && user.id != GameApplication.app.userinfomanager.myuser.id)
				{
					if(user != null && i < cars.length && i < colors.length)
					{
						carModel = new CarModel();
						carModel.prototype = GameApplication.app.models.cars.getCarPrototypeById(cars[i]);
						carModel.color = colors[i];
						carBodies[user.id] = carDriving.addUserCar(user, carModel, i);
						
						GameApplication.app.gameContainer.chat.miniMapPanel.createUser(user);
					}
				}else{
					myCarIndex = i;
				}
			}
			
			if(iIsMember)
			{
				carModel = new CarModel();
				carModel.prototype = GameApplication.app.models.cars.getCarPrototypeById(GameApplication.app.userinfomanager.myuser.activeCar.prototype.id);
				carModel.color = GameApplication.app.userinfomanager.myuser.activeCar.color;
				myCar = carDriving.addUserCar(GameApplication.app.userinfomanager.myuser, carModel, myCarIndex);
				carBodies[GameApplication.app.userinfomanager.myuser.id] = myCar;
				
				GameApplication.app.gameContainer.chat.miniMapPanel.createUser(GameApplication.app.userinfomanager.myuser);
			}
			
			if (!qb2world.running)
			{
				qb2world.step();
			}
			
			miniMapSid = setInterval(updateMiniMap, 1000);
			updateMiniMap();
		}
		
		private function updateMiniMap():void{
			if(carBodies){
				var carBody:tdCarBody;
				for(var key:String in carBodies){
					carBody = carBodies[key];
					if(carBody){
						GameApplication.app.gameContainer.chat.miniMapPanel.setUserPosition(int(key), carBody.position.x, carBody.position.y);
					}
				}
			}
		}
		
		public function beginContact(obj1:*, obj2:*):void{
			if(obj1 == startSensor && obj2 == myCar || obj1 == myCar && obj2 == startSensor){
				if(GameApplication.app.models.gameModel.gameStatus != GameStatus.START_ON){
					GameApplication.app.models.gameModel.gameStatus = GameStatus.START_ON;
					GameApplication.app.gamemanager.sensorStart();
				}
			}else if(obj1 == finishSensor && obj2 == myCar || obj1 == myCar && obj2 == finishSensor){
				if(GameApplication.app.models.gameModel.gameStatus != GameStatus.FINISH_ON){
					GameApplication.app.models.gameModel.gameStatus = GameStatus.FINISH_ON;
					GameApplication.app.gamemanager.sensorFinish();
				}
			}else if(obj1 == additionalZoneSensor && obj2 == myCar || obj1 == myCar && obj2 == additionalZoneSensor){
				if(GameApplication.app.models.gameModel.gameStatus != GameStatus.ADDITIONAL_ZONE_ON){
					GameApplication.app.models.gameModel.gameStatus = GameStatus.ADDITIONAL_ZONE_ON;
					GameApplication.app.gamemanager.sensorAdditionalZone();
				}
			}
		}
		
		private function createWorldFromXML():void
		{
			var list:XMLList = locationXML.elements("*");
			for(var i:uint = 0; i < list.length(); i++)
			{
				if (list[i].name() == SceneElements.BACKGROUND){
					var bgSprite:Sprite = new Sprite();
					bgSprite.graphics.clear();
					
					var bgSkinClass:Class = LibraryMovieClass.getBgClassByDistrictID(districtID);
					var bgMc:MovieClip = new bgSkinClass();
					
					var bgBitmapData:BitmapData = new BitmapData(bgMc.width, bgMc.height); 
					bgBitmapData.draw(bgMc);
					bgSprite.graphics.beginBitmapFill(bgBitmapData, null, true, true);
					var bgWidth:Number = Math.min(GameApplication.app.constructor.maxSceneWidth, Math.max(GameApplication.app.constructor.minSceneWidth, locationXML.attribute("width")));
					var bgHeight:Number = Math.min(GameApplication.app.constructor.maxSceneHeight, Math.max(GameApplication.app.constructor.minSceneHeight, locationXML.attribute("height")));
					bgSprite.graphics.drawRect(0, 0, bgWidth, bgHeight);
					bgSprite.graphics.endFill();
					bgSprite.alpha = 1;

					bgLayer.addChild(bgSprite);
					
					bgBounds.width = locationXML.attribute("width");
					bgBounds.height = locationXML.attribute("height");
				}else if (list[i].name() == SceneElements.START){
					startSensor = carDriving.addStartSensor(list[i].@x, list[i].@y, list[i].@w, list[i].@h, list[i].@a);
					
					var startMc:StartMc = new StartMc();
					startMc.x = list[i].@x;
					startMc.y = list[i].@y;
					startMc.rotation = list[i].@a;
					decorLayer.addChild(startMc);
				}else if (list[i].name() == SceneElements.FINISH){
					finishSensor = carDriving.addFinishSensor(list[i].@x, list[i].@y, list[i].@w, list[i].@h, list[i].@a);
					
					var finishMc:FinishMc = new FinishMc();
					finishMc.x = list[i].@x;
					finishMc.y = list[i].@y;
					finishMc.rotation = list[i].@a;
					decorLayer.addChild(finishMc);
				}else if (list[i].name() == SceneElements.ADDITIONAL_ZONE){
					additionalZoneSensor = carDriving.addAdditioanlZoneSensor(list[i].@x, list[i].@y, list[i].@w, list[i].@h, list[i].@a)
				}else if (list[i].name() == SceneElements.TRANSITION){
					var transitionMc:TransitionMc = new TransitionMc();
					transitionMc.x = list[i].@x;
					transitionMc.y = list[i].@y;
					transitionMc.rotation = list[i].@a;
					decorLayer.addChild(transitionMc);
				}else if (list[i].name() == SceneElements.LIGHT1){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var light1Mc:Light1Mc = new Light1Mc();
					light1Mc.x = list[i].@x;
					light1Mc.y = list[i].@y;
					light1Mc.rotation = list[i].@a;
					decorLayer.addChild(light1Mc);
				}else if (list[i].name() == SceneElements.LIGHT2){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var light2Mc:Light2Mc = new Light2Mc();
					light2Mc.x = list[i].@x;
					light2Mc.y = list[i].@y;
					light2Mc.rotation = list[i].@a;
					decorLayer.addChild(light2Mc);
				}else if (list[i].name() == SceneElements.BUILDING1){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var building1Mc:Building1Mc = new Building1Mc();
					building1Mc.x = list[i].@x;
					building1Mc.y = list[i].@y;
					building1Mc.rotation = list[i].@a;
					decorLayer.addChild(building1Mc);
				}else if (list[i].name() == SceneElements.BUILDING2){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var building2Mc:Building2Mc = new Building2Mc();
					building2Mc.x = list[i].@x;
					building2Mc.y = list[i].@y;
					building2Mc.rotation = list[i].@a;
					decorLayer.addChild(building2Mc);
				}else if (list[i].name() == SceneElements.BUILDING3){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var building3Mc:Building3Mc = new Building3Mc();
					building3Mc.x = list[i].@x;
					building3Mc.y = list[i].@y;
					building3Mc.rotation = list[i].@a;
					decorLayer.addChild(building3Mc);
				}else if (list[i].name() == SceneElements.BUILDING4){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var building4Mc:Building4Mc = new Building4Mc();
					building4Mc.x = list[i].@x;
					building4Mc.y = list[i].@y;
					building4Mc.rotation = list[i].@a;
					decorLayer.addChild(building4Mc);
				}else if (list[i].name() == SceneElements.GARLAND1){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var garland1Mc:Garland1Mc = new Garland1Mc();
					garland1Mc.x = list[i].@x;
					garland1Mc.y = list[i].@y;
					garland1Mc.rotation = list[i].@a;
					decorLayer.addChild(garland1Mc);
				}else if (list[i].name() == SceneElements.GARLAND2){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var garland2Mc:Garland2Mc = new Garland2Mc();
					garland2Mc.x = list[i].@x;
					garland2Mc.y = list[i].@y;
					garland2Mc.rotation = list[i].@a;
					decorLayer.addChild(garland2Mc);
				}else if (list[i].name() == SceneElements.GARLAND3){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var garland3Mc:Garland3Mc = new Garland3Mc();
					garland3Mc.x = list[i].@x;
					garland3Mc.y = list[i].@y;
					garland3Mc.rotation = list[i].@a;
					decorLayer.addChild(garland3Mc);
				}else if (list[i].name() == SceneElements.TREE1){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var tree1Mc:Tree1Mc = new Tree1Mc();
					tree1Mc.x = list[i].@x;
					tree1Mc.y = list[i].@y;
					tree1Mc.rotation = list[i].@a;
					decorLayer.addChild(tree1Mc);
				}else if (list[i].name() == SceneElements.TREE2){
					if(!GameApplication.app.models.settings.showDecoration){
						continue;
					}
					var tree2Mc:Tree2Mc = new Tree2Mc();
					tree2Mc.x = list[i].@x;
					tree2Mc.y = list[i].@y;
					tree2Mc.rotation = list[i].@a;
					decorLayer.addChild(tree2Mc);
				}else if (list[i].name() == SceneElements.LAYOUTH){
					var layoutHSprite:Sprite = new Sprite();
					layoutHSprite.graphics.clear();
					
					var layoutHMc:MovieClip = new LayoutHMc();
					var layoutHBitmapData:BitmapData = new BitmapData(layoutHMc.width, layoutHMc.height, true, 0xff0000); 
					layoutHBitmapData.draw(layoutHMc);
					layoutHSprite.graphics.beginBitmapFill(layoutHBitmapData, null, true, true);
					layoutHSprite.graphics.drawRect(0, 0, list[i].@w, list[i].@h);
					layoutHSprite.graphics.endFill();
					layoutHSprite.x = list[i].@x - list[i].@w / 2;
					layoutHSprite.y = list[i].@y - list[i].@h / 2;
					
					decorLayer.addChild(layoutHSprite);
				}else if (list[i].name() == SceneElements.LAYOUTV){
					var layoutVSprite:Sprite = new Sprite();
					layoutVSprite.graphics.clear();
					
					var layoutVMc:MovieClip = new LayoutVMc();
					var layoutVBitmapData:BitmapData = new BitmapData(layoutVMc.width, layoutVMc.height, true, 0xff0000); 
					layoutVBitmapData.draw(layoutVMc);
					layoutVSprite.graphics.beginBitmapFill(layoutVBitmapData, null, true, true);
					layoutVSprite.graphics.drawRect(0, 0, list[i].@w, list[i].@h);
					layoutVSprite.graphics.endFill();
					layoutVSprite.x = list[i].@x - list[i].@w / 2;
					layoutVSprite.y = list[i].@y - list[i].@h / 2;
					
					decorLayer.addChild(layoutVSprite);
				}else if (list[i].name() == SceneElements.ROAD){
					var rdSprite:Sprite = new Sprite();
					rdSprite.graphics.clear();
					
					var rdMc:MovieClip = new RoadMc();
					var rdBitmapData:BitmapData = new BitmapData(rdMc.width, rdMc.height); 
					rdBitmapData.draw(rdMc);
					rdSprite.graphics.beginBitmapFill(rdBitmapData, null, true, true);
					rdSprite.graphics.drawRect(0, 0, list[i].@w, list[i].@h);
					rdSprite.graphics.endFill();
					rdSprite.x = list[i].@x - list[i].@w / 2;
					rdSprite.y = list[i].@y - list[i].@h / 2;
					
					rdLayer.addChild(rdSprite);
				}else if (list[i].name() == SceneElements.BORDERH){
					carDriving.addPavement(list[i].@x, list[i].@y, list[i].@w, 10);
				}else if (list[i].name() == SceneElements.BORDERV){
					carDriving.addPavement(list[i].@x, list[i].@y, 10, list[i].@h);
				}else if (list[i].name() == SceneElements.CAR){
					GameApplication.app.models.gameModel.carPoint = new Point(list[i].@x, list[i].@y);
					GameApplication.app.models.gameModel.carRotation = list[i].@a;
				}
			}
		}
		
		private function makeVisible():void
		{
			visible = true;
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			keyDown(int(event.keyCode));
		}
		
		private function keyDown(keyCode:int):void
		{
			if(!keyBoardReaction)
				return;
			
			switch(keyCode)
			{
				//left
				case 65:
				case 37:
				{
					if (!pressButtons[keyCode])
					{
						pressButtons[keyCode] = keyCode;
						userGotoLeft(GameApplication.app.userinfomanager.myuser.id, true, 0, 0, 0, 0, 0, true);
						GameApplication.app.gamemanager.goToLeft(true, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					}
					break;
				}
					//right
				case 68:
				case 39:
				{
					if (!pressButtons[keyCode])
					{ 
						pressButtons[keyCode] = keyCode;
						userGotoRight(GameApplication.app.userinfomanager.myuser.id, true, 0, 0, 0, 0, 0, true);
						GameApplication.app.gamemanager.goToRight(true, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					}
					break;					
				}
					//up
				case 87:
				case 38:
				{ 					
					if (!pressButtons[keyCode])
					{
						pressButtons[keyCode] = keyCode;
						userForward(GameApplication.app.userinfomanager.myuser.id, true, 0, 0, 0, 0, 0, true);
						GameApplication.app.gamemanager.forward(true, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					}
					break;
				}
					//down
				case 83:
				case 40: 
				{
					if (!pressButtons[keyCode])
					{
						pressButtons[keyCode] = keyCode;
						userBack(GameApplication.app.userinfomanager.myuser.id, true, 0, 0, 0, 0, 0, true);
						GameApplication.app.gamemanager.back(true, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					}
					break;
				}
					//space
				case 32:
				{ 			
					if (!pressButtons[keyCode])
					{
						pressButtons[keyCode] = keyCode;
						userBrake(GameApplication.app.userinfomanager.myuser.id, true, 0, 0, 0, 0, 0, true);
						GameApplication.app.gamemanager.brake(true, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					}
					break;
				}
					//ctrl
				case 17: break;
				default: break;
			}
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			keyUp(int(event.keyCode));
		}
		
		private function keyUp(keyCode:int):void
		{
			if(!keyBoardReaction)
				return;
			
			delete pressButtons[keyCode];
			switch(keyCode)
			{
				//left
				case 65:
				case 37:
				{ 			
					userGotoLeft(GameApplication.app.userinfomanager.myuser.id, false, 0, 0, 0, 0, 0, true);
					GameApplication.app.gamemanager.goToLeft(false, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					break;
				}
					//right
				case 68:
				case 39:
				{
					userGotoRight(GameApplication.app.userinfomanager.myuser.id, false, 0, 0, 0, 0, 0, true);
					GameApplication.app.gamemanager.goToRight(false, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					break;					
				}
					//up
				case 87:
				case 38:
				{
					userForward(GameApplication.app.userinfomanager.myuser.id, false, 0, 0, 0, 0, 0, true);
					GameApplication.app.gamemanager.forward(false, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					break;
				}
					//down
				case 83:
				case 40: 
				{
					userBack(GameApplication.app.userinfomanager.myuser.id, false, 0, 0, 0, 0, 0, true);
					GameApplication.app.gamemanager.back(false, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					break;
				}
					//space
				case 32:
				{
					userBrake(GameApplication.app.userinfomanager.myuser.id, false, 0, 0, 0, 0, 0, true);
					GameApplication.app.gamemanager.brake(false, carDriving.myCar.position.x, carDriving.myCar.position.y, carDriving.myCar.rotation, carDriving.myCar.b2_body.GetLinearVelocity().x, carDriving.myCar.b2_body.GetLinearVelocity().y);
					break;
				}
					//ctrl
				case 17: break;
				default: break;
			}
		}
		
		public function userGotoLeft(userID:int, down:Boolean, userx:Number, usery:Number, r:Number, lvx:Number, lvy:Number, ismyuser:Boolean = false):void
		{
			var car:tdCarBody = carDriving.cars[userID] as tdCarBody;
			
			if(car){
				if(!ismyuser)
				{
					car.position.x = userx;
					car.position.y = usery;
					car.rotation = r;
					car.b2_body.SetLinearVelocity(new V2(lvx, lvy));
				}
			}
			
			var carBrainController:KeyboardCarController = carDriving.carBrainControllers[userID] as KeyboardCarController;
			if(carBrainController)
			{
				carBrainController.left = down;
			}
		}
		
		public function userGotoRight(userID:int, down:Boolean, userx:Number, usery:Number, r:Number, lvx:Number, lvy:Number, ismyuser:Boolean = false):void
		{
			var car:tdCarBody = carDriving.cars[userID] as tdCarBody;
			if(car){
				if(!ismyuser)
				{
					car.position.x = userx;
					car.position.y = usery;
					car.rotation = r;
					car.b2_body.SetLinearVelocity(new V2(lvx, lvy));
				}
			}
			
			var carBrainController:KeyboardCarController = carDriving.carBrainControllers[userID] as KeyboardCarController;
			if(carBrainController)
			{
				carBrainController.right = down;
			}
		}
		
		public function userForward(userID:int, down:Boolean, userx:Number, usery:Number, r:Number, lvx:Number, lvy:Number, ismyuser:Boolean = false):void
		{
			var car:tdCarBody = carDriving.cars[userID] as tdCarBody;
			if(car){
				if(!ismyuser)
				{
					car.position.x = userx;
					car.position.y = usery;
					car.rotation = r;
					car.b2_body.SetLinearVelocity(new V2(lvx, lvy));
				}
			}
			
			var carBrainController:KeyboardCarController = carDriving.carBrainControllers[userID] as KeyboardCarController;
			if(carBrainController)
			{
				carBrainController.forward = down;
			}
		}
		
		public function userBack(userID:int, down:Boolean, userx:Number, usery:Number, r:Number, lvx:Number, lvy:Number, ismyuser:Boolean = false):void
		{
			var car:tdCarBody = carDriving.cars[userID] as tdCarBody;
			if(car){
				if(!ismyuser)
				{
					car.position.x = userx;
					car.position.y = usery;
					car.rotation = r;
					car.b2_body.SetLinearVelocity(new V2(lvx, lvy));
				}
			}
			
			var carBrainController:KeyboardCarController = carDriving.carBrainControllers[userID] as KeyboardCarController;
			if(carBrainController)
			{
				carBrainController.back = down;
			}
		}
		
		public function userBrake(userID:int, down:Boolean, userx:Number, usery:Number, r:Number, lvx:Number, lvy:Number, ismyuser:Boolean = false):void
		{
			var car:tdCarBody = carDriving.cars[userID] as tdCarBody;
			if(car){
				if(!ismyuser)
				{
					car.position.x = userx;
					car.position.y = usery;
					car.rotation = r;
					car.b2_body.SetLinearVelocity(new V2(lvx, lvy));
				}
			}
			
			var carBrainController:KeyboardCarController = carDriving.carBrainControllers[userID] as KeyboardCarController;
			if(carBrainController)
			{
				carBrainController.brake = down;
			}
		}
		
		public function myUserFinished():void
		{
			for each(var keyCode:int in pressButtons)
			{
				keyUp(keyCode);
			}
			keyBoardReaction = false;
		}
		
		private function update(evt:qb2UpdateEvent):void
		{
			var distanceCut:Number  = .05;
			var snapDistance:Number = .2;
			var snapRotation:Number = .01;
			
			if (cameraPoint.distanceTo(cameraTargetPoint) <= snapDistance)
			{
				cameraPoint.copy(cameraTargetPoint);
			}
			else
			{
				var vec:amVector2d = cameraTargetPoint.minus(cameraPoint);
				vec.scaleBy(distanceCut);
				cameraPoint.translateBy(vec);
			}
			
			if (_cameraRotation != _cameraTargetRotation)
			{
				var rotMove:Number = _cameraTargetRotation - _cameraRotation;
				if (Math.abs(rotMove) < snapRotation)
				{
					_cameraRotation = _cameraTargetRotation;
				}
				else
				{
					rotMove *= distanceCut;
					_cameraRotation += rotMove;
				}
			}
			gameContainer.x = Math.max(worldBounds.width - bgBounds.width, Math.min(0, -cameraPoint.x + worldBounds.width / 2));
			gameContainer.y = Math.max(worldBounds.height - bgBounds.height, Math.min(0, -cameraPoint.y + worldBounds.height / 2));
		}
		
		public function destroyWorld():void
		{
			if(miniMapSid != -1){
				clearInterval(miniMapSid);
				miniMapSid = -1;
			}
			
			if(qb2world)
			{
				qb2world.removeEventListener(qb2UpdateEvent.POST_UPDATE, update);
			}
			
			GameApplication.app.gamemanager.removeEventListener(GameManagerEvent.TIMER_UPDATE, onTimeUpdate);
			
			if(iIsMember)
			{
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			}
			
			try{
				for (var bb:b2Body = qb2world.b2_world.m_bodyList; bb; bb = bb.m_next)
				{
					destroyBody(bb);
				}
				for (var jj:b2Joint = qb2world.b2_world.m_jointList; jj; jj = jj.m_next)
				{
					qb2world.b2_world.DestroyJoint(jj);
				}
			}catch(e:*){
				trace("destroyWorld error: " + e);
			}
			
			carDriving.destroy();
			carDriving = null;
			
			commongr.removeChild(_gameContainer);
			removeElement(commongr);
		}
		
		public function destroyBody(bb:b2Body): void 
		{
			qb2world.b2_world.DestroyBody(bb);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			percentWidth = 100;
			
			horizontalAlign = HorizontalAlign.CENTER;
			
			commongr.addChild(gameContainer);
			commongr.addChild(roundTimerShadow);
			commongr.addChild(roundTimer);
			addElement(commongr);
		}
		
		public function onHide():void
		{
		}
	}
}