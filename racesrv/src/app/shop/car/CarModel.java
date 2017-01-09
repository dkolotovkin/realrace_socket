package app.shop.car;

import java.util.Date;

import app.Config;

public class CarModel {
	public int id;
	public CarPrototypeModel prototype;
	public int color;
	public int durability;
	public int durabilityMax = 100;
	public int rented = 0;
	public int rentTime = 0;
	
	public boolean changed = false;
	
	public boolean checkRentedTime(){
		Date date = new Date();
		int currenttime = (int)(date.getTime() / 1000);
		date = null;
		
		if(rented == 1 && (rentTime + Config.rentCarDuration() - currenttime > 0)){
			return true;
		}
		
		return false;
	}
}