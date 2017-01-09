package app;

import java.util.Arrays;
import java.util.List;

public class Config {
	
	public static byte TEST = 0;
	public static byte RELEASE = 1;
	
	public static int mode(){return RELEASE;}
	public static int currentVersion(){return 13;}									//ВЕРСИЯ КЛИЕНТА
	
	public static List<Integer> exphourprizes = Arrays.asList(20, 10, 5, 3, 2);		//НАГРАДА ЛУЧШИМ ЗА ЧАС
	public static List<Integer> expdayprizes = Arrays.asList(200, 100, 50, 30, 20);	//НАГРАДА ЛУЧШИМ ЗА ДЕНЬ
	
	public static int maxMessageCountInRoom(){return 10;} 						//КОЛИЧЕСТВО СООБЩЕНИЙ, КОТОРЫЕ ХРАНИМ В КОМНАТЕ	 
	public static int valueExperienceUpdateInBan(){return 2;}					//ЗНАЧЕНИЕ НА КОТОРОЕ ИЗМЕНЯЕТСЯ ОПЫТ В БАНЕ ЗА МИНУТУ	
	public static int valuePopularUpdateInBan(){return 2;}						//ЗНАЧЕНИЕ НА КОТОРОЕ ИЗМЕНЯЕТСЯ ПОПУЛЯРНОСТЬ В БАНЕ ЗА МИНУТУ	 
	public static int banminutePrice(){return 20;}								//ЦЕНА ЗА МИНУТУ БАНА
	public static int exchangeMoneyK(){return 10;}								//КОЭФФИЦИЕНТ ОБМЕНА ДЕНЕГ	
	public static int changeInfoPrice(){return 2000;}							//ЦЕНА ЗА СМЕНУ ИНФОРМАЦИИ О ПЕРСОНАЖЕ
	public static int sendMailPrice(){return 20;}								//ЦЕНА ЗА ОТПРАВКУ ПОЧТЫ	
	public static int createClanPrice(){return 10000;}							//ЦЕНА ЗА ПОКУПКУ КЛУБА В РЕАЛАХ	
	public static int createClanNeedLevel(){return 7;}							//НЕОБХОДИМЫЙ УРОВЕНЬ ДЛЯ СОЗДАНИЯ КЛАНА	
	public static int showLinkPrice(){return 50;}								//ЦЕНА ЗА ПРОСМОТР ССЫЛКИ	
	public static int experiencePrize(){return 10;}								//НАГРАДА ОПЫТА ЗА ПОБЕДУ В ЗАБЕГЕ
	public static int friendBonus(){return 30;}									//БОНУС ЗА ПРИВЕДЕННОГО ДРУГА	
	public static int moneyPrize(){return 20;}									//НАГРАДА ДЕНЕГ ЗА ПОБЕДУ В ЗАБЕГЕ	
	public static int moneyBonus(){return 1;}									//БОНУС ДЕНЕГ ЗА ПОБЕДУ В ЗАБЕГЕ	
	public static int percentMoneyUsers(){return 50;}							//СКОЛЬКО ПРОЦЕНТОВ ПОЛЬЗОВАТЕЛЕЙ ПОЛУЧАТ ДЕНЕЖНЫЙ ПРИЗ	
	public static int experiencePrizeDelta(){return 2;}							//РАЗНИЦА МЕЖДУ НАГРАДАМИ(ОПЫТА) ПРИЗЕРОВ ЗАБЕГА
	public static int levelFromChatEnabled(){return 2;}							//УРОВЕНЬ, С КОТОРОГО ДОСТУПЕН ОБЩИЙ ЧАТ	
	public static int rentCarDuration(){return 60 * 60 * 24;}					//ДЛИТЕЛЬНОТЬ АРЕНДЫ АВТО
		
	public static int waitTimeToStart(){if(Config.mode() == Config.TEST){return 3;}else{return 15;}}		//ВРЕМЯ ОЖИДАНИЯ ИГРЫ
	public static int waitTimeToStartBet(){if(Config.mode() == Config.TEST){return 10;}else{return 30;}}	//ВРЕМЯ ОЖИДАНИЯ ИГРЫ НА ДЕНЬГИ	
	
