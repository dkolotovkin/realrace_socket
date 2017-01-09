package app.utils.map;

import java.util.ArrayList;
import java.util.List;

public class MapsModel {
	public List<MapModel> maps;
	
	public MapsModel(){
		maps = new ArrayList<MapModel>();
		
		addMap(1, 2);
		addMap(2, 2);
		addMap(3, 3);
		addMap(4, 3);
		addMap(5, 3);
		addMap(6, 3);
		addMap(7, 2);
		addMap(8, 2);
		addMap(9, 2);
		addMap(10, 3);
		addMap(11, 2);
		addMap(12, 3);
		addMap(13, 2);
		addMap(14, 2);
		addMap(15, 2);
		addMap(16, 3);
		addMap(17, 2);
		addMap(18, 3);
		addMap(19, 2);
		addMap(20, 2);
		addMap(21, 4);
		addMap(22, 2);
		addMap(23, 2);
		addMap(24, 3);
		addMap(25, 2);
		addMap(26, 2);
		addMap(27, 3);
		addMap(28, 2);
		addMap(29, 2);
		addMap(30, 2);
		addMap(31, 2);
		addMap(32, 3);
		addMap(33, 3);
		addMap(34, 2);
		addMap(35, 2);
		addMap(36, 3);
		addMap(37, 2);
		addMap(38, 5);
		addMap(39, 2);
		addMap(40, 2);
	}
	
	private void addMap(int mid, int laps){
		MapModel map = new MapModel(mid, laps);
		maps.add(map);
	}
	
	public MapModel getRandomMap(){
		int index = Math.round((float)Math.random() * (maps.size() - 1));
		return maps.get(index);
	}
}
