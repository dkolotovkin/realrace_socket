package app.utils.map;


public class MapModel {
	public int id;
	public int laps;
	public int time;
	
	public MapModel(int id, int laps){
		this.id = id;
		this.laps = laps;
		this.time = 5 * 60;
	}
}
