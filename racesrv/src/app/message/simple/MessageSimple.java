package app.message.simple;

import app.message.Message;
import app.user.User;

public class MessageSimple extends Message {
	public String text;	
	public User fromUser;
	public User toUser;
	
	public MessageSimple(byte type, int roomId, String text, User fromUser, User toUser){
		super(type, roomId);
		this.text = text;
		this.fromUser = fromUser;
		this.toUser = toUser;
	}
}
