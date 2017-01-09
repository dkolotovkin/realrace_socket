package application.gamecontainer.chat.actionmenu.chatuser {	
	import application.GameApplication;
	import application.GameMode;
	import application.components.popup.addfriend.PopUpAddFriend;
	import application.components.popup.ban.PopUpBan;
	import application.components.popup.buylink.PopUpBuyLink;
	import application.components.popup.present.PopUpPresent;
	import application.components.popup.sendmail.PopUpSendMail;
	import application.components.preloader.PreLoaderCircle;
	import application.gamecontainer.chat.actionmenu.ActionMenu;
	import application.gamecontainer.chat.actionmenu.Actions;
	
	import utils.managers.apimanager.ApiManagerMB;
	import utils.user.ClanUserRole;
	import utils.user.User;
	import utils.user.UserRole;

	/**
	 * @author dkolotovkin
	 */
	public class ActionMenuChatUser extends ActionMenu {

		private var _user : User;
		
		public function ActionMenuChatUser(user : User) {
			super();
			_user = user;			
			title = user.title;
		}
		
		override protected function createChildren() : void {
			super.createChildren();
			
			var addLink:Boolean = false;
			_titleComponent.setTitle(_user.title, true, _user.level);
			addAndCreateControl(Actions.INFO, "Информация");
			if(_user.id != GameApplication.app.userinfomanager.myuser.id){
				addAndCreateControl(Actions.WRITE_TO, "Написать пользователю");
				addAndCreateControl(Actions.PRIVATE, "Приватное сообщение");
				var myRole:int = GameApplication.app.userinfomanager.myuser.role;
				if(UserRole.isAdministrator(myRole) || UserRole.isAdministratorMain(myRole) || UserRole.isModerator(myRole) ||
					(!UserRole.isAdministrator(_user.role) && !UserRole.isAdministratorMain(_user.role) && !UserRole.isModerator(_user.role)
					&& GameApplication.app.banmanager.bantime == 0)){
					addAndCreateControl(Actions.BAN, "Забанить");
				}
				addAndCreateControl(Actions.ADD_TO_FRIEND, "Добавить в друзья");
				addAndCreateControl(Actions.ADD_TO_ENEMY, "Добавить во враги");
//				addAndCreateControl(Actions.SEND_MAIL, "Отправить почту");
				if (GameApplication.app.config.mode == GameMode.MM || GameApplication.app.config.mode == GameMode.OD){
					addAndCreateControl(Actions.ADD_MONEY, "Пополнить счет другу");
				}
				
				if(!(GameApplication.app.navigator.currentSceneContent is PreLoaderCircle)){
					addAndCreateControl(Actions.PRESENT, "Подарить");
				}
				
				if (_user.url != null && _user.url.length > 0){
					var vkRE:RegExp = /(http:\/\/)vkontakte(\S*)/g;
					var mmRE:RegExp = /(http:\/\/)my.mail(\S*)/g;
					var odRE:RegExp = /(http:\/\/)odnoklassniki(\S*)/g;
					if (GameApplication.app.config.mode == GameMode.VK && vkRE.exec(_user.url) != null ||
						GameApplication.app.config.mode == GameMode.MM && mmRE.exec(_user.url) != null ||
						GameApplication.app.config.mode == GameMode.OD && odRE.exec(_user.url) != null ||
						GameApplication.app.config.mode == GameMode.DEBUG || GameApplication.app.config.mode == GameMode.SITE || 
						UserRole.isAdministrator(GameApplication.app.userinfomanager.myuser.role) || 
						UserRole.isAdministratorMain(GameApplication.app.userinfomanager.myuser.role))
					{
						addLink = true;
						addAndCreateControl(Actions.LINK, "Страничка");
					}
				}
				
				if(GameApplication.app.userinfomanager.myuser.claninfo.clanrole == ClanUserRole.OWNER){
					addAndCreateControl(Actions.CLANINVITE, "Пригласить в клуб");
				}
			}
		}
		
		override protected function onAction(id : String) : void {
			super.onAction(id);		
			
			GameApplication.app.popuper.hidePopUp();
			if (id == Actions.INFO){
				GameApplication.app.adminmanager.lastUserID = _user.id;
				GameApplication.app.userinfomanager.showUserInfo(_user);
			}else if(id == Actions.WRITE_TO){		
				GameApplication.app.models.chatForUser = _user;
			}else if(id == Actions.PRIVATE){	
				GameApplication.app.gameContainer.chat.onSetPrivateUser(_user);		
			}else if(id == Actions.ADD_TO_FRIEND){	
				GameApplication.app.popuper.show(new PopUpAddFriend(_user.clone()));
			}else if(id == Actions.ADD_TO_ENEMY){	
				GameApplication.app.userinfomanager.addToEnemy(_user.id);
			}else if(id == Actions.SEND_MAIL){
				GameApplication.app.popuper.show(new PopUpSendMail(_user));
			}else if(id == Actions.BAN){	
				GameApplication.app.popuper.show(new PopUpBan(_user.id));	
			}else if(id == Actions.LINK){
				GameApplication.app.popuper.show(new PopUpBuyLink(_user.url));					
			}else if(id == Actions.CLANINVITE){				
				GameApplication.app.clanmanager.inviteuser(_user);
			}else if(id == Actions.PRESENT){
				GameApplication.app.popuper.show(new PopUpPresent(_user.id));
			}else if(id == Actions.ADD_MONEY){
				GameApplication.app.apimanager.addMoneyUserID = _user.id;
				GameApplication.app.apimanager.showBuyMoneyPopUp();
			}
		}
	}
}
