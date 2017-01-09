package utils.managers.quests
{
	import application.GameApplication;
	import application.GameMode;
	import application.components.popup.buy.PopUpBuy;
	
	import utils.models.ItemPrototype;
	import utils.models.quests.Quest;
	import utils.models.quests.QuestGroup;
	import utils.models.quests.QuestStatus;
	import utils.protocol.ProtocolKeys;
	import utils.protocol.ProtocolValues;

	public class QuestsManager
	{
		public function QuestsManager(){
			GameApplication.app.models.questsModel.reset();
			
			addGroup(1, "Характеристики персонажа");
			addGroup(2, "Забеги");
			addGroup(3, "Покупки / популярность");
			addGroup(4, "Помощник");
			addGroup(5, "Клуб");
			addGroup(6, "Мини-игры");
			addGroup(7, "Социальные задания");
			
			addQuest(101, 1, 5, "Получить 5 уровень", 1, 95);
			addQuest(102, 1, 10, "Получить 10 уровень", 1, 78);
			addQuest(103, 1, 15, "Получить 15 уровень", 1, 137);
			addQuest(104, 1, 20, "Получить 20 уровень", 1, 101);
			addQuest(105, 1, 5, "Получить новый уровень популярности: «узнаваемый»", 1, 151);
			addQuest(106, 1, 10, "Получить новый уровень популярности: «популярный»", 1, 72);
			addQuest(107, 1, 15, "Получить новый уровень популярности: «король мышей»", 1, 100);
			
			addQuest(201, 2, 1, "30 раз принести сыр в норку", 30, 62);
			addQuest(202, 2, 3, "50 раз принести сыр в норку", 50, 70);
			addQuest(203, 2, 5, "30 раз занять призовое место", 30, 66);
			addQuest(204, 2, 7, "100 раз занять 1 место", 100, 44);
			addQuest(205, 2, 10, "3 раза попасть в пятерку лучших за час", 3, 89);
			addQuest(206, 2, 12, "Попасть в пятерку лучших за день", 1, 93);
			addQuest(207, 2, 7, "Выиграть джек пот", 1, 27);
			addQuest(208, 2, 10, "Выиграть 10 платных забегов", 10, 96);
			
			addQuest(301, 3, 3, "Сделать 10 любых подарков", 10, 63);
			addQuest(302, 3, 5, "Подарить 5 подарков «сердце»", 5, 80);
			addQuest(303, 3, 7, "Подарить 1 подарок «машина»", 1, 126);
			addQuest(304, 3, 1, "Купить любой костюм (аксессуар)", 1, 62);
			addQuest(305, 3, 3, "Купить цветную мышь", 1, 131);
			addQuest(306, 3, 5, "Купить черную или белую мышь", 1, 136);
			addQuest(307, 3, 12, "Баллотироваться на выборах королей", 1, 19);
			addQuest(308, 3, 5, "Сменить имя", 1, 151);
			addQuest(309, 3, 10, "Создать 3 карты и отправить их на проверку", 3, 136);
			addQuest(310, 3, 7, "Приобрести любой VIP-аккаунт", 1, 23);
			addQuest(311, 3, 5, "Пополнить счет", 1, 134);
			
			addQuest(401, 4, 3, "Завести помощника", 1, 131);
			addQuest(402, 4, 3, "Собрать 10 артефактов «золотая звезда»", 10, 144);
			addQuest(403, 4, 5, "Собрать 10 артефактов «золотая нота»", 10, 132);
			addQuest(404, 4, 7, "Собрать 10 артефактов «золотое сердце»", 10, 134);
			addQuest(405, 4, 10, "Собрать 10 артефактов «золотой слиток»", 10, 71);
			addQuest(406, 4, 15, "Собрать 10 артефактов «золотое кольцо 2 уровня»", 10, 72);
			
			addQuest(501, 5, 5, "Создать/вступить в клуб", 1, 46);
			addQuest(502, 5, 10, "Набрать 500 евро и 1000 опыта для клуба", 1, 50);
			addQuest(503, 5, 5, "Получить 3 звезды в клубе", 1, 95);
			addQuest(504, 5, 7, "Получить 5 звезд в клубе", 1, 66);
			
			addQuest(601, 6, 5, "Дать 5 правильных ответов на викторину", 5, 95);
			addQuest(602, 6, 10, "2 раза выиграть на автомате по 4-5 линиям", 2, 132);
			addQuest(603, 6, 7, "3 раза выиграть аукцион", 3, 62);
			addQuest(604, 6, 12, "Выиграть в колесе фортуны на 10 или 11 секторе", 1, 129);
			
			addQuest(701, 7, 1, "Сделать 3 различных снимка экрана в забегах (кнопка на верхней панеле)", 3, 16);		
			addQuest(702, 7, 3, "Привести в игру 10 друзей (в рассчет берутся только вступившие в игру друзья)", 10, 14);
			
			if(GameApplication.app.config.mode != GameMode.DEBUG){
				if(GameApplication.app.config.mode == GameMode.OD){
					removeGroup(6);
					removeQuest(601);
					removeQuest(602);
					removeQuest(603);
					removeQuest(604);
				}
				if(GameApplication.app.config.mode != GameMode.VK && GameApplication.app.config.mode != GameMode.MM && GameApplication.app.config.mode != GameMode.OD){
					removeGroup(7);
					removeQuest(701);
					removeQuest(702);
				}
				if(GameApplication.app.config.mode == GameMode.VK){
					removeQuest(702);
				}
			}
		}
		
		private function addGroup(groupId:int, groupTitle:String):void{
			var group:QuestGroup = new QuestGroup();
			group.id = groupId;
			group.title = groupTitle;
			GameApplication.app.models.questsModel.groups.addItem(group);
		}
		
		private function addQuest(questId:int, groupId:int, minLevel:int, questDescription:String, value:int, prize:int):void{
			var quest:Quest = new Quest();
			quest.id = questId;
			quest.groupId = groupId;
			quest.minLevel = minLevel;
			quest.description = questDescription;
			quest.value = value;
			quest.prize = prize;
			quest.status = QuestStatus.UNDEFINED;
			GameApplication.app.models.questsModel.quests.addItem(quest);
		}
		
		private function removeGroup(groupId:int):void{
			var group:QuestGroup;
			for(var i:int = 0; i < GameApplication.app.models.questsModel.groups.length; i++){
				group = GameApplication.app.models.questsModel.groups.getItemAt(i) as QuestGroup;
				if(group && group.id == groupId){
					GameApplication.app.models.questsModel.groups.removeItemAt(i);
					break;
				}
			}
		}
		
		private function removeQuest(questId:int):void{
			var quest:Quest;
			for(var i:int = 0; i < GameApplication.app.models.questsModel.quests.length; i++){
				quest = GameApplication.app.models.questsModel.quests.getItemAt(i) as Quest;
				if(quest && quest.id == questId){
					GameApplication.app.models.questsModel.quests.removeItemAt(i);
					break;
				}
			}
		}
		
		public function cancelQuest():void{
			GameApplication.app.callsmanager.call(ProtocolValues.QUEST_CANCEL, onQuestCancel);
		}
		
		private function onQuestCancel(obj:Object):void{
			if(obj[ProtocolKeys.VALUE]){
				var quest:Quest;
				for(var i:int = 0; i < GameApplication.app.models.questsModel.quests.length; i++){
					quest = GameApplication.app.models.questsModel.quests.getItemAt(i) as Quest;
					if(quest && quest.status == QuestStatus.PERFORMED){
						quest.status = QuestStatus.IN_WAIT;
						quest.currentValue = 0;
					}
				}
				GameApplication.app.models.questsModel.currentQuest = null;
			}else{
				GameApplication.app.popuper.showInfoPopUp("Произошла ошибка при обращении к серверу...");
			}
		}
		
		public function passQuest():void{
			GameApplication.app.callsmanager.call(ProtocolValues.QUEST_PASS, onPassQuest);
		}
		
		private function onPassQuest(obj:Object):void{
			if(obj[ProtocolKeys.VALUE]){
				var quest:Quest;
				for(var i:int = 0; i < GameApplication.app.models.questsModel.quests.length; i++){
					quest = GameApplication.app.models.questsModel.quests.getItemAt(i) as Quest;
					if(quest && quest.status == QuestStatus.PERFORMED){
						quest.status = QuestStatus.COMLETED;
						quest.currentValue = quest.value;
					}
				}
				if(GameApplication.app.models.questsModel.currentQuest){
					var itemprototype:ItemPrototype = GameApplication.app.models.itemPrototypes.getModelById(GameApplication.app.models.questsModel.currentQuest.prize);
					if(itemprototype){
						GameApplication.app.popuper.show(new PopUpBuy(itemprototype, "Поздравляем, задание выполнено!"));					
					}
					GameApplication.app.models.questsModel.currentQuest = null;
				}
			}else{
				GameApplication.app.popuper.showInfoPopUp("Произошла ошибка при обращении к серверу...");
			}
		}
		
		public function getQuest(quest:Quest):void{
			GameApplication.app.callsmanager.call(ProtocolValues.QUEST_GET, onGetQuest, quest.id);
		}
		
		private function onGetQuest(obj:Object):void{
			if(obj[ProtocolKeys.VALUE] > 0){
				var quest:Quest;
				for(var i:int = 0; i < GameApplication.app.models.questsModel.quests.length; i++){
					quest = GameApplication.app.models.questsModel.quests.getItemAt(i) as Quest;
					if(quest && quest.id == obj[ProtocolKeys.VALUE]){
						quest.status = QuestStatus.PERFORMED;
						GameApplication.app.models.questsModel.currentQuest = quest;
						break;
					}
				}
				
				getCurrentQuestValue(null);
			}else{
				GameApplication.app.popuper.showInfoPopUp("Нельзя начать задание. Возможно еще не прошло врямя ожидания до начала следующего задания.");
			}
		}
		
		private var callBackGetCurrentQuestValue:Function;
		public function getCurrentQuestValue(value:Function):void{
			callBackGetCurrentQuestValue = value;
			GameApplication.app.callsmanager.call(ProtocolValues.QUEST_GET_CURRENT_VALUE, onGetCurrentQuestValue);
		}
		
		private function onGetCurrentQuestValue(obj:Object):void{
			if(GameApplication.app.models.questsModel.currentQuest){
				GameApplication.app.models.questsModel.currentQuest.currentValue = int(obj[ProtocolKeys.VALUE]);
			}
			GameApplication.app.models.questsModel.cooldownTime = int(obj[ProtocolKeys.TIME]);
			
			callBackGetCurrentQuestValue && callBackGetCurrentQuestValue();
			callBackGetCurrentQuestValue = null;
		}
	}
}