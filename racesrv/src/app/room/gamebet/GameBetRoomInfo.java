package app.room.gamebet;

import java.util.List;

public class GameBetRoomInfo {
	public int id;
	public int bet;
	public int time;
	public boolean rlocked;
	public boolean isseats;
	public List<String> users;
	
	public GameBetRoomInfo(int id, int bet, int time, boolean rlocked, boolean isseats, List<String> users){
		this.id = id;
		this.bet = bet;
		this.time = time;
		this.isseats = isseats;
		this.rlocked = rlocked;
		this.users = users;
	}
}
