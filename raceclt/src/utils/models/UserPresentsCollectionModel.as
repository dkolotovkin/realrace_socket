package utils.models
{
	import mx.collections.ArrayCollection;
	
	import utils.models.item.ItemPresent;

	public class UserPresentsCollectionModel
	{
		private var _collection:ArrayCollection;
		
		public var end:Boolean = false;
		public var getting:Boolean = false;
		
		[Bindable]
		public function get collection():ArrayCollection{
			return _collection;
		}
		
		public function set collection(value:ArrayCollection):void{
			_collection = value;
		}
		
		public function UserPresentsCollectionModel()
		{
			_collection = new ArrayCollection();
		}
		
		public function getModelById(id:int):ItemPresent{
			var model:ItemPresent;
			for each(model in collection){
				if(model.id == id)
					return model;
			}
			
			model = new ItemPresent(id);
			collection.addItem(model);
			return model;
		}
		
		public function removeModelById(id:int):void{
			var model:ItemPresent;
			for(var i:int; i < collection.length; i++){
				model = collection.getItemAt(i) as ItemPresent;
				if(model && model.id == id){
					collection.removeItemAt(i);
					return;
				}
			}
		}
	}
}