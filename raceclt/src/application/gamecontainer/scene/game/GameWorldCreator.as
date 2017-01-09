package application.gamecontainer.scene.game
{
	import application.GameApplication;
	import application.components.usertitle.UserTitle;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import mx.core.UIComponent;
	
	import utils.constructor.BackGroundType;
	import utils.managers.gameparams.GameParamsManager;
	import utils.user.Accessorytype;
	import utils.user.ColorType;
	import utils.user.User;
	
	public class GameWorldCreator
	{
		private var _persfriction:Number = 2;
		private var _pesmass:uint = 700;		
		private var world:b2World;
		private var ui:UIComponent;
		private var _userstitles:Object;
		private var _bgcontainer:Sprite;
		
		public function GameWorldCreator(world:b2World, ui:UIComponent, pt:Object)
		{
			this.world = world;
			this.ui = ui;
			
			_userstitles = pt;
			
			_bgcontainer = new Sprite();
			ui.addChild(_bgcontainer);
		}
		
		public function createBg(bgId:uint):void{
			var bgSprite:Sprite;
			var bgMc:MovieClip;
			var bgBitmapData:BitmapData;
			
			if(bgId == BackGroundType.DAY){
				_bgcontainer.addChild(new BackGroundDay());
			}else if(bgId == BackGroundType.EVENING){
				_bgcontainer.addChild(new BackGroundEvening());
			}else if(bgId == BackGroundType.NIGHT){
				_bgcontainer.addChild(new BackGroundNight());
			}else if(bgId == BackGroundType.SEA){
				_bgcontainer.addChild(new BackgroundSea());
			}else if(bgId == BackGroundType.FORESTNIGHT){
				_bgcontainer.addChild(new BackgroundForestNight());
			}else if(bgId == BackGroundType.CASTLE){
				_bgcontainer.addChild(new BackCastle());
			}else if(bgId == BackGroundType.BEACH){
				_bgcontainer.addChild(new BackBeach());
			}else if(bgId == BackGroundType.SEWAGE){
				_bgcontainer.addChild(new Stoki());
			}else if(bgId == BackGroundType.HILLS){
				_bgcontainer.addChild(new Hills());
			}else if(bgId == BackGroundType.WALL){
				bgSprite = new Sprite();
				bgSprite.graphics.clear();
				
				bgMc = new Wall();
				bgBitmapData = new BitmapData(bgMc.width, bgMc.height); 
				bgBitmapData.draw(bgMc);
				bgSprite.graphics.beginBitmapFill(bgBitmapData, null, true, true);
				bgSprite.graphics.drawRect(0, 0, GameApplication.app.models.gameModel.sceneWidth, GameApplication.app.models.gameModel.sceneHeight);
				bgSprite.graphics.endFill();
				
				_bgcontainer.addChild(bgSprite);
			}else if(bgId == BackGroundType.TREES){
				bgSprite = new Sprite();
				bgSprite.graphics.clear();
				
				bgMc = new Trees();
				bgBitmapData = new BitmapData(bgMc.width, bgMc.height); 
				bgBitmapData.draw(bgMc);
				bgSprite.graphics.beginBitmapFill(bgBitmapData, null, true, true);
				bgSprite.graphics.drawRect(0, 0, GameApplication.app.models.gameModel.sceneWidth, GameApplication.app.models.gameModel.sceneHeight);
				bgSprite.graphics.endFill();
				
				_bgcontainer.addChild(bgSprite);
			}else if(bgId == BackGroundType.JUNGLE){
				bgSprite = new Sprite();
				bgSprite.graphics.clear();
				
				bgMc = new Jungle();
				bgBitmapData = new BitmapData(bgMc.width, bgMc.height); 
				bgBitmapData.draw(bgMc);
				bgSprite.graphics.beginBitmapFill(bgBitmapData, null, true, true);
				bgSprite.graphics.drawRect(0, 0, GameApplication.app.models.gameModel.sceneWidth, GameApplication.app.models.gameModel.sceneHeight);
				bgSprite.graphics.endFill();
				
				_bgcontainer.addChild(bgSprite);
			}
			_bgcontainer.cacheAsBitmap = true;
		}
		
		public function createDecoration(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):void{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;
				bodyDef.userData.alpha = .9;
				bodyDef.userData.name = "decoration";
				ui.addChildAt(bodyDef.userData, 1);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = .5;
			shape.isSensor = true; 
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
		}
		
		public function createStaticBox(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = .1;			
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			return body;
		}
		
		public function createStaticRedBox(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = .1;
			shape.restitution = 2;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			return body;
		}
		
		public function createStaticBlueBox(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = 0;			
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			return body;
		}
		
		public function createGroundBox(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new MovieClip();
				
				bodyDef.userData.graphics.clear();
				var groundMc:MovieClip = new ConstructorGround();
				var bitmapData:BitmapData = new BitmapData(groundMc.width, groundMc.height); 
				bitmapData.draw(groundMc);
				bodyDef.userData.graphics.beginBitmapFill(bitmapData, null, true);
				bodyDef.userData.graphics.drawRect(-bw / 2, -bh / 2, bw, bh);
				bodyDef.userData.graphics.endFill();
				
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = .1;			
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			return body;
		}
		
		public function createGroundRedBox(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new MovieClip();
				
				bodyDef.userData.graphics.clear();
				var groundMc:MovieClip = new ConstructorGroundRed();
				var bitmapData:BitmapData = new BitmapData(groundMc.width, groundMc.height); 
				bitmapData.draw(groundMc);
				bodyDef.userData.graphics.beginBitmapFill(bitmapData, null, true);
				bodyDef.userData.graphics.drawRect(-bw / 2, -bh / 2, bw, bh);
				bodyDef.userData.graphics.endFill();
				
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = .1;
			shape.restitution = 2;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			return body;
		}
		
		public function createGroundBlueBox(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new MovieClip();
				
				bodyDef.userData.graphics.clear();
				var groundMc:MovieClip = new ConstructorGroundBlue();
				var bitmapData:BitmapData = new BitmapData(groundMc.width, groundMc.height); 
				bitmapData.draw(groundMc);
				bodyDef.userData.graphics.beginBitmapFill(bitmapData, null, true);
				bodyDef.userData.graphics.drawRect(-bw / 2, -bh / 2, bw, bh);
				bodyDef.userData.graphics.endFill();
				
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = 0;			
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			return body;
		}
		
		public function createBox(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):b2Body{			
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;				
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);
			shape.density = 4;
			shape.friction = .1;
			shape.restitution = 0;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			return body;
		}
		
		public function createHeavyBox(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);
			shape.density = 3;
			shape.friction = .5;
			shape.restitution = 0;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();	
			return body;
		}
		
		public function createStick(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);
			shape.density = .7;
			shape.friction = .1;
			shape.restitution = 0;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();	
			return body;
		}
		
		public function createBall(bx:Number, by:Number, r:Number, ba:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = r * 2; 
				bodyDef.userData.height = r * 2;
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2CircleDef = new b2CircleDef();
			shape.radius = r;
			shape.density = .5;
			shape.friction = .9;
			shape.restitution = .7;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();	
			return body;
		}
		
		public function createKernelRight(bx:Number, by:Number, r:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = r * 2; 
				bodyDef.userData.height = r * 2;
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2CircleDef = new b2CircleDef();
			shape.radius = r;
			shape.density = 2;
			shape.friction = .9;
			shape.restitution = 0;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			
			body.SetLinearVelocity(new b2Vec2(3000, 0));
			return body;
		}	
		public function createKernelLeft(bx:Number, by:Number, r:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = r * 2; 
				bodyDef.userData.height = r * 2;
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2CircleDef = new b2CircleDef();
			shape.radius = r;
			shape.density = 2;
			shape.friction = .9;
			shape.restitution = 0;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			
			body.SetLinearVelocity(new b2Vec2(-3000, 0));	
			return body;
		}
		
		public function createCarrierH(x:Number, y:Number, w:Number, boxw:Number, boxh:Number, mcClass:Class = null):b2Body{
			var boxbodydef:b2BodyDef = new b2BodyDef();			
			boxbodydef.position.Set(x + boxw / 2, y);		
			boxbodydef.isSleeping = false;
			boxbodydef.userData = new mcClass();			
			if (mcClass)
			{
				boxbodydef.userData.width = boxw; 
				boxbodydef.userData.height = boxh;
				boxbodydef.userData.name = "toright";
				ui.addChild(boxbodydef.userData);
			}
			var boxbody:b2Body = world.CreateBody(boxbodydef);
			
			var boxdef:b2PolygonDef = new b2PolygonDef();
			boxdef.SetAsBox(boxw / 2, boxh / 2);
			boxdef.density = 10;
			
			boxbody.CreateShape(boxdef);
			boxbody.SetMassFromShapes();	
			
			var prism_joint:b2PrismaticJointDef = new b2PrismaticJointDef();
			prism_joint.Initialize(world.GetGroundBody(), boxbody, new b2Vec2(x + boxw / 2, y + boxh / 2),new b2Vec2(1,0));
			prism_joint.lowerTranslation = 0.0;
			prism_joint.upperTranslation = w - boxw;
			prism_joint.enableLimit = true;
			prism_joint.userData = new mcClass();
			
			var joint_added:b2PrismaticJoint = world.CreateJoint(prism_joint) as b2PrismaticJoint;	
			boxbody.SetLinearVelocity(new b2Vec2(20, 0));
			
			return boxbody;
		}
		
		public function createCarrierV(x:Number, y:Number, h:Number, boxw:Number, boxh:Number, mcClass:Class = null):b2Body{
			var boxbodydef:b2BodyDef = new b2BodyDef();			
			boxbodydef.position.Set(x, y + boxh / 2);		
			boxbodydef.isSleeping = false;
			boxbodydef.userData = new mcClass();			
			if (mcClass)
			{
				boxbodydef.userData.width = boxw; 
				boxbodydef.userData.height = boxh;
				boxbodydef.userData.name = "tobottom";
				ui.addChild(boxbodydef.userData);
			}
			var boxbody:b2Body = world.CreateBody(boxbodydef);
			
			var boxdef:b2PolygonDef = new b2PolygonDef();
			boxdef.SetAsBox(boxw / 2, boxh / 2);
			boxdef.density = 10;
			
			boxbody.CreateShape(boxdef);
			boxbody.SetMassFromShapes();	
			
			var prism_joint:b2PrismaticJointDef = new b2PrismaticJointDef();
			prism_joint.Initialize(world.GetGroundBody(), boxbody, new b2Vec2(x, y + boxh / 2),new b2Vec2(0, 1));
			prism_joint.lowerTranslation = 0.0;
			prism_joint.upperTranslation = h - boxh;
			prism_joint.enableLimit = true;
			prism_joint.userData = new mcClass();
			
			var joint_added:b2PrismaticJoint = world.CreateJoint(prism_joint) as b2PrismaticJoint;	
			boxbody.SetLinearVelocity(new b2Vec2(0, 10));
			
			return boxbody;
		}
		
		public function CreateSpringboard(bx:Number, by:Number, bw:Number, bh:Number, mcClass:Class = null):b2Body{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;
				bodyDef.userData.name = "Springboard";
				ui.addChild(bodyDef.userData);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = .5;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
			return body;
		}
		
		public function CreateCheese(bx:Number, by:Number, bw:Number, bh:Number, mcClass:Class = null):void{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;
				bodyDef.userData.name = "Cheese";
				ui.addChildAt(bodyDef.userData, 1);
			}
			
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = .5;
			shape.isSensor = true;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
		}
		
		public function CreateMink(bx:Number, by:Number, bw:Number, bh:Number, ba:Number, mcClass:Class = null):void{
			var bodyDef:b2BodyDef = new b2BodyDef();			
			bodyDef.position.Set(bx, by);
			bodyDef.angle = ba * (Math.PI / 180);
			
			if(mcClass){
				bodyDef.userData = new mcClass();
				bodyDef.userData.width = bw; 
				bodyDef.userData.height = bh;
				bodyDef.userData.name = "Mink";
				ui.addChildAt(bodyDef.userData, 1);
			}
			var body:b2Body = world.CreateBody(bodyDef);
			var shape:b2PolygonDef = new b2PolygonDef();
			shape.SetAsBox(bw / 2, bh / 2);	
			shape.friction = .5;
			shape.isSensor = true;
			
			body.CreateShape(shape);
			body.SetMassFromShapes();
		}
		
		public function createPers(mx:Number, my:Number, mw:Number, mh:Number, colortype:int, king:int, user:User):b2Body{
			var scale:Number = 1;
			var accessorytype:int = user.accessorytype;
			
			if(king == 1){
//				scale = 1.2;
				colortype = ColorType.BLACK1;
				accessorytype = Accessorytype.KING_CRONE;
			}
			
			var ismyuser:Boolean = false;
			if(int(user.id) == GameApplication.app.userinfomanager.myuser.id) ismyuser = true;
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.position.Set(mx, my);
			bodyDef.isSleeping = false;
			
			var accessoryClass:Class = User.getAccessoryClass(accessorytype);
			var accessorymc:MovieClip = new accessoryClass();
			accessorymc.scaleX = accessorymc.scaleY = scale;
//			if(!ismyuser) accessorymc.alpha = .5;
			accessorymc.gotoAndStop(1);
			accessorymc.name = "accessory";
			
			var SkinClass:Class = User.getSkinClassByColorType(colortype);
			bodyDef.userData = new SkinClass();
			
			bodyDef.userData["scale"] = scale;
			
			bodyDef.userData.scaleX = bodyDef.userData.scaleY = scale;
//			if(!ismyuser) bodyDef.userData.alpha = .5;
			bodyDef.userData.addChild(accessorymc);
			bodyDef.userData.name = "LittleMouse";
			
			bodyDef.userData.graphics.clear();
			bodyDef.userData.graphics.beginFill(0xff0000, 0);
			bodyDef.userData.graphics.drawRect(-8, 14 + 1, 16, 2);
			bodyDef.userData.graphics.endFill();
			
			bodyDef.userData["kspeed"] = GameParamsManager.getKSpeed(accessorytype, colortype);
			bodyDef.userData["kjump"] = GameParamsManager.getKJump(accessorytype, colortype);
			bodyDef.userData["booking"] = GameParamsManager.getBooking(accessorytype, colortype);
			ui.addChild(bodyDef.userData);
			
			bodyDef.userData["accessory"] = accessorymc;
			
			accessorymc.x = 0;
			accessorymc.y = 0;			
			
			var body:b2Body = world.CreateBody(bodyDef);			
			var shapeDef:b2PolygonDef = new b2PolygonDef();
			shapeDef.SetAsBox((mw * scale) / 2, (mh * scale) / 2);
			shapeDef.density = 0.1;
			shapeDef.friction = _persfriction;
			shapeDef.restitution = 0;
			shapeDef.filter.groupIndex = -1;
			
			body.CreateShape(shapeDef);
			body.SetMassFromShapes();
			
			var mass:b2MassData = new b2MassData();
			mass.mass = _pesmass;
			mass.center = new b2Vec2(0, mh / 2)
			
			body.SetMass(mass);			
			createPersTitle(user.id, user.title, user.level);
			return body;
		}
		
		private function createPersTitle(userID:int, title:String, level:int):void{
			var ismyuser:Boolean = (userID == GameApplication.app.userinfomanager.myuser.id);
			var ut:UserTitle = new UserTitle(title, level, ismyuser);
			_userstitles[userID] = ut;
			ui.addChild(ut);
			
			if(!GameApplication.app.models.settings.userTitlesInGameVisible && 
				userID != GameApplication.app.userinfomanager.myuser.id){
				ut.titlevisible = false; 
			}
		}		
	}
}