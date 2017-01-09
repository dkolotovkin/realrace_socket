package utils.models
{
	import utils.user.User;

	public class MailMessageModel
	{
		public var id:int;
		public var text:String;
		public var user:User;
		public var ctime:String;
		
		public function MailMessageModel(u:User, t:String, mid:int, ctime:String)
		{
			this.user = u;
			this.text = t;
			this.id = mid;
			this.ctime = ctime;
		}
	}
}