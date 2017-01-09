package utils.managers.gameparams
{
	import utils.user.Accessorytype;
	import utils.user.ColorType;

	public class GameParamsManager
	{
		public function GameParamsManager()
		{
		}
		
		//перо
		public static function isPen(atype:int):Boolean{
			if(atype == Accessorytype.PEN1 || atype == Accessorytype.PEN3 || atype == Accessorytype.PEN10) return true;
			return false;
		}
		//галстук
		public static function isTie(atype:int):Boolean{
			if(atype == Accessorytype.TIE1 || atype == Accessorytype.TIE3 || atype == Accessorytype.TIE10) return true;
			return false;
		}
		//повязка
		public static function isBandage(atype:int):Boolean{
			if(atype == Accessorytype.BANDAGE1 || atype == Accessorytype.BANDAGE3 || atype == Accessorytype.BANDAGE10) return true;
			return false;
		}
		//корона
		public static function isCrone(atype:int):Boolean{
			if(atype == Accessorytype.CRONE1 || atype == Accessorytype.CRONE3 || atype == Accessorytype.CRONE10) return true;
			return false;
		}
		//цилиндр
		public static function isCylinder(atype:int):Boolean{
			if(atype == Accessorytype.CYLINDER1 || atype == Accessorytype.CYLINDER3 || atype == Accessorytype.CYLINDER10) return true;
			return false;
		}
		//шапка повара
		public static function isCookHat(atype:int):Boolean{
			if(atype == Accessorytype.COOKHAT1 || atype == Accessorytype.COOKHAT3 || atype == Accessorytype.COOKHAT10) return true;
			return false;
		}
		//шапка ковбойская
		public static function isKovboyHat(atype:int):Boolean{
			if(atype == Accessorytype.KOVBOYHAT1 || atype == Accessorytype.KOVBOYHAT3 || atype == Accessorytype.KOVBOYHAT10) return true;
			return false;
		}
		//шарф
		public static function isScarf(atype:int):Boolean{
			if(atype == Accessorytype.SCARF1 || atype == Accessorytype.SCARF3 || atype == Accessorytype.SCARF10) return true;
			return false;
		}
		//стрижка-вспышка
		public static function isFlashHair(atype:int):Boolean{
			if(atype == Accessorytype.FLASHHAIR1 || atype == Accessorytype.FLASHHAIR3 || atype == Accessorytype.FLASHHAIR10) return true;
			return false;
		}
		//тыква	
		public static function isPumpkin(atype:int):Boolean{
			if(atype == Accessorytype.PUMPKIN1 || atype == Accessorytype.PUMPKIN3 || atype == Accessorytype.PUMPKIN10) return true;
			return false;
		}
		//новогодняя шапка
		public static function isNYHat(atype:int):Boolean{
			if(atype == Accessorytype.NYHAT1 || atype == Accessorytype.NYHAT3 || atype == Accessorytype.NYHAT10) return true;
			return false;
		}
		//костюм хип хоп
		public static function isHipHop(atype:int):Boolean{
			if(atype == Accessorytype.HIPHOP1 || atype == Accessorytype.HIPHOP3 || atype == Accessorytype.HIPHOP10) return true;
			return false;
		}
		//костюи гламур
		public static function isGlamur(atype:int):Boolean{
			if(atype == Accessorytype.GLAMUR1 || atype == Accessorytype.GLAMUR3 || atype == Accessorytype.GLAMUR10) return true;
			return false;
		}
		//костюи лямур
		public static function isLamur(atype:int):Boolean{
			if(atype == Accessorytype.LAMUR1 || atype == Accessorytype.LAMUR3 || atype == Accessorytype.LAMUR10) return true;
			return false;
		}
		//костюи мото
		public static function isMoto(atype:int):Boolean{
			if(atype == Accessorytype.MOTO1 || atype == Accessorytype.MOTO3 || atype == Accessorytype.MOTO10) return true;
			return false;
		}
		//новогодний костюм
		public static function isNY(atype:int):Boolean{
			if(atype == Accessorytype.NY1 || atype == Accessorytype.NY3 || atype == Accessorytype.NY10) return true;
			return false;
		}
		//доктор
		public static function isDoctor(atype:int):Boolean{
			if(atype == Accessorytype.DOCTOR1 || atype == Accessorytype.DOCTOR3 || atype == Accessorytype.DOCTOR10) return true;
			return false;
		}
		//пчела
		public static function isBee(atype:int):Boolean{
			if(atype == Accessorytype.BEE1 || atype == Accessorytype.BEE3 || atype == Accessorytype.BEE10) return true;
			return false;
		}
		//костюм снегурочки
		public static function isSnowGirl(atype:int):Boolean{
			if(atype == Accessorytype.SNOW_GIRL1 || atype == Accessorytype.SNOW_GIRL3 || atype == Accessorytype.SNOW_GIRL10) return true;
			return false;
		}
		//очки USB
		public static function isUSB(atype:int):Boolean{
			if(atype == Accessorytype.USB1 || atype == Accessorytype.USB3 || atype == Accessorytype.USB10) return true;
			return false;
		}
		//ангел
		public static function isAngel(atype:int):Boolean{
			if(atype == Accessorytype.ANGEL1 || atype == Accessorytype.ANGEL3 || atype == Accessorytype.ANGEL10) return true;
			return false;
		}
		//демон
		public static function isDemon(atype:int):Boolean{
			if(atype == Accessorytype.DEMON1 || atype == Accessorytype.DEMON3 || atype == Accessorytype.DEMON10) return true;
			return false;
		}
		//маска кошки
		public static function isCatMask(atype:int):Boolean{
			if(atype == Accessorytype.CATMASK1 || atype == Accessorytype.CATMASK3 || atype == Accessorytype.CATMASK10) return true;
			return false;
		}
		//каска
		public static function isHelmet(atype:int):Boolean{
			if(atype == Accessorytype.HELMET1 || atype == Accessorytype.HELMET3 || atype == Accessorytype.HELMET10) return true;
			return false;
		}
		//фуражка
		public static function isPoliceHat(atype:int):Boolean{
			if(atype == Accessorytype.POLICEHAT1 || atype == Accessorytype.POLICEHAT3 || atype == Accessorytype.POLICEHAT10) return true;
			return false;
		}
		//черная мышь
		public static function isBlack(ctype:int):Boolean{
			if(ctype == ColorType.BLACK1 || ctype == ColorType.BLACK3 || ctype == ColorType.BLACK10) return true;
			return false;
		}
		//белая мышь
		public static function isWhite(ctype:int):Boolean{
			if(ctype == ColorType.WHITE1 || ctype == ColorType.WHITE3 || ctype == ColorType.WHITE10) return true;
			return false;
		}
		//голубая мышь
		public static function isBlue(ctype:int):Boolean{
			if(ctype == ColorType.BLUE1 || ctype == ColorType.BLUE3 || ctype == ColorType.BLUE10) return true;
			return false;
		}
		//розовая мышь
		public static function isFiolet(ctype:int):Boolean{
			if(ctype == ColorType.FIOLET1 || ctype == ColorType.FIOLET3 || ctype == ColorType.FIOLET10) return true;
			return false;
		}
		//рыжая мышь
		public static function isOrange(ctype:int):Boolean{
			if(ctype == ColorType.ORANGE1 || ctype == ColorType.ORANGE3 || ctype == ColorType.ORANGE10) return true;
			return false;
		}		
		//король
		public static function isKingCrone(atype:int):Boolean{
			if(atype == Accessorytype.KING_CRONE) return true;
			return false;
		}
		
		public static function getKSpeed(atype:int, ctype:int):Number{
			var needAccessory:Boolean;
			var needColor:Boolean;
			var k:Number = 1;
			if(	isPumpkin(atype) ||
				isNYHat(atype) ||
				isDoctor(atype) ||
				isBee(atype) ||
				isUSB(atype) ||
				isAngel(atype) ||
				isDemon(atype) ||
				isCatMask(atype) ||
				isMoto(atype) ||
				isKingCrone(atype) ||
				isNY(atype) ||
				isSnowGirl(atype)
			){
				needAccessory = true;
			}			
			if(	isBlack(ctype) ||
				isWhite(ctype) ||
				isBlue(ctype) ||
				isFiolet(ctype) ||
				isOrange(ctype)
				){
				needColor = true;
			}
			
			if(needAccessory || needColor){
				k = 1.8;
			}
			if(needAccessory && needColor){
				k = 2.3;
			}
			
			return k;
		}
		
		public static function getKJump(atype:int, ctype:int):Number{
			var needAccessory:Boolean;
			var needColor:Boolean;
			var k:Number = 1;
			
			if(	isCylinder(atype) ||
				isCookHat(atype) ||
				isKovboyHat(atype) ||
				isScarf(atype) ||
				isHipHop(atype) ||
				isGlamur(atype) ||
				isLamur(atype) ||
				isHelmet(atype) ||
				isPoliceHat(atype) ||
				isFlashHair(atype) ||
				isPumpkin(atype) ||
				isNYHat(atype) || 
				isDoctor(atype) ||
				isBee(atype) ||
				isUSB(atype) ||
				isAngel(atype) || 
				isDemon(atype) || 
				isCatMask(atype) ||
				isMoto(atype) ||
				isKingCrone(atype) ||
				isNY(atype) ||
				isSnowGirl(atype)
			){
				needAccessory = true;
			}
			if(	isBlack(ctype) ||
				isWhite(ctype)
			){
				needColor = true;
			}
			
			if(needAccessory || needColor){
				k = 1.2;
			}
			if(needAccessory && needColor){
				k = 1.3;
			}
			return k;
		}
		
		public static function getBooking(atype:int, ctype:int):Boolean{
			
			if(	isDoctor(atype) || 
				isBee(atype) ||
				isNY(atype) ||
				isSnowGirl(atype) ||
				isUSB(atype) ||
				isMoto(atype) ||
				isAngel(atype) ||
				isCatMask(atype) ||
				isKingCrone(atype) ||
				isDemon(atype) 				
			){
				return true;
			}
			if(	isBlack(ctype) ||
				isWhite(ctype)
			){
				return true;
			}
			
			return false;
		}
		
		public static function getEnergyUp(atype:int, ctype:int):Boolean{
			if(
				isPen(atype) ||
				isTie(atype) ||
				isBandage(atype) ||
				isCrone(atype) ||
				isCylinder(atype) ||
				isCookHat(atype) ||
				isKovboyHat(atype) ||
				isScarf(atype) ||
				isHipHop(atype) ||
				isGlamur(atype) ||
				isLamur(atype) ||
				isHelmet(atype) ||
				isPoliceHat(atype) ||
				isFlashHair(atype) ||
				isPumpkin(atype) ||
				isNYHat(atype) ||
				isNY(atype) ||
				isSnowGirl(atype) ||
				isMoto(atype) ||
				isUSB(atype) ||
				isDoctor(atype) ||
				isBee(atype) ||
				isAngel(atype) ||
				isDemon(atype) ||
				isCatMask(atype) ||
				isBlack(ctype) ||
				isWhite(ctype) ||
				isBlue(ctype) ||
				isFiolet(ctype) ||
				isOrange(ctype)
			){
				return true;
			}
			return false;
		}
		
		public static function getExperienceBonus(atype:int, ctype:int):Boolean{
			if(
				isPen(atype) ||
				isTie(atype) ||
				isBandage(atype) ||
				isCrone(atype) ||
				isCylinder(atype) ||
				isCookHat(atype) ||
				isScarf(atype) ||
				isKovboyHat(atype) ||
				isHipHop(atype) ||
				isGlamur(atype) ||
				isLamur(atype) ||
				isHelmet(atype) ||
				isPoliceHat(atype) ||
				isFlashHair(atype) ||
//				isPumpkin(atype) ||
//				isNYHat(atype) ||
				isNY(atype) ||
				isSnowGirl(atype) ||
				isUSB(atype) ||
				isMoto(atype) ||
				isDoctor(atype) ||
				isBee(atype) ||
				isAngel(atype) ||
				isDemon(atype) ||
				isCatMask(atype) ||
				isBlack(ctype) ||
				isWhite(ctype) ||
				isBlue(ctype) ||
				isFiolet(ctype) ||
				isOrange(ctype)
			){
				return true;
			}
			return false;
		}
		
		public static function getExperienceClanBonus(atype:int, ctype:int):Boolean{
			if(
//				isPen(atype) ||
//				isBandage(atype) ||
//				isCrone(atype) ||
				isCylinder(atype) ||
				isCookHat(atype) ||
				isScarf(atype) ||
				isKovboyHat(atype) ||
				isHipHop(atype) ||
				isGlamur(atype) ||
				isLamur(atype) ||
				isHelmet(atype) ||
				isPoliceHat(atype) ||
				isFlashHair(atype) ||
				isPumpkin(atype) ||
				isNYHat(atype) ||
				isUSB(atype) ||
				isNY(atype) ||
				isSnowGirl(atype) ||
				isMoto(atype) ||
				isDoctor(atype) ||
				isBee(atype) ||
				isAngel(atype) ||
				isDemon(atype) ||
				isCatMask(atype) ||
//				isBlack(ctype) ||
//				isWhite(ctype) ||
				isBlue(ctype) ||
				isFiolet(ctype) ||
				isOrange(ctype)
			){
				return true;
			}
			return false;
		}
		
		public static function getMoneyBonus(atype:int, ctype:int):Boolean{
			if(
//				isPen(atype) ||
//				isBandage(atype) ||
//				isCrone(atype) ||
//				isCylinder(atype) ||
//				isCookHat(atype) ||
//				isKovboyHat(atype) ||
//				isFlashHair(atype) ||
				isPumpkin(atype) ||
				isNYHat(atype) ||
				isNY(atype) ||
				isSnowGirl(atype) ||
				isMoto(atype) ||
				isDoctor(atype) ||
				isBee(atype) ||
				isUSB(atype) ||
				isAngel(atype) ||
				isDemon(atype) ||
				isCatMask(atype) ||
				isBlack(ctype) ||
				isWhite(ctype)
//				isBlue(ctype) ||
//				isFiolet(ctype) ||
//				isOrange(ctype)
			){
				return true;
			}
			return false;
		}
	}
}