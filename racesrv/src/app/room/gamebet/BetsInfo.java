package app.room.gamebet;

import java.util.ArrayList;
import java.util.List;

public class BetsInfo {
	public List<Integer> users = new ArrayList<Integer>();
	public List<BetInfo> bets = new ArrayList<BetInfo>();
	public int creatorid;
}
