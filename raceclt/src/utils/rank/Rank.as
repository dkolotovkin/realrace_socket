package utils.rank
{
	public class Rank
	{
		public function Rank()
		{
		}
		
		public static function getValueByRank(params:int, rank:int):int{
			var param7:int = int(Math.floor(params / 1000000));
			var param6:int = int(Math.floor((params - param7 * 1000000) / 100000));
			var param5:int = int(Math.floor((params - (param7 * 1000000 + param6 * 100000)) / 10000));
			var param4:int = int(Math.floor((params - (param7 * 1000000 + param6 * 100000 + param5 * 10000)) / 1000));
			var param3:int = int(Math.floor((params - (param7 * 1000000 + param6 * 100000 + param5 * 10000 + param4 * 1000)) / 100));				
			var param2:int = int(Math.floor((params - (param7 * 1000000 + param6 * 100000 + param5 * 10000 + param4 * 1000 + param3 * 100)) / 10));
			var param1:int = int(Math.floor((params - (param7 * 1000000 + param6 * 100000 + param5 * 10000 + param4 * 1000 + param3 * 100 + param2 * 10)) / 1));				
			
			//если разряды считать справа налево
			//param1 - первый разряд params
			//param2 - второй разряд params
			//...
			//paramN - N-й разряд params 
			
			if(rank == 1){
				return param1;
			}else if(rank == 2){
				return param2;
			}else if(rank == 3){
				return param3;
			}else if(rank == 4){
				return param4;
			}else if(rank == 5){
				return param5;
			}else if(rank == 6){
				return param6;
			}else if(rank == 7){
				return param7;
			}else 
				return 0;
		}
	}
}