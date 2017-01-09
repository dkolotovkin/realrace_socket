package utils.models
{
	import mx.collections.ArrayCollection;

	public class ItemPrototypesCollectionModel
	{
		private var _collection:ArrayCollection;
		
		[Bindable]
		public function get collection():ArrayCollection{
			return _collection;
		}
		
		public function set collection(value:ArrayCollection):void{
		}
		
		public function ItemPrototypesCollectionModel()
		{
			_collection = new ArrayCollection();
		}
		
		public function getModelById(id:int):ItemPrototype{
			var model:ItemPrototype;
			for each(model in collection){
				if(model.id == id)
					return model;
			}
			
			model = new ItemPrototype(id);
			collection.addItem(model);
			return model;
		}
	}
}