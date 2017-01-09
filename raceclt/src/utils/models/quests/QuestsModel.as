package utils.models.quests
{
	import mx.collections.ArrayCollection;

	public class QuestsModel
	{
		[Bindable]
		public var groups:ArrayCollection;
		[Bindable]
		public var quests:ArrayCollection;
		[Bindable]
		public var currentQuest:Quest;
		[Bindable]
		public var cooldownTime:int;
		
		public function QuestsModel()
		{
			reset();
		}
		
		public function reset():void{
			groups = new ArrayCollection();
			quests = new ArrayCollection();
		}
		
		public function getQuestById(qid:int):Quest{
			var q:Quest;
			for(var i:int = 0; i < quests.length; i++){
				q = quests.getItemAt(i) as Quest;
				if(q.id == qid){
					return q;
				}
			}
			return null;
		}
	}
}