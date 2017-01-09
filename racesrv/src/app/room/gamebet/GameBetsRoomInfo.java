package app.room.gamebet;

import java.util.List;

import app.user.UserConnection;

public class GameBetsRoomInfo {
	public int id;
	public UserConnection creator;
	public boolean isseats;
	public List<String> users;
	
	public GameBetsRoomInfo(int id, UserConnection creator, boolean isseats, List<String> users){
		this.id = id;
		this.creator = creator;
		this.isseats = isseats;
		this.users = users;
	}
}
