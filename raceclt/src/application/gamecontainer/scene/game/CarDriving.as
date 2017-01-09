package application.gamecontainer.scene.game
{
	import application.GameApplication;
	import application.gamecontainer.scene.catalog.article.LibraryMovieClass;
	
	import flash.display.*;
	
	import qb2.As3Math.consts.*;
	import qb2.As3Math.general.*;
	import qb2.As3Math.geo2d.*;
	import qb2.QuickB2.events.*;
	import qb2.QuickB2.misc.acting.qb2FlashSpriteActor;
	import qb2.QuickB2.misc.acting.qb2IActor;
	import qb2.QuickB2.objects.tangibles.*;
	import qb2.QuickB2.stock.*;
	import qb2.TopDown.ai.*;
	import qb2.TopDown.ai.brains.*;
	import qb2.TopDown.ai.controllers.*;
	import qb2.TopDown.carparts.*;
	import qb2.TopDown.debugging.*;
	import qb2.TopDown.objects.*;
	import qb2.TopDown.stock.*;
	
	import utils.brush.BrushManager;
	import utils.chat.Flasher;
	import utils.game.action.GameType;
	import utils.models.car.CarModel;
	import utils.user.User;
	
	public class CarDriving extends qb2Group
	{
		public var map:tdMap;
				
		private var qb2world:qb2World; 
		private var gameWorld:GameWorld;
		private var center:amPoint2d;
		
		public var myCar:tdCarBody;
		public var cars:Object;
		public var carBrainControllers:Object;
		
		public function CarDriving(gw:GameWorld, world:qb2World) 
		{
			qb2world = world;
			gameWorld = gw;
			
			map = new tdMap();
			map.actor = new qb2FlashSpriteActor();
			
			actor = new qb2FlashSpriteActor();
			
			center = new amPoint2d(gameWorld.worldBounds.width / 2, gameWorld.worldBounds.height / 2);
			
			//создаем / задаем границы карты
			var defaultTerrain:tdTerrain = new tdTerrain(true);
			defaultTerrain.frictionZMultiplier = 1.5;
			map.addObject(defaultTerrain);
			
			addObject(map);
				
			cars = new Object();
			carBrainControllers = new Object();
		}
		
		public function addPavement(px:Number, py:Number, pw:Number, ph:Number):void{
			
			var actor:qb2FlashSpriteActor = new qb2FlashSpriteActor();
			
			var skin:Sprite = new Sprite();
			skin.graphics.clear();
			
			var pavementMC:MovieClip;
			if(pw > ph){
				pavementMC = new BorderHMc();
			}else{
				pavementMC = new BorderVMc();
			}
			
			var bgBitmapData:BitmapData = new BitmapData(pavementMC.width, pavementMC.height); 
			bgBitmapData.draw(pavementMC);
			skin.graphics.beginBitmapFill(bgBitmapData, null, true, true);
			skin.graphics.drawRect(0, 0, pw, ph);
			skin.graphics.endFill();
			actor.addChild(skin);
			
			var body:qb2Body = new qb2Body();			
			body.actor = actor as qb2IActor;
			body.addObject(qb2Stock.newRectShape(new amPoint2d(actor.width / 2, actor.height / 2), actor.width, actor.height));
			qb2world.addObject(body);
			body.position.x = int(px - pw / 2);
			body.position.y = int(py - ph / 2);
		}
		
		public function addStartSensor(sx:Number, sy:Number, sw:Number, sh:Number, sr:Number):qb2TripSensor{
			var startSensor:qb2TripSensor = qb2Stock.newRectSensor(new amPoint2d(sx, sy), sw, sh, (Math.PI / 2 * sr) / 90);
			qb2world.addObject(startSensor);
			
			return startSensor;
		}
		
		public function addFinishSensor(sx:Number, sy:Number, sw:Number, sh:Number, sr:Number):qb2TripSensor{
			var finishSensor:qb2TripSensor = qb2Stock.newRectSensor(new amPoint2d(sx, sy), sw, sh, (Math.PI / 2 * sr) / 90);
			qb2world.addObject(finishSensor);
			
			return finishSensor;
		}
		
		public function addAdditioanlZoneSensor(sx:Number, sy:Number, sw:Number, sh:Number, sr:Number):qb2TripSensor{
			var additionalZoneSensor:qb2TripSensor = qb2Stock.newRectSensor(new amPoint2d(sx, sy), sw, sh, (Math.PI / 2 * sr) / 90);
			qb2world.addObject(additionalZoneSensor);
			
			return additionalZoneSensor;
		}
		
		public function addUserCar(user:User, carModel:CarModel, index:int):tdCarBody{
			var boundsK:Number = 0.010;
			var carWidth:Number = carModel.prototype.width * boundsK;
			var carLength:Number = carModel.prototype.length * boundsK;
			
			var car:tdCarBody = new tdCarBody();
			var carActor:qb2FlashSpriteActor = new qb2FlashSpriteActor();
			car.actor = carActor as qb2IActor;
			
			if(GameApplication.app.userinfomanager.myuser.id == user.id)
			{
				myCar = car;
			}
			cars[user.id] = car;
			
			car.addObject(qb2Stock.newRectShape(new amPoint2d(0, 0), carWidth, carLength));
			car.mass = carModel.prototype.mass;
			car.tractionControl = false;
			
			var angle:Number = GameApplication.app.models.gameModel.carRotation;
			var count360round:int = Math.floor(Math.abs(angle) / 360);
			if(angle < 0){
				angle += count360round * 360;
				angle = 360 + angle;
			}else{
				angle -= count360round * 360;
			}
			
			var dx:Number;
			var dy:Number;
			
			if(angle == 0 || angle == 180){
				dx = 90;
				dy = 70;
				if(index % 2 == 0){
					car.position.x = GameApplication.app.models.gameModel.carPoint.x;
				}else{
					if(angle == 0){
						car.position.x = GameApplication.app.models.gameModel.carPoint.x + dx;
					}else{
						car.position.x = GameApplication.app.models.gameModel.carPoint.x - dx;
					}
				}
				if(angle == 0){
					car.position.y = GameApplication.app.models.gameModel.carPoint.y + dy * Math.floor(index / 2);
				}else{
					car.position.y = GameApplication.app.models.gameModel.carPoint.y - dy * Math.floor(index / 2);
				}
			}else{
				dx = 70;
				dy = 90;
				if(index % 2 == 0){
					car.position.y = GameApplication.app.models.gameModel.carPoint.y;
				}else{
					if(angle == 90){
						car.position.y = GameApplication.app.models.gameModel.carPoint.y + dy;
					}else{
						car.position.y = GameApplication.app.models.gameModel.carPoint.y - dy;
					}
				}
				if(angle == 90){
					car.position.x = GameApplication.app.models.gameModel.carPoint.x - dx * Math.floor(index / 2);
				}else{
					car.position.x = GameApplication.app.models.gameModel.carPoint.x + dx * Math.floor(index / 2);
				}
			}
			
			car.rotation = Math.PI * GameApplication.app.models.gameModel.carRotation / 180;
			car.contactGroupIndex = -1;
			
			var tireFriction:Number = 2.0 * carModel.prototype.tireFrictionK; 
			var tireRollingFriction:Number = 1;
			var tireWidth:Number = 3.5 * (carModel.prototype.discR / 14);
			var tireRadius:Number = 5 * (carModel.prototype.discR / 14);
			
			var tireLF:tdTire = new tdTire(new amPoint2d(-carWidth/2 + tireWidth / 2 + 2, -carLength/3 + tireRadius / 3), tireWidth, tireRadius, true /*driven*/, true /*turns*/, false /*brakes*/, tireFriction, tireRollingFriction);
			var tireLFActor:qb2FlashSpriteActor = new qb2FlashSpriteActor();
			var tireLFSkin:Sprite = new Sprite();
			tireLFSkin.graphics.beginFill(0x00, 1);
			tireLFSkin.graphics.drawRect(-tireWidth / 2, -tireRadius, tireWidth, tireRadius * 2);
			tireLFActor.setX(-carWidth / 2 + tireWidth / 2 + 2);
			tireLFActor.setY(-carLength / 3 + tireRadius / 3);
			tireLFActor.addChild(tireLFSkin);			
			tireLF.actor = tireLFActor;
			
			var tireRF:tdTire = new tdTire(new amPoint2d(carWidth / 2 - tireWidth / 2 - 2, -carLength / 3 + tireRadius / 3), tireWidth, tireRadius, true /*driven*/, true /*turns*/, false /*brakes*/, tireFriction, tireRollingFriction);
			var tireRFActor:qb2FlashSpriteActor = new qb2FlashSpriteActor();
			var tireRFSkin:Sprite = new Sprite();
			tireRFSkin.graphics.beginFill(0x0, 1);
			tireRFSkin.graphics.drawRect(-tireWidth / 2, -tireRadius, tireWidth, tireRadius * 2);
			tireRFActor.setX(carWidth / 2 - tireWidth / 2 - 2);
			tireRFActor.setY(-carLength / 3 + tireRadius / 3);
			tireRFActor.addChild(tireRFSkin);			
			tireRF.actor = tireRFActor;
			
			var tireLB:tdTire = new tdTire(new amPoint2d(-carWidth / 2 + tireWidth / 2 + 2, carLength / 3 - tireRadius / 3), tireWidth, tireRadius, false /*driven*/, false /*turns*/, true /*brakes*/, tireFriction, tireRollingFriction);
			var tireRB:tdTire = new tdTire(new amPoint2d(carWidth / 2 - tireWidth / 2 - 2, carLength / 3 - tireRadius / 3), tireWidth, tireRadius, false /*driven*/, false /*turns*/, true /*brakes*/, tireFriction, tireRollingFriction);
			
			car.addObject(tireLF, tireRF, tireLB, tireRB);
			
			var carBrain:tdControllerBrain = new tdControllerBrain();
			var carBrainController:KeyboardCarController = new KeyboardCarController();
			carBrain.addController(carBrainController);
			car.addObject(carBrain);
			
			carBrainControllers[user.id] = carBrainController;
			
			car.addObject(new tdEngine(), new tdTransmission());
			
			car.tranny.gearRatios = carModel.prototype.trannyGearRatios;
			
			var curve:tdTorqueCurve = car.engine.torqueCurve;
			for(var key:String in carModel.prototype.powersObj)
			{
				curve.addEntry(int(key), int(carModel.prototype.powersObj[key]));
			}
			
			var carSkinClass:Class = LibraryMovieClass.getCarTDClassByCarPrototypeID(carModel.prototype.id);
			var carSkin:MovieClip = new carSkinClass();
			carSkin.width = carWidth;
			carSkin.height = carLength;
			
			var gameWorldCar:GameWorldCar = new GameWorldCar();
			gameWorldCar.addChild(carSkin);
			carActor.addChild(gameWorldCar);
			
			if(GameApplication.app.userinfomanager.myuser.id == user.id && GameApplication.app.models.gameModel.gameType == GameType.SIMPLE)
			{
				var delay:int = 200;
				new Flasher(gameWorldCar).start(delay, 1000 / delay * 8);
			}
			
			BrushManager.brush(carModel.color, carSkin["mc"]);
			
			map.addObject(car);
			
			return car;
		}
		
		protected override function update():void
		{
			super.update();
			
			if(myCar)
			{
				cameraPoint.copy(myCar.position);
				cameraTargetPoint.copy(myCar.position);
			}
		}
		
		public function get cameraTargetPoint():amPoint2d
		{  
			return gameWorld.cameraTargetPoint;  
		}
		
		public function get cameraPoint():amPoint2d 
		{  
			return gameWorld.cameraPoint;  
		}
		
		public function destroy():void
		{
			cars = null;
			carBrainControllers = null;
			myCar = null;
			qb2world = null;
			gameWorld = null;
			center = null;
		}
	}
}