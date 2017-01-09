package utils.game.betroominfo
{
	import application.GameApplication;
	
	import utils.user.User;

	public class GameBetRoomInfo
	{
		public var id:int;
		public var creator:User;
		[Bindable]
		public var bet:int;
		[Bindable]
		public var time:int;
		[Bindable]
		public var isseats:Boolean;
		[Bindable]
		public var passward:Boolean;
		public var users:Array = new Array();
		
		public function GameBetRoomInfo(id:int, bet:int, time:int, isseats:Boolean, passward:Boolean, users:Array, creator:User){
			this.id = id;
			this.bet = bet;
			this.time = time;
			this.isseats = isseats;
			this.passward = passward;
			this.creator = creator;
			
			for(var i:int = 0; i < users.length; i++){
				this.users.push(users[i]);
			}
		}
	}
}