	public static int minUsersInGame(){if(Config.mode() == Config.TEST){return 1;}else{return 2;}}			//МИНИМАЛЬНОЕ КОЛИЧЕСТВО ПОЛЬЗОВАТЕЛЕЙ В ИГРЕ
	public static int minUsersInGameByLevel(){return 5;}													//КОЛИЧЕСТВО ПОЛЬЗОВАТЕЛЕЙ НЕОБХОДИМОЕ ДЛЯ НАЧАЛА ИГРЫ БЕЗ ОБЪЕДИНЕНИЯ ПО УРОВНЯМ	
	public static int maxUsersInGame(){return 8;}															//МАКСИМАЛЬНОЕ КОЛИЧЕСТВО ПОЛЬЗОВАТЕЛЕЙ В ИГРЕ
	
	public static String protectedSecretSiteVK(){return "xxxxxxxxxxxxxxxxxxxxxx";}				//protected secret VK (for site)
	public static String protectedSecretVK(){return "01fkzwlIYlBCt9MIBcX3";}					//protected secret VK
	public static String protectedSecretSiteMM(){return "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";}	//protected secret MM (for site)
	public static String protectedSecretMM(){return "2d80c9dbcfbe047b80b4a8493f758ec2";}		//protected secret MM
	public static String protectedSecretSiteOD(){return "xxxxxxxxxxxxxxxxxxxxxxxx";}			//protected secret OD (for site)
	public static String applicationKeySiteOD(){return "xxxxxxxxxxxxxxxxx";}					//application key OD  (for site)
	public static String protectedSecretOD(){return "7732A683A03C7F9E7F048C15";}				//protected secret OD
	public static String publicSecretOD(){return "CBAKHIELABABABABA";}							//public secret OD

	public static int appIdVK(){return 3544908;}												//ХАРДКОД ДЛЯ АВТОРИЗАЦИИ И УВЕДОМЛЕНИЙ	
	public static int appIdMM(){return 703045;}													//ХАРДКОД ДЛЯ АВТОРИЗАЦИИ И УВЕДОМЛЕНИЙ	
	public static int appIdOD(){return 172456192;}												//ХАРДКОД ДЛЯ АВТОРИЗАЦИИ И УВЕДОМЛЕНИЙ	
	
	public static String apiUrlMM(){return "http://www.appsmail.ru/platform/api";}				//ХАРДКОД ДЛЯ УВЕДОМЛЕНИЙ
	public static String apiUrlVK(){return "http://api.vkontakte.ru/api.php";}					//ХАРДКОД ДЛЯ УВЕДОМЛЕНИЙ
	public static String apiUrlOD(){return "http://api.odnoklassniki.ru/";}						//ХАРДКОД ДЛЯ УВЕДОМЛЕНИЙ	
	
	public static String loginUrlVK(){return "https://api.vkontakte.ru/oauth/access_token";}	//ХАРДКОД ДЛЯ САЙТА
	public static String loginUrlMM(){return "https://connect.mail.ru/oauth/token";}			//ХАРДКОД ДЛЯ САЙТА
	public static String loginUrlOD(){return "http://api.odnoklassniki.ru/oauth/token.do";}		//ХАРДКОД ДЛЯ САЙТА
	
	public static String oficalSiteUrl(){return "http://rerace.ru";}							//ХАРДКОД ДЛЯ САЙТА
	public static String characterEncoding(){return "UTF-8";}									//КОДИРОВКА
	public static String policyHead(){return "<policy-file-request/>";}
	public static String lineSeparator(){return "\u2028";}
	public static int serverPort(){return 8091;}
	public static String serverHost(){
		if(Config.mode() == Config.TEST){
			return "localhost";
		}
		return "37.200.71.154";
	}	
	public static String policyContent(){return "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>\0";}
	
	public static String rootPath(){															//ПУТЬ ДО ROOT ИГРЫ
		if(Config.mode() == Config.TEST){
			return "c:/usr/game/";
		}
		return "/usr/game/";
	}
	
	public static String logPath(){
		return Config.rootPath() + "log/race_log.txt";
	}
	
	public static String optionLogPath(){
		return Config.rootPath() + "log/race_optionLog.txt";
	}
}
