package app.shop.item;

public class ItemPresent extends Item {
	public String presenter;
	
	public ItemPresent(int id, int prototypeid, int price, int pricereal, String title, String description, int count, String presenter){
		super(id, prototypeid, price, pricereal, title, description, count, 5);
		this.presenter = presenter;
	}
}
