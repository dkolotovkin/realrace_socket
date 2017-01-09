package app.message.ban;

import app.message.Message;
import app.user.User;

public class BanMessage extends Message {	
	public User fromUser;
	public User toUser;
	public byte bantype;
	
	public BanMessage(byte type, int roomId, User fromUser, User toUser, byte bantype){
		super(type, roomId);
	
		this.fromUser = fromUser;
		this.toUser = toUser;
		this.bantype = bantype;
	}
}
