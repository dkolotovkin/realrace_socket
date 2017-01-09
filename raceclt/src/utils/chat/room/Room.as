package utils.chat.room
{
	import application.GameApplication;
	import application.components.popup.present.PopUpRecievePresent;
	import application.gamecontainer.chat.actionmenu.chatuser.ActionMenuChatUser;
	import application.gamecontainer.scene.catalog.article.LibraryMovieClass;
	
	import flash.events.EventDispatcher;
	import flash.text.engine.FontWeight;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.InlineGraphicElement;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	
	import mx.collections.ArrayCollection;
	
	import utils.chat.UserSprite;
	import utils.chat.formats.ChatActionFormat;
	import utils.chat.formats.ChatRegExp;
	import utils.chat.formats.ChatSmiles;
	import utils.chat.message.MessageType;
	import utils.managers.ban.BanType;
	import utils.models.ItemPrototype;
	import utils.protocol.ProtocolKeys;
	import utils.selector.ISelected;
	import utils.sound.SoundType;
	import utils.user.User;
	import utils.user.UserRole;

	public class Room extends EventDispatcher implements ISelected
	{
		public static var COMMON:int = 1;
		
		public var title : String;
		protected var _id : int;
		protected var _selected : Boolean;
		protected var _messages : int = 0;		
		protected var _cache : TextFlow;
		protected var _users : Object = new Object();
		private var urlPartsArr:Array = new Array("http://","https://","ftp://",".ru",".com",".net",".org");
				
		private var _stacksid:int = -1;
		private var _stackmessages:Array = new Array();
		
		public var usersCollection:ArrayCollection;
		
		public function get id() : String {
			return _id.toString();
		}	
		
		public function get selected() : Boolean {
			return _selected;
		}
		
		public function set selected(value : Boolean) : void {
			if (_selected != value) {
				_selected = value;
			}	
		}
		
		public function get users():Object{
			return _users;
		}
		
		public function set users(value:Object):void{
			_users = value;
		}
		
		public function Room(id : int, title : String, users:Array = null, messages:Array = null)
		{
			this.title = title;			
			_id = id;
			_cache = new TextFlow();
			
			usersCollection = new ArrayCollection();
			
			//ДЛЯ РАБОТЫ ССЫЛОК ПРИ ПУСТОМ TextFlow ПРИ ИНИЦИАОИЗАЦИИ (неизвестно почему так, возможно баг flex sdk)
			addAndRemoveSimpleLink();			
			
			if(users && users.length){
				for(var i:uint = 0; i < users.length; i++){
					addUser(users[i]);
				}	
			}
			
			if(messages && messages.length){				
				for(var j:uint = 0; j < messages.length; j++){	
					addMessage(messages[j], true, true);
				}
			}			
		}
		
		private function addAndRemoveSimpleLink():void{
			var link : LinkElement = new LinkElement();
			var p:ParagraphElement = new ParagraphElement();
			p.addChild(link);
			_cache.addChild(p);
			_cache.removeChild(p);
		}
		
		public function addUser(u : Object) : Boolean {
			var user:User;
			if(u is User){
				user = (u as User).clone();
			}else{
				user = createUser(u);
			}
			user.isonline = true;
			
			if(!_users[user.id]){
				_users[user.id] = user;
				usersCollection.addItemAt(user, 0);
				return true;
			}
			return false;
		}
		public function createUser(u:Object):User{			
			if(u){
				var user:User = new User();
				if (!_users[int(u[ProtocolKeys.ID])]){
					user.id = int(u[ProtocolKeys.ID]);
					user.idSocial = String(u[ProtocolKeys.ID_SOCIAL]);
					user.sex = int(u[ProtocolKeys.SEX]);
					user.title = String(u[ProtocolKeys.TITLE]);	
					user.level = int(u[ProtocolKeys.LEVEL]);
					user.role = int(u[ProtocolKeys.ROLE]);
					user.url = String(u[ProtocolKeys.URL]);
					user.popular = int(u[ProtocolKeys.POPULAR]);
				}else{
					user = _users[int(u[ProtocolKeys.ID])];
				}
				return user;
			}
			return null;
		}
		
		public function removeUser(id : int) : User {			
			var user : User = _users[id];
			if(user){
				var userInCollection:User;
				for(var i:int = 0; i < usersCollection.length; i++){
					userInCollection = usersCollection.getItemAt(i) as User;
					if(userInCollection && userInCollection.id == id){
						usersCollection.removeItemAt(i);
						break;
					}
				}
				delete _users[id];
			}
			return user;
		}
		
		public function getUser(id : int) : User {
			return _users[id];
		}
		
		public function addMessage(message : Object, dispach : Boolean = true, ishistory:Boolean = false) : void {			
			if (ishistory){
				addM(message, dispach, ishistory);
			}else{
				_stackmessages.push(message);
				if(_stacksid == -1){
					_stacksid = setInterval(addStackMessage, 500);
					addM(_stackmessages.shift());
				}
			}
		}
		
		private function addM(message : Object, dispach : Boolean = true, ishistory:Boolean = false):void{
			var p : ParagraphElement = getMessageString(message, ishistory);
			
			if(!p){
				return;
			}
			
			if ((_cache.getChildAt(0) as ParagraphElement) && 
				((_cache.getChildAt(0) as ParagraphElement).getChildAt(0) as SpanElement) && 
				(((_cache.getChildAt(0) as ParagraphElement).getChildAt(0) as SpanElement).text == "")){
				_cache.removeChildAt(0);
			} 
			if (_cache.numChildren > GameApplication.app.config.maxMessagesInRoom) {
				_cache.removeChildAt(0);				
			}
			dispach && p && _cache.addChild(p);			
			dispatchEvent(new RoomEvent(RoomEvent.ADD_MESSAGE, null, this));
		}
		
		private function addStackMessage():void{			
			if(_stackmessages.length == 0){
				if(_stacksid != -1){
					clearInterval(_stacksid);
					_stacksid = -1;
				}
			}else{
				addM(_stackmessages.shift());
			}
		}
		
		private function getMessageString(m : Object, ishistory:Boolean = false) : ParagraphElement {
			var from:User;
			if(m[ProtocolKeys.FROM]){
				from = createUser(m[ProtocolKeys.FROM]);
			}else{
				from = users[m[ProtocolKeys.FROM_ID]];
			}
			
			var mType:int = m[ProtocolKeys.TYPE];
			if(from == null && mType != MessageType.USER_NOT_FIND && mType != MessageType.SYSTEM){
				return null;
			}
			
			if(int(id) == COMMON && (mType == MessageType.MESSAGE || mType == MessageType.PRESENT)){
				if(from && !GameApplication.app.models.usersOfLastMessagesHash[from.id]){
					GameApplication.app.models.usersOfLastMessages.addItemAt(from, 0);
					GameApplication.app.models.usersOfLastMessagesHash[from.id] = from.id;
						
					if(GameApplication.app.models.usersOfLastMessages.length > 10){
						var lasrtUserInQueue:User = GameApplication.app.models.usersOfLastMessages.getItemAt(GameApplication.app.models.usersOfLastMessages.length - 1) as User;
						if(lasrtUserInQueue){
							delete GameApplication.app.models.usersOfLastMessagesHash[lasrtUserInQueue.id];
						}
						GameApplication.app.models.usersOfLastMessages.removeItemAt(GameApplication.app.models.usersOfLastMessages.length - 1);
					}
				}
			}
			
			var to:User;
			if(m[ProtocolKeys.TO]){
				to = createUser(m[ProtocolKeys.TO]);
			}else{
				to = users[m[ProtocolKeys.TO_ID]];
			}
			
			var p : ParagraphElement = new ParagraphElement();
			var ui : ChatActionFormat = new ChatActionFormat("_sans", 12, 0x00FFFF, 0xf7f7f7, FontWeight.NORMAL, false);
			var ban : ChatActionFormat = new ChatActionFormat("_sans", 12, 0xFF66CC, 0xf7f7f7, FontWeight.NORMAL, false);
			var tf : ChatActionFormat = new ChatActionFormat("_sans", 12, 0xffffff, 0xf7f7f7, FontWeight.NORMAL, false);
			//system
			var stf : ChatActionFormat = new ChatActionFormat("_sans", 12, 0xFF66CC, 0xf7f7f7, FontWeight.NORMAL, false);
			//jackpot
			var jptf : ChatActionFormat = new ChatActionFormat("_sans", 12, 0xFF66CC, 0xf7f7f7, FontWeight.NORMAL, false);
			//offline
			var otf : ChatActionFormat = new ChatActionFormat("_sans", 12, 0xC4C4C4, 0xf7f7f7, FontWeight.NORMAL, false);						
			
			var space_span:SpanElement = new SpanElement();
			space_span.text = " ";
			space_span.fontSize = tf.size;
			space_span.fontFamily = tf.font;
			
			var points_space_span : SpanElement = new SpanElement();
			points_space_span.text = ": ";
			points_space_span.color = tf.color;
			points_space_span.fontSize = tf.size;
			points_space_span.fontFamily = tf.font;
			
			var for_span:SpanElement = new SpanElement();
			for_span.text = " для ";            
			for_span.color = otf.color;
			for_span.fontSize = otf.size;			
			for_span.fontFamily = otf.font;			
			
			var warning_span:SpanElement = new SpanElement();
			warning_span.text = "Неверная команда: ";
			warning_span.fontSize = stf.size;
			warning_span.color = stf.color;			
			warning_span.fontFamily = stf.font;
			
			var present_span:SpanElement = new SpanElement();
			present_span.text = " подарил ";            
			present_span.color = ban.color;
			present_span.fontSize = ban.size;			
			present_span.fontFamily = ban.font;
				
			if (!ishistory){
				p = createParagraphTime(p);
			}
			
			if (m[ProtocolKeys.TYPE] == MessageType.SYSTEM){
				p = createParagraphMessage(p, m, stf);				
				return p;				
			}else if(from == null){
				var m:Object = new Object();
				m[ProtocolKeys.TYPE] = MessageType.SYSTEM;
				m[ProtocolKeys.TEXT] = "Пользователь вышел из игры";				
				p = createParagraphMessage(p, m, stf);
				return p;
			}else if (m[ProtocolKeys.TYPE] == MessageType.MESSAGE && to) {
				createNickIcon(p, from.popular);
				p.addChild(createHtmlNick(from, true, tf.bgc));
				p.addChild(createUserSprite(from));
				p.addChild(for_span);
				createNickIcon(p, to.popular);
				p.addChild(createHtmlNick(to, true, tf.bgc));
				p.addChild(createUserSprite(to));	
				p.addChild(points_space_span);
				p = createParagraphMessage(p, m, tf);
				return p;					
			}else if(m.flags == MessageType.PRIVATE) {				
			}else if(m[ProtocolKeys.TYPE] == MessageType.USEITEM) {
				createNickIcon(p, from.popular);
				p.addChild(createHtmlNick(from, true, tf.bgc));	
				p.addChild(createUserSprite(from));
				p.addChild(points_space_span);
				p = createParagraphMessage(p, m, ui);				
				return p;
			}else if(m[ProtocolKeys.TYPE] == MessageType.BAN) {
				if(from && from.id == GameApplication.app.userinfomanager.myuser.id ||
					to && to.id == GameApplication.app.userinfomanager.myuser.id){
					//отображаем сообщения в любом случае
				}else{
					if(!GameApplication.app.models.settings.banMessagesVisible){
						return null;
					}
				}
				
				var time:String;
				var t:int;				
				if (m[ProtocolKeys.BANTYPE] == BanType.MINUT5){
					time = " на 5 минут";
					t = 5 * 60;
				}else if (m[ProtocolKeys.BANTYPE] == BanType.MINUT15){
					time = " на 15 минут";
					t = 15 * 60;
				}else if (m[ProtocolKeys.BANTYPE] == BanType.MINUT30){
					time = " на 30 минут";
					t = 30 * 60;
				}else if (m[ProtocolKeys.BANTYPE] == BanType.HOUR1){
					time = " на 1 час";
					t = 60 * 60;
				}else if (m[ProtocolKeys.BANTYPE] == BanType.DAY1){
					time = " на 1 день";
					t = 60 * 60 * 24;
				}else if (m[ProtocolKeys.BANTYPE] == BanType.WEEK){
					time = " на 1 неделю";
					t = 60 * 60 * 24 * 7;
				}
				if(to && to.id == GameApplication.app.userinfomanager.myuser.id && !ishistory){
					GameApplication.app.banmanager.setBanTime(t);
				}
				
				createNickIcon(p, from.popular);
				p.addChild(createHtmlNick(from, true, tf.bgc));
				p.addChild(createUserSprite(from));
				
				var ban1_span:SpanElement = new SpanElement();
				ban1_span.text = " отправил в бан ";            
				ban1_span.color = ban.color;
				ban1_span.fontSize = ban.size;			
				ban1_span.fontFamily = ban.font;
				p.addChild(ban1_span);
				
				var ban_uout:SpanElement = new SpanElement();
				ban_uout.text = "вышедшего из игры пользователя ";            
				ban_uout.color = ban.color;
				ban_uout.fontSize = ban.size;			
				ban_uout.fontFamily = ban.font;				
				
				if (to != null){
					createNickIcon(p, to.popular);
					p.addChild(createHtmlNick(to, true, tf.bgc));
					p.addChild(createUserSprite(to));
				}else{
					p.addChild(ban_uout);
				}
				
				var ban2_span:SpanElement = new SpanElement();
				ban2_span.text = time;            
				ban2_span.color = ban.color;
				ban2_span.fontSize = ban.size;			
				ban2_span.fontFamily = ban.font;
				p.addChild(ban2_span);	
				return p;
			}else if(m[ProtocolKeys.TYPE] == MessageType.BAN_OUT) {
				if(from && from.id == GameApplication.app.userinfomanager.myuser.id ||
					to && to.id == GameApplication.app.userinfomanager.myuser.id){
					//отображаем сообщения в любом случае
				}else{
					if(!GameApplication.app.models.settings.banMessagesVisible){
						return null;
					}
				}
				
				createNickIcon(p, from.popular);
				p.addChild(createHtmlNick(from, true, tf.bgc));
				p.addChild(createUserSprite(from));
				
				var banout_span:SpanElement = new SpanElement();
				banout_span.text = " вышел из бана";            
				banout_span.color = ban.color;
				banout_span.fontSize = ban.size;			
				banout_span.fontFamily = ban.font;
				p.addChild(banout_span);
				return p;
			}else if(m[ProtocolKeys.TYPE] == MessageType.PRESENT){
				if(from && from.id == GameApplication.app.userinfomanager.myuser.id ||
					to && to.id == GameApplication.app.userinfomanager.myuser.id){
					//отображаем сообщения в любом случае
				}else{
					if(!GameApplication.app.models.settings.presentMessagesVisible){
						return null;
					}
				}
				
				createNickIcon(p, from.popular);
				p.addChild(createHtmlNick(from, true, tf.bgc));
				p.addChild(createUserSprite(from));
				
				if(to){
					p.addChild(present_span);
					createNickIcon(p, to.popular);
					p.addChild(createHtmlNick(to, true, tf.bgc));
					p.addChild(createUserSprite(to));
					p.addChild(space_span);					
					
					if(to.id == GameApplication.app.userinfomanager.myuser.id && !ishistory && !GameApplication.app.gamemanager.gameMode){
						var itemprototype:ItemPrototype = new ItemPrototype(m[ProtocolKeys.PROTOTYPE_ID]);
						itemprototype.title = "";
						itemprototype.description = "";
						itemprototype.count = 1;
						itemprototype.price = 0;
						itemprototype.priceReal = 0;
						itemprototype.showed = 1;
						GameApplication.app.popuper.show(new PopUpRecievePresent(itemprototype, "Пользователь " + from.title + " преподнес вам подарок!"));
					}
				}else{
					var presentout_span:SpanElement = new SpanElement();
					presentout_span.text = " подарил вышедшему из игры пользователю ";            
					presentout_span.color = ban.color;
					presentout_span.fontSize = ban.size;			
					presentout_span.fontFamily = ban.font;
					p.addChild(presentout_span);
				}		
				
				createPresentMessage(p, m[ProtocolKeys.PROTOTYPE_ID]);
				
				if(int(m[ProtocolKeys.PRICE]) < 500 && int(m[ProtocolKeys.PRICE_REAL]) <= 0){
					if(from && from.id == GameApplication.app.userinfomanager.myuser.id ||
						to && to.id == GameApplication.app.userinfomanager.myuser.id){
					}else{
						return null;
					}
				}
				return p;
			}
			
			createNickIcon(p, from.popular);
			p.addChild(createHtmlNick(from, true, tf.bgc));	
			p.addChild(createUserSprite(from));
			p.addChild(points_space_span);
			p = createParagraphMessage(p, m, tf);
			var inf : Object = {color:stf.color};
			p.linkHoverFormat = inf;			
			return p;
		}
		
		private function createParagraphTime(p : ParagraphElement) : ParagraphElement {
			var date : Date = new Date();
			var hours : String;
			var minutes : String;
			var seconds : String;				
			if (date.getHours() < 10) hours = "0" + date.getHours();
			else hours = "" + date.getHours();
			if (date.getMinutes() < 10) minutes = "0" + date.getMinutes();
			else minutes = "" + date.getMinutes();
			if (date.getSeconds() < 10) seconds = "0" + date.getSeconds();
			else seconds = "" + date.getSeconds();
			var time : SpanElement = new SpanElement();
			time.text = hours + ":" + minutes + ":" + seconds + " ";
			time.fontSize = 10;
			time.color = 0xFFFFCC;
			time.fontFamily = '_sans';				
			
			p.addChild(time);
			return p;
		}
		
		private function createUserSprite(user : User) : InlineGraphicElement {
			var sige : InlineGraphicElement;
			sige = new InlineGraphicElement();
			var _spr : UserSprite = new UserSprite();
			_spr.user = user;									
			sige.source = _spr;
			return sige;
		}
		
		private function createHtmlNick (user:User, active:Boolean = true, bgc:uint = 0xF7F7F7):FlowElement{
			if (user){
				var link:LinkElement = new LinkElement();
				var linkSpan:SpanElement = new SpanElement();
				linkSpan.fontSize = 12;
				linkSpan.fontFamily = '_sans';
				
				if (active && (user.id != GameApplication.app.userinfomanager.myuser.id)){										
					link.href = "event:" + user.id;					
					link.id = user.title;					
					
					var overf : Object = {color:0xCCFF66};
					var normalf : Object = {color:0x00FF00};
					if(UserRole.isModerator(user.role)){
						normalf = {color:0x00FFFF};
					}else if(UserRole.isAdministrator(user.role) || UserRole.isAdministratorMain(user.role)){
						normalf = {color:0xFD92FE};
					}
					
					link.linkHoverFormat = overf;
					link.linkNormalFormat = normalf;
					
					link.addEventListener(FlowElementMouseEvent.CLICK, onLinkPress, false, 0, true);
					
					linkSpan.text = user.title;
					linkSpan.textDecoration = 'none';            	           		
					link.addChild(linkSpan);            	            		
					
					return link;				
				}			
				linkSpan = new SpanElement();
				linkSpan.text = user.title;
				linkSpan.color = 0xC4C4C4;
				linkSpan.fontSize = 12;
				linkSpan.fontFamily = '_sans';						
				return linkSpan;
			}else{
				return null;
			}
		}
		
		private function onLinkPress(e:FlowElementMouseEvent):void{
			var grElem:InlineGraphicElement = (e.flowElement as FlowElement).getNextSibling() as InlineGraphicElement;
			if(grElem){
				var u:User = (grElem.source as UserSprite).user;
				if(GameApplication.app.config.playmode != 1 && u.id > 0 && u.id != GameApplication.app.userinfomanager.myuser.id){
					GameApplication.app.actionShowerMenu.showMenu(new ActionMenuChatUser(u));					
				}
				
				GameApplication.app.soundmanager.play(SoundType.CLICK);
			}
		}
		
		private function createPresentMessage(p : ParagraphElement,prototypeID:int):ParagraphElement{
			var inlineGraphicElement : InlineGraphicElement = new InlineGraphicElement();			
			if (prototypeID > 0) {	
				var Present : Class = LibraryMovieClass.getClassByItemPrototypeID(prototypeID);
				if (Present) {					
					inlineGraphicElement = new InlineGraphicElement();
					inlineGraphicElement.source = new Present();	
					
					var needHeight:Number = LibraryMovieClass.getPresentChatSize(prototypeID);
					var k:Number;
					k = needHeight / inlineGraphicElement.source.height;
					inlineGraphicElement.source.height *= k;
					inlineGraphicElement.source.width *= k;
					
					p.addChild(inlineGraphicElement);
				}
			}			
			return p;
		}
		
		private function createNickIcon(p : ParagraphElement, popular:int):ParagraphElement{
			var inlineGraphicElement : InlineGraphicElement = new InlineGraphicElement();			
			var Icon : Class = GameApplication.app.userinfomanager.getPopularIconClass(popular);												 
			if (Icon) {					
				inlineGraphicElement = new InlineGraphicElement();
				inlineGraphicElement.source = new Icon();
				
				var needHeight:Number = 20;
				var k:Number;
				k = needHeight / inlineGraphicElement.source.height;
				inlineGraphicElement.source.height *= k;
				inlineGraphicElement.source.width *= k;
				
				var space_span:SpanElement = new SpanElement();
				space_span.text = " ";				
				
				p.addChild(inlineGraphicElement);
				p.addChild(space_span);
			}		
			return p;
		}
		
		private function createParagraphMessage(p : ParagraphElement, m : Object, tf : ChatActionFormat) : ParagraphElement {
			var inlineGraphicElement : InlineGraphicElement = new InlineGraphicElement();			
			var span : SpanElement = new SpanElement();
			var arrElems : Array = new Array();
			var ms : String = m[ProtocolKeys.TEXT];			
			
			if (ms && ms.length > 0) {	
				arrElems = ms.split(ChatRegExp.seprator);
				for each (var e : String in arrElems) {
					var smile : Class = ChatSmiles.getSmile(e);
//					_urlFinder.lastIndex = 0;
//					var arrExec:* = _urlFinder.exec(e);
					
					var findUrlPart:Boolean = false;
					for(var i:int = 0; i < urlPartsArr.length; i++){
						if(e.indexOf(urlPartsArr[i]) != -1){
							findUrlPart = true;
						}
					}
					
					if (smile) {					
						inlineGraphicElement = new InlineGraphicElement();
						inlineGraphicElement.source = new smile();
						p.addChild(inlineGraphicElement);
					}else if(findUrlPart) {						
						/*var linkElem:LinkElement = new LinkElement();
						var linkSpan:SpanElement = new SpanElement();
						linkSpan.fontSize = 12;
						linkSpan.color = 0x1C60DB;
						linkSpan.fontFamily = tf.font;
						linkElem.href = "http://" + (arrExec as Array)[2] + (arrExec as Array)[4];
						linkSpan.text = e;						
						
						linkSpan.textDecoration = 'none';
						linkElem.addChild(linkSpan);
						p.addChild(linkElem);*/
						
						span = new SpanElement();
						span.text = "************";                                   
						span.color = tf.color;						
						span.fontFamily = tf.font;
						span.fontWeight = tf.bold;
						p.addChild(span);
					}else if (e.length) {
						span = new SpanElement();
						span.text = e;                                   
						span.color = tf.color;						
						span.fontFamily = tf.font;
						span.fontWeight = tf.bold;
						p.addChild(span);
					}
				}
			}			
			return p;
		}
		
		public function getText() : TextFlow {						
			return _cache;
		}
		
		public function getUserByNick(nick : String) : User {
			for each (var user : User in _users) {
				if (user.title == nick) {
					return user;
				}
			}
			return null;
		}
		
		public function clear() : void {
			_messages = 0;
			_cache = new TextFlow();
			users = new Object();
			usersCollection.removeAll();
		}
	}
}