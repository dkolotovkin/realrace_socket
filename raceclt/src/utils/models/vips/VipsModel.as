package utils.models.vips
{
	import mx.collections.ArrayCollection;
	
	import utils.models.ItemPrototype;
	import utils.models.item.ItemType;
	import utils.user.VipType;

	public class VipsModel
	{
		[Bindable]
		public var collection:ArrayCollection;
		
		public function VipsModel()
		{
			collection = new ArrayCollection();
			
			var vipPrototype:ItemPrototype;
			
			vipPrototype = new ItemPrototype(ItemType.VIP_BRONZE);
			vipPrototype.title = "Бронзовый VIP-аккаунт";
			vipPrototype.description = "В каждом выигранном забеге вы получаете +2 опыта, +10% популярности при совершении покупок. Срок действия 5 дней.";
			vipPrototype.price = 2000;
			collection.addItem(vipPrototype);
			
			vipPrototype = new ItemPrototype(ItemType.VIP_SILVER);
			vipPrototype.title = "Серебряный VIP-аккаунт";
			vipPrototype.description = "В каждом выигранном забеге вы получаете +3 опыта и +1 к опыту клуба, +20% популярности при совершении покупок. Срок действия 5 дней.";
			vipPrototype.price = 5000;
			collection.addItem(vipPrototype);
			
			vipPrototype = new ItemPrototype(ItemType.VIP_GOLD);
			vipPrototype.title = "Золотой VIP-аккаунт";
			vipPrototype.description = "В каждом выигранном забеге вы получаете +4 опыта и +1 к опыту клуба, +30% популярности при совершении покупок. Возможность БЕСПЛАТНО писать в общем чате. Срок действия 5 дней.";
			vipPrototype.priceReal = 300;
			collection.addItem(vipPrototype);
		}
	}
}