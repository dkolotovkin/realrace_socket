package application.components.popup.extraction
{
	import application.components.popup.PopUpTitled;
	
	import utils.protocol.ProtocolKeys;
	
	public class PopUpExtraction extends PopUpTitled
	{
		private var _extractionInfo:ExtractionInfo;
		
		public function PopUpExtraction(extraction:Object, position:int)
		{
			super();
			var experience:int = 0;
			var cexperience:int = 0;
			var money:int = 0;
			var experienceBonus:int = 0;
			var cexperienceBonus:int = 0;
			var moneyBonus:int = 0;
			
			_extractionInfo = new ExtractionInfo();
			if (extraction){
				experience = extraction[ProtocolKeys.EXPERIENCE];
				cexperience = extraction[ProtocolKeys.CEXPERIENCE];
				money = extraction[ProtocolKeys.MONEY];
				experienceBonus = extraction[ProtocolKeys.EXPERIENCE_BONUS];
				cexperienceBonus = extraction[ProtocolKeys.CEXPERIENCE_BONUS];
				moneyBonus = extraction[ProtocolKeys.MONEY_BONUS];
			}			
			
			title = "Окончание заезда";
			if (experience > 0 || money > 0){
				_extractionInfo.description = "Заезд окончен и Вы заняли " + position + " место!";
			}else if (experience == 0){
				_extractionInfo.description = "Заезд окончен! К сожалению Вы не заняли призовое место и не получили награды. Попробуйте еще.";
			}else{
				_extractionInfo.description = "Заезд окончен! К сожалению Вы не доехали до финиша.";
			}
			_extractionInfo.experience = experience;
			_extractionInfo.cexperience = cexperience;
			_extractionInfo.money = money;
			_extractionInfo.experienceBonus = experienceBonus;
			_extractionInfo.cexperienceBonus = cexperienceBonus;
			_extractionInfo.moneyBonus = moneyBonus;
		}
		
		override protected function createChildren():void{
			super.createChildren();
			addElement(_extractionInfo);
		}
	}
}