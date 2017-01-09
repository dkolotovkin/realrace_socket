package app.utils.gameaction.start;

import java.util.List;

import app.utils.gameaction.GameAction;
import app.utils.map.MapModel;

public class GameActionStart extends GameAction {
	public MapModel map;
	public int districtID;
	public List<Integer> users;
	public List<Integer> usersCars;
	public List<Integer> carsColors;
	public byte gametype;
	
	public GameActionStart(byte type, int roomID){
		super(type, roomID);
	}
}
