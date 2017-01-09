package app.message.present;

import app.message.Message;
import app.user.User;

public class MessagePresent extends Message{
	public int prototypeid;
	public int prototypeprice;
	public int prototypepricereal;
	public User fromUser;
	public User toUser;
	
	public MessagePresent(byte type, int roomId, int prototypeid, int prototypeprice, int prototypepricereal, User fromUser, User toUser){
		super(type, roomId);
		this.prototypeid = prototypeid;
		this.prototypeprice = prototypeprice;
		this.prototypepricereal = prototypepricereal;
		this.fromUser = fromUser;
		this.toUser = toUser;
	}
}
