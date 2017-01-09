package utils.models
{
	import mx.collections.ArrayCollection;
	
	import utils.models.item.Item;

	public class UserItemsCollectionModel
	{
		private var _collection:ArrayCollection;
		
		[Bindable]
		public function get collection():ArrayCollection{
			return _collection;
		}
		
		public function set collection(value:ArrayCollection):void{
		}
		
		public function UserItemsCollectionModel()
		{
			_collection = new ArrayCollection();
		}
		
		public function getModelById(id:int):Item{
			var model:Item;
			for each(model in collection){
				if(model.id == id)
					return model;
			}
			
			model = new Item(id);
			collection.addItem(model);
			return model;
		}
	}
}