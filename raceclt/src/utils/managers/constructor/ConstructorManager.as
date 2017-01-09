package utils.managers.constructor
{
	import application.GameApplication;
	import application.components.popup.savemap.PopUpSaveMap;
	import application.gamecontainer.scene.constructor.Constructor;
	import application.gamecontainer.scene.game.SceneElements;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	import utils.constructor.BackGroundType;
	import utils.constructor.ConstructorCreateMode;
	import utils.constructor.ConstructorElement;
	import utils.constructor.ConstructorState;
	import utils.models.car.CarId;
	import utils.models.map.DistrictModel;
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;
	import utils.selector.Selector;
	import utils.shop.BuyResultCode;

	public class ConstructorManager extends EventDispatcher
	{
		public var constructor:Constructor;
		
		public const CARRIER_BOX_WIDTH:Number = 50;
		public const CARRIER_BOX_HEIGHT:Number = 20;
		
		[Bindable]
		public var constructormode:Boolean = false;
		[Bindable]
		public var testMode:Boolean = false;
		[Bindable]
		public var createmode:uint;
		[Bindable]
		public var state:uint;
		
		[Bindable]
		public var sceneWidth:Number = 750;
		[Bindable]
		public var sceneHeight:Number = 380;
		public var minSceneWidth:Number = 750;
		public var minSceneHeight:Number = 380;
		public var maxSceneWidth:Number = 2500;
		public var maxSceneHeight:Number = 2000;
		
		private var _down:Boolean = false;
		private var _up:Boolean = false;
		private var _move:Boolean = false;
		
		public var currentElement:ConstructorElement;
		
		private var _startCreatedPoint:Point;
		private var _elementIdCounter:uint = 0;
		
		private var _selectorElement:Selector = new Selector();
		private var _fileRef:FileReference;
		private var _creatorID:uint;
		private var _bgId:uint = 0;
		private var _laps:int = 3;
		
		public var elementsObj:Object = new Object();
		
		public function get selectorElement():Selector{
			return _selectorElement;
		}
		
		public function ConstructorManager()
		{
		}
		
		public function init():void{
			GameApplication.app.constructor.sceneWidth = 750;
			GameApplication.app.constructor.sceneHeight = 380;
			
			dispatchEvent(new ConstructorManagerEvent(ConstructorManagerEvent.CONSTRUCTOR_INIT, 0));
			dispatchEvent(new ConstructorManagerEvent(ConstructorManagerEvent.SCENE_SIZE_CHANGE, 0));
			
			setBg(BackGroundType.BG1);
		}
		
		public function initXML(xmlContent:XML):void{
			_bgId = 0;
			
			if(constructor && xmlContent){
				sceneWidth = xmlContent.attribute("width");
				sceneHeight = xmlContent.attribute("height");
				
				dispatchEvent(new ConstructorManagerEvent(ConstructorManagerEvent.SCENE_SIZE_CHANGE, 0));
				
				var list:XMLList = xmlContent.elements("*");			
				for(var i:uint = 0; i < list.length(); i++)
				{	
					var element:ConstructorElement;
					var fillMc:MovieClip;
					var fillBitmapData:BitmapData;
					if (list[i].name() == SceneElements.ROAD){
						element = createElement(_elementIdCounter++, list[i].name(), RoadMc);
						
						element.graphics.clear();
						fillMc = new RoadMc();
						fillBitmapData = new BitmapData(fillMc.width, fillMc.height); 
						fillBitmapData.draw(fillMc);
						element.graphics.beginBitmapFill(fillBitmapData, null, true);
						element.graphics.drawRect(0, 0, list[i].@w, list[i].@h);
						element.graphics.endFill();
						
						element.x = list[i].@x - list[i].@w / 2;
						element.y = list[i].@y - list[i].@h / 2;
					}else if (list[i].name() == SceneElements.BORDERH){
						element = createElement(_elementIdCounter++, list[i].name(), BorderHMc);
						
						element.graphics.clear();
						fillMc = new BorderHMc();
						fillBitmapData = new BitmapData(fillMc.width, fillMc.height); 
						fillBitmapData.draw(fillMc);
						element.graphics.beginBitmapFill(fillBitmapData, null, true);
						element.graphics.drawRect(0, 0, list[i].@w, list[i].@h);
						element.graphics.endFill();
						
						element.x = list[i].@x - list[i].@w / 2;
						element.y = list[i].@y - list[i].@h / 2;
					}else if (list[i].name() == SceneElements.BORDERV){
						element = createElement(_elementIdCounter++, list[i].name(), BorderVMc);
						
						element.graphics.clear();
						fillMc = new BorderVMc();
						fillBitmapData = new BitmapData(fillMc.width, fillMc.height); 
						fillBitmapData.draw(fillMc);
						element.graphics.beginBitmapFill(fillBitmapData, null, true);
						element.graphics.drawRect(0, 0, list[i].@w, list[i].@h);
						element.graphics.endFill();
						
						element.x = list[i].@x - list[i].@w / 2;
						element.y = list[i].@y - list[i].@h / 2;
					}else if (list[i].name() == SceneElements.START){
						element = createElement(_elementIdCounter++, list[i].name(), StartMc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.FINISH){
						element = createElement(_elementIdCounter++, list[i].name(), FinishMc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.ADDITIONAL_ZONE){
						element = createElement(_elementIdCounter++, list[i].name(), AdditionalZoneMc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.TRANSITION){
						element = createElement(_elementIdCounter++, list[i].name(), TransitionMc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.LIGHT1){
						element = createElement(_elementIdCounter++, list[i].name(), Light1Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.LIGHT2){
						element = createElement(_elementIdCounter++, list[i].name(), Light2Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.BUILDING1){
						element = createElement(_elementIdCounter++, list[i].name(), Building1Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.BUILDING2){
						element = createElement(_elementIdCounter++, list[i].name(), Building2Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.BUILDING3){
						element = createElement(_elementIdCounter++, list[i].name(), Building3Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.BUILDING4){
						element = createElement(_elementIdCounter++, list[i].name(), Building4Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.GARLAND1){
						element = createElement(_elementIdCounter++, list[i].name(), Garland1Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.GARLAND2){
						element = createElement(_elementIdCounter++, list[i].name(), Garland2Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.GARLAND3){
						element = createElement(_elementIdCounter++, list[i].name(), Garland3Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.TREE1){
						element = createElement(_elementIdCounter++, list[i].name(), Tree1Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.TREE2){
						element = createElement(_elementIdCounter++, list[i].name(), Tree2Mc);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if (list[i].name() == SceneElements.LAYOUTH){
						element = createElement(_elementIdCounter++, list[i].name(), LayoutHMc);
						
						while (element.numChildren)
							element.removeChildAt(0);
						
						element.graphics.clear();
						fillMc = new LayoutHMc();
						fillBitmapData = new BitmapData(fillMc.width, fillMc.height, true, 0xff0000); 
						fillBitmapData.draw(fillMc);
						element.graphics.beginBitmapFill(fillBitmapData, null, true);
						element.graphics.drawRect(0, 0, list[i].@w, list[i].@h);
						element.graphics.endFill();
						
						element.x = list[i].@x - list[i].@w / 2;
						element.y = list[i].@y - list[i].@h / 2;
					}else if (list[i].name() == SceneElements.LAYOUTV){
						element = createElement(_elementIdCounter++, list[i].name(), LayoutVMc);
						
						while (element.numChildren)
							element.removeChildAt(0);
						
						element.graphics.clear();
						fillMc = new LayoutVMc();
						fillBitmapData = new BitmapData(fillMc.width, fillMc.height, true, 0xff0000); 
						fillBitmapData.draw(fillMc);
						element.graphics.beginBitmapFill(fillBitmapData, null, true);
						element.graphics.drawRect(0, 0, list[i].@w, list[i].@h);
						element.graphics.endFill();
						
						element.x = list[i].@x - list[i].@w / 2;
						element.y = list[i].@y - list[i].@h / 2;
					}else if (list[i].name() == SceneElements.CAR){
						element = createElement(_elementIdCounter++, list[i].name(), Car);
						element.x = list[i].@x;
						element.y = list[i].@y;
						element.rotation = list[i].@a;
					}else if(list[i].name() == "creator"){
						_creatorID = list[i].@id;
					}
					else if(list[i].name() == "laps"){
						_laps = list[i].@count;
						dispatchEvent(new ConstructorManagerEvent(ConstructorManagerEvent.LAPS_CHANGE, list[i].@count));
					}else if(list[i].name() == SceneElements.BACKGROUND){
						setBg(list[i].@id);						
						dispatchEvent(new ConstructorManagerEvent(ConstructorManagerEvent.BG_CHANGE, list[i].@id));
					}
				} 
			}
		}
		
		private function createElement(eid:uint, tagName:String, iconClass:Class):ConstructorElement{
			var element:ConstructorElement = new ConstructorElement();
			element.tagName = tagName;
			element.iconClass = iconClass;
			element.elementId = eid;
					
			element.addEventListener(ConstructorElementEvent.SELECTED, onElementSelected, false, 0, true);
			element.addEventListener(ConstructorElementEvent.UNSELECTED, onElementUnSelected, false, 0, true);
			
			if (tagName == SceneElements.ROAD){
				constructor.content.addChildAt(element, 0);
			}else{
				constructor.content.addChild(element);
			}
			
			elementsObj[element.elementId] = element;			
			return element;
		}
		
		public function startCreate():void{
			GameApplication.app.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			GameApplication.app.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			GameApplication.app.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);			
			
			constructormode = true;
			state = ConstructorState.NONE;
		}
		
		public function stopCreate():void{
			GameApplication.app.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			GameApplication.app.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			GameApplication.app.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			clearConstructorElementSelector();
			
			constructormode = false;
			
			currentElement = null;
			elementsObj = new Object();
			constructor = null;
		}
		
		public function clearConstructorElementSelector():void{
			_selectorElement.clear();
		}
		
		public function setLaps(value:int):void{
			_laps = value;
		}
		
		public function setBg(bgid:uint):void{
			_bgId = bgid;
			while(constructor.bg.numChildren > 0){
				constructor.bg.removeChildAt(0);
			}
			
			var bgSprite:Sprite = new Sprite();
			bgSprite.graphics.clear();
			
			var bgMc:MovieClip;
			if(bgid == BackGroundType.BG1){
				bgMc = new Bg1Mc();
			}else if(bgid == BackGroundType.BG2){
				bgMc = new Bg2Mc();
			}else if(bgid == BackGroundType.BG3){
				bgMc = new Bg3Mc();
			}
			var bgBitmapData:BitmapData = new BitmapData(bgMc.width, bgMc.height); 
			bgBitmapData.draw(bgMc);
			bgSprite.graphics.beginBitmapFill(bgBitmapData, null, true);
			bgSprite.graphics.drawRect(0, 0, sceneWidth, sceneHeight);
			bgSprite.graphics.endFill();
			
			constructor.bg.addChild(bgSprite);
		}
		
		public function setContentScale(scale:Number):void{
			constructor.bg.scaleX = scale;
			constructor.bg.scaleY = scale;
			
			constructor.content.scaleX = scale;
			constructor.content.scaleY = scale;
		}
		
		public function setMode(mode:uint):void{
			createmode = mode;
			state = ConstructorState.CREATE;
		}
		
		private function onMouseDown(e:MouseEvent):void{
			if(state == ConstructorState.CREATE){
				var constructorSceneContent:Constructor = GameApplication.app.navigator.currentSceneContent as Constructor;
				
				if(constructorSceneContent && constructorSceneContent.hitTestPoint(constructorSceneContent.mouseX, constructorSceneContent.mouseY)){
					if(constructor){
						currentElement = new ConstructorElement();
						
						if(createmode == ConstructorCreateMode.ROAD){
							currentElement.tagName = SceneElements.ROAD;
							currentElement.iconClass = RoadMc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.BORDERH){
							currentElement.tagName = SceneElements.BORDERH;
							currentElement.iconClass = BorderHMc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.BORDERV){
							currentElement.tagName = SceneElements.BORDERV;
							currentElement.iconClass = BorderVMc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.START){
							currentElement.tagName = SceneElements.START;
							currentElement.iconClass = StartMc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.CAR){
							currentElement.tagName = SceneElements.CAR;
							currentElement.iconClass = Car;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.FINISH){
							currentElement.tagName = SceneElements.FINISH;
							currentElement.iconClass = FinishMc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.ADDITIONAL_ZONE){
							currentElement.tagName = SceneElements.ADDITIONAL_ZONE;
							currentElement.iconClass = AdditionalZoneMc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.TRANSITION){
							currentElement.tagName = SceneElements.TRANSITION;
							currentElement.iconClass = TransitionMc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.LAYOUTH){
							currentElement.tagName = SceneElements.LAYOUTH;
							currentElement.iconClass = LayoutHMc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.LAYOUTV){
							currentElement.tagName = SceneElements.LAYOUTV;
							currentElement.iconClass = LayoutVMc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.BUILDING1){
							currentElement.tagName = SceneElements.BUILDING1;
							currentElement.iconClass = Building1Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.BUILDING2){
							currentElement.tagName = SceneElements.BUILDING2;
							currentElement.iconClass = Building2Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.BUILDING3){
							currentElement.tagName = SceneElements.BUILDING3;
							currentElement.iconClass = Building3Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.BUILDING4){
							currentElement.tagName = SceneElements.BUILDING4;
							currentElement.iconClass = Building4Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.LIGHT1){
							currentElement.tagName = SceneElements.LIGHT1;
							currentElement.iconClass = Light1Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.LIGHT2){
							currentElement.tagName = SceneElements.LIGHT2;
							currentElement.iconClass = Light2Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.GARLAND1){
							currentElement.tagName = SceneElements.GARLAND1;
							currentElement.iconClass = Garland1Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.GARLAND2){
							currentElement.tagName = SceneElements.GARLAND2;
							currentElement.iconClass = Garland2Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.GARLAND3){
							currentElement.tagName = SceneElements.GARLAND3;
							currentElement.iconClass = Garland3Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.TREE1){
							currentElement.tagName = SceneElements.TREE1;
							currentElement.iconClass = Tree1Mc;
							
							state = ConstructorState.NONE;
						}else if(createmode == ConstructorCreateMode.TREE2){
							currentElement.tagName = SceneElements.TREE2;
							currentElement.iconClass = Tree2Mc;
							
							state = ConstructorState.NONE;
						}
						
						currentElement.elementId = _elementIdCounter++;
						
						var fillMc:MovieClip;
						var bitmapData:BitmapData;
						
						if(currentElement.tagName == SceneElements.ROAD){
							var roadMc:MovieClip = new RoadMc();
							bitmapData = new BitmapData(roadMc.width, roadMc.height); 
							bitmapData.draw(roadMc);
							currentElement.graphics.beginBitmapFill(bitmapData, null, true);
							currentElement.graphics.drawRect(0, 0, 180, 180);
							currentElement.graphics.endFill();
						}else if(currentElement.tagName == SceneElements.LAYOUTH){
							while (currentElement.numChildren)
								currentElement.removeChildAt(0);
							
							fillMc = new LayoutHMc();
							bitmapData = new BitmapData(fillMc.width, fillMc.height, true, 0xff0000); 
							bitmapData.draw(fillMc);
							currentElement.graphics.beginBitmapFill(bitmapData, null, true);
							currentElement.graphics.drawRect(0, 0, fillMc.width, fillMc.height);
							currentElement.graphics.endFill();
						}else if(currentElement.tagName == SceneElements.LAYOUTV){
							while (currentElement.numChildren)
								currentElement.removeChildAt(0);
							
							fillMc = new LayoutVMc();
							bitmapData = new BitmapData(fillMc.width, fillMc.height, true, 0xff0000); 
							bitmapData.draw(fillMc);
							currentElement.graphics.beginBitmapFill(bitmapData, null, true);
							currentElement.graphics.drawRect(0, 0, fillMc.width, fillMc.height);
							currentElement.graphics.endFill();
						}else if(currentElement.tagName == SceneElements.BORDERH){
							while (currentElement.numChildren)
								currentElement.removeChildAt(0);
							
							fillMc = new BorderHMc();
							bitmapData = new BitmapData(fillMc.width, fillMc.height, true, 0xff0000); 
							bitmapData.draw(fillMc);
							currentElement.graphics.beginBitmapFill(bitmapData, null, true);
							currentElement.graphics.drawRect(0, 0, fillMc.width, fillMc.height);
							currentElement.graphics.endFill();
						}else if(currentElement.tagName == SceneElements.BORDERV){
							while (currentElement.numChildren)
								currentElement.removeChildAt(0);
							
							fillMc = new BorderVMc();
							bitmapData = new BitmapData(fillMc.width, fillMc.height, true, 0xff0000); 
							bitmapData.draw(fillMc);
							currentElement.graphics.beginBitmapFill(bitmapData, null, true);
							currentElement.graphics.drawRect(0, 0, fillMc.width, fillMc.height);
							currentElement.graphics.endFill();
						}
						
						if(currentElement.tagName == SceneElements.LAYOUTV || currentElement.tagName == SceneElements.LAYOUTH ||
							currentElement.tagName == SceneElements.BORDERH || currentElement.tagName == SceneElements.BORDERV){
							currentElement.x = int(constructor.content.mouseX - currentElement.width / 2);
							currentElement.y = int(constructor.content.mouseY - currentElement.height / 2);
						}else{
							currentElement.x = int(constructor.content.mouseX);
							currentElement.y = int(constructor.content.mouseY);
						}
												
						
						currentElement.addEventListener(ConstructorElementEvent.SELECTED, onElementSelected, false, 0, true);
						currentElement.addEventListener(ConstructorElementEvent.UNSELECTED, onElementUnSelected, false, 0, true);
						
						if(currentElement.tagName == SceneElements.ROAD){
							constructor.content.addChildAt(currentElement, 0);
						}else{
							constructor.content.addChild(currentElement);
						}
						elementsObj[currentElement.elementId] = currentElement;
						
						_startCreatedPoint = new Point(constructor.content.mouseX, constructor.content.mouseY);
					}
					
				}
				
			}
		}
		
		private function onMouseUp(e:MouseEvent):void{
			if(currentElement){
				if(currentElement.width < 5 || currentElement.height < 5){
					GameApplication.app.popuper.showInfoPopUp("Недостаточная ширина или высота предмета.");
					_selectorElement.selected(currentElement);
					deleteSelectObject();
				}
			}
			currentElement = null;
			_startCreatedPoint = null;
			createmode = ConstructorCreateMode.NONE;
			state = ConstructorState.NONE;
			
			dispatchEvent(new ConstructorManagerEvent(ConstructorManagerEvent.ELEMENT_CREATED));
		}
		
		private function onMouseMove(e:MouseEvent):void{
			if(state == ConstructorState.RESIZE){
				if(_startCreatedPoint){
					var _startX:Number = Math.min(constructor.content.mouseX, _startCreatedPoint.x);
					var _startY:Number = Math.min(constructor.content.mouseY, _startCreatedPoint.y);
					
					var _elementW:Number = Math.abs(constructor.content.mouseX - _startCreatedPoint.x);
					var _elementH:Number = Math.abs(constructor.content.mouseY - _startCreatedPoint.y);
					
					currentElement.x = _startX;
					currentElement.y = _startY;
					
					currentElement.width = _elementW;
					currentElement.height = _elementH;
				}
			}
		}
		
		private function onElementSelected(event : ConstructorElementEvent) : void {
			_selectorElement.selected(event.element);
			dispatchEvent(new ConstructorElementEvent(ConstructorElementEvent.SELECTED, event.element));
		}
		
		private function onElementUnSelected(event : ConstructorElementEvent) : void {
			dispatchEvent(event.clone());
		}
		
		public function deleteSelectObject():void{
			var selectedElement:ConstructorElement = _selectorElement.selection as ConstructorElement;
			if(selectedElement){
				if(constructor){
					_selectorElement.clear();
					delete elementsObj[selectedElement.elementId];
					if(constructor.content.contains(selectedElement)){
						constructor.content.removeChild(selectedElement);
					}
				}
			}else{
				GameApplication.app.popuper.showInfoPopUp("Не выделен элемент! Если вы хотите удалить элемент, то выделите его, а затем нажмите на кнопку удаления.");
			}
		}
		
		public function play(gameType:int):void{
			var xml:XML = getLocationXML();
			if(xml){
				var users:Array = new Array();
				users.push(GameApplication.app.userinfomanager.myuser.id);
				
				var cars:Array = new Array();
				cars.push(GameApplication.app.models.cars.getCarPrototypeById(CarId.VAZ_2110));
				
				var colors:Array = new Array();
				colors.push(0xffffff);
				
				GameApplication.app.models.map.constructorMap = xml;
				GameApplication.app.gamemanager.gameworld = GameApplication.app.navigator.goGameWorld(1024, DistrictModel.DISTRICT4, users, cars, colors, gameType);
				GameApplication.app.gamemanager.gameworld.removeRoundTimer();
				GameApplication.app.gamemanager.gameworld.keyBoardReaction = true;
				
				testMode = true;
			}
		}
		
		public function save():void{
			var xml:XML = getLocationXML();
			if(xml){				
				var fileRef:FileReference = new FileReference();				
				fileRef.save(xml);
			}
		}
		
		public function shopSaveOnServerPopUp():void{
			var xml:XML = getLocationXML();
			if(xml){
				GameApplication.app.popuper.show(new PopUpSaveMap(xml));
			}
		}
		
		public function saveOnServer(fileName:String, content:String):void{
		}
		
		private function onSaveMap(buyresult:Object):void{
			if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OK){
				GameApplication.app.popuper.showInfoPopUp("Поздравляем! Ваша карта успешно сохранена на сервере!");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.NOT_ENOUGH_MONEY){
				GameApplication.app.popuper.showInfoPopUp("У Вас не достаточно денег.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.LOW_LEVEL){
				GameApplication.app.popuper.showInfoPopUp("У вас маленький уровень.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.EXIST){
				GameApplication.app.popuper.showInfoPopUp("Файл с таким именем уже существует на сервере. Выберите другое имя файла.");
			}else if (buyresult[ProtocolKeys.ERROR] == BuyResultCode.OTHER){
				GameApplication.app.popuper.showInfoPopUp("Невозможно сохранить карту. Вы можете сохранить максимум 3 карты в день.");
			}
		}
		private function onSaveMapError(error:Object):void{
			GameApplication.app.popuper.showInfoPopUp("Невозможно сохранить карту.");
		}
		
		public function open():void{
			_fileRef = new FileReference();
			_fileRef.browse([new FileFilter("Все файлы","*.*")]);
			
			_fileRef.addEventListener(Event.SELECT, onSelect, false, 0, true);			
		}
		
		private function onSelect(e:Event):void{
			_fileRef.removeEventListener(Event.SELECT, onSelect);
			_fileRef.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			_fileRef.load();
		}
		
		private function onLoadComplete(e:Event):void{
			_fileRef.removeEventListener(Event.COMPLETE, onLoadComplete);
			GameApplication.app.navigator.goConstructor(new XML(e.target.data));
		}
		
		public function getLocationXML():XML{		
			var startCreated:Boolean = false;
			var finishCreated:Boolean = false;
			var addZoneCreated:Boolean = false;
			var carCreated:Boolean = false;
			var countElement:uint = 0;
			
			var xmlString:String = "<?xml version='1.0' encoding='UTF-8'?>";
			xmlString += "<scene width='" + Math.max(minSceneWidth, Math.min(maxSceneWidth, sceneWidth)) + "' height='" + Math.max(minSceneHeight, Math.min(maxSceneHeight, sceneHeight)) + "'>";
			xmlString += "<laps count='" + Math.max(1, Math.min(10, _laps)) + "'/>";
			if(_creatorID == 0){
				_creatorID = GameApplication.app.userinfomanager.myuser.id;
			}
			xmlString += "<creator id='" + _creatorID + "'/>";
			xmlString += "<bg id='" + _bgId + "'/>";
			for each(var element:ConstructorElement in elementsObj){
				countElement++;
				var _x:Number = element.x;
				var _y:Number = element.y;
				var _cx:Number = element.x;
				var _cy:Number = element.y;
				
				var erotation:Number = element.rotation;				
				
				var bounds:Rectangle = element.getBounds(element.parent);
				_x = int(bounds.x + bounds.width / 2);
				_y = int(bounds.y + bounds.height / 2);
				
				element.rotation = 0;
				if(element.tagName == SceneElements.START || element.tagName == SceneElements.FINISH ||
					element.tagName == SceneElements.TRANSITION || element.tagName == SceneElements.BUILDING1 ||
					element.tagName == SceneElements.BUILDING2 || element.tagName == SceneElements.BUILDING3 ||
					element.tagName == SceneElements.BUILDING4 || element.tagName == SceneElements.GARLAND1 ||
					element.tagName == SceneElements.GARLAND2 || element.tagName == SceneElements.GARLAND3 ||
					element.tagName == SceneElements.TREE1 || element.tagName == SceneElements.TREE2 ||
					element.tagName == SceneElements.ADDITIONAL_ZONE || element.tagName == SceneElements.CAR){
					
					xmlString += "<" + element.tagName + " x='" + _x + "' y='" + _y + "' a='" + erotation + 
						"' w='" + element.width + "' h='" + element.height + "'/>";
				}else{
					xmlString += "<" + element.tagName + " x='" + _x + "' y='" + _y +
						"' w='" + element.width + "' h='" + element.height + "'/>";
				}
				element.rotation = erotation;
				
				if(element.tagName == SceneElements.START){
					if(startCreated){
						GameApplication.app.popuper.showInfoPopUp("На карте может быть только одно место START");
						return null;
					}
					startCreated = true;
				}
				if(element.tagName == SceneElements.FINISH){
					if(finishCreated){
						GameApplication.app.popuper.showInfoPopUp("На карте может быть только одно место FINISH");
						return null;
					}
					finishCreated = true;
				}
				if(element.tagName == SceneElements.ADDITIONAL_ZONE){
					if(addZoneCreated){
						GameApplication.app.popuper.showInfoPopUp("На карте может быть только одно место ADDITIONAL_ZONE");
						return null;
					}
					addZoneCreated = true;
				}
				if(element.tagName == SceneElements.CAR){
					if(carCreated){
						GameApplication.app.popuper.showInfoPopUp("На карте может быть только одно место CAR");
						return null;
					}
					carCreated = true;
				}
			}
			xmlString += "</scene>";
			
			var countElementK:Number = (sceneWidth * sceneHeight) / (minSceneWidth * minSceneHeight);
			if(countElement > Math.round(countElementK * 60)){
				GameApplication.app.popuper.showInfoPopUp("Слишком много элементов на карте!");
				return null;
			}
			
			if(startCreated && finishCreated && addZoneCreated && carCreated){
				return new XML(xmlString);
			}
			GameApplication.app.popuper.showInfoPopUp("На карте обязательно должны быть: место START, FINISH, ADDITIONAL_ZONE и CAR");
			return null;			
		}
	}
}