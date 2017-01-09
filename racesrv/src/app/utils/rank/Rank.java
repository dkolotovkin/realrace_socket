package app.utils.rank;

public class Rank {
	public static int getValueByRank(int params, int rank){
		int param7 = (int) Math.floor((double) (params / 1000000));
		int param6 = (int) Math.floor((double) (params - param7 * 1000000) / 100000);
		int param5 = (int) Math.floor((double) (params - (param7 * 1000000 + param6 * 100000)) / 10000);
		int param4 = (int) Math.floor((double) (params - (param7 * 1000000 + param6 * 100000 + param5 * 10000)) / 1000);
		int param3 = (int) Math.floor((double) (params - (param7 * 1000000 + param6 * 100000 + param5 * 10000 + param4 * 1000)) / 100);				
		int param2 = (int) Math.floor((double) (params - (param7 * 1000000 + param6 * 100000 + param5 * 10000 + param4 * 1000 + param3 * 100)) / 10);
		int param1 = (int) Math.floor((double) (params - (param7 * 1000000 + param6 * 100000 + param5 * 10000 + param4 * 1000 + param3 * 100 + param2 * 10)) / 1);				
		
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
