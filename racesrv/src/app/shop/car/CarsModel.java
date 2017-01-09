package app.shop.car;

import java.util.ArrayList;

public class CarsModel {
	public ArrayList<CarPrototypeModel> carPrototypes;
	
	public CarsModel(){
		carPrototypes = new ArrayList<CarPrototypeModel>();
		
		CarPrototypeModel carPrototype;
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.VAZ_2110;
		carPrototype.carClass = 1;
		carPrototype.title = "Ваз 2110";		
		carPrototype.minLevel = 1;
		carPrototype.price = 0;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.RENAULT_LOGAN;
		carPrototype.carClass = 1;
		carPrototype.title = "Renault Logan";
		carPrototype.minLevel = 2;
		carPrototype.price = 2000;
		carPrototype.rentPriceReal = 20;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.FORD_FOCUS;
		carPrototype.carClass = 2;
		carPrototype.title = "Ford Focus";
		carPrototype.minLevel = 3;
		carPrototype.price = 8000;
		carPrototype.rentPriceReal = 50;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.TOYOTA_COROLLA;
		carPrototype.carClass = 2;
		carPrototype.title = "Toyota Corolla";
		carPrototype.minLevel = 4;
		carPrototype.price = 15000;
		carPrototype.rentPriceReal = 100;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.OPEL_ASTRA;
		carPrototype.carClass = 2;
		carPrototype.title = "Opel Astra";
		carPrototype.minLevel = 5;
		carPrototype.price = 20000;
		carPrototype.rentPriceReal = 150;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.MAZDA_3;
		carPrototype.carClass = 3;
		carPrototype.title = "Mazda 3";
		carPrototype.minLevel = 7;
		carPrototype.price = 30000;
		carPrototype.rentPriceReal = 200;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.VOLKSWAGEN_GOLF;
		carPrototype.carClass = 3;
		carPrototype.title = "Volkswagen Golf";
		carPrototype.minLevel = 8;
		carPrototype.price = 40000;
		carPrototype.rentPriceReal = 250;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.VOLKSWAGEN_PASSAT;
		carPrototype.carClass = 3;
		carPrototype.title = "Volkswagen Passat";
		carPrototype.minLevel = 10;
		carPrototype.price = 50000;
		carPrototype.rentPriceReal = 300;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.BMW_325i;
		carPrototype.carClass = 4;
		carPrototype.title = "BMW 325i";
		carPrototype.minLevel = 12;
		carPrototype.price = 200000;
		carPrototype.rentPriceReal = 900;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.AUDI_A7;
		carPrototype.carClass = 4;
		carPrototype.title = "Audi A7";
		carPrototype.minLevel = 13;
		carPrototype.priceReal = 15000;
		carPrototype.rentPriceReal = 1000;
		carPrototypes.add(carPrototype);
		
		carPrototype = new CarPrototypeModel();
		carPrototype.id = CarId.MERCEDES_SLC;
		carPrototype.carClass = 4;
		carPrototype.title = "Mercedes SLC";
		carPrototype.minLevel = 15;
		carPrototype.priceReal = 18000;
		carPrototype.rentPriceReal = 1200;
		carPrototypes.add(carPrototype);
	}
	
	public CarPrototypeModel getCarPrototypeById(int pid){
		for(int i = 0; i < carPrototypes.size(); i++){
			if(carPrototypes.get(i).id == pid){
				return carPrototypes.get(i);
			}
		}
		return null;
	}
}
