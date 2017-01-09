package app.utils.jsonutil;

import atg.taglib.json.util.JSONObject;

public class JSONUtil {
	public static String getValueByName(String str, String field){
		if(str != null && str.length() > 2){
			String content = str.substring(1, str.length() - 2);			
			String[] arr3 = content.split(",");
			for(int i = 0; i < arr3.length; i++){				
				String[] arr4 = arr3[i].split(":");
				if(arr4 != null && arr4[0].indexOf(field) != -1){
					return new String(arr4[1]);
				}						
			}
		}
		return null;
	}
	
	public static String getString(JSONObject jsonObj, String key){
		try{
			return jsonObj.getString(key);
		}catch(Exception e){
        }
		return null;
	}
	
	public static boolean getBoolean(JSONObject jsonObj, String key){
		try{
			return jsonObj.getBoolean(key);
		}catch(Exception e){			
        }
		return false;
	}
	
	public static int getInt(JSONObject jsonObj, String key){		
		try{
			return jsonObj.getInt(key);
		}catch(Exception e){
        }
		return 0;
	}
	
	public static double getDouble(JSONObject jsonObj, String key){
		try{
			return jsonObj.getDouble(key);
		}catch(Exception e){
        }
		return 0;
	}
	
	public static boolean isJSON(String jsonStr){
		int countOpen = 0;
		int countClose = 0;
		int currentIndex = jsonStr.indexOf("{", 0);
		while(currentIndex >= 0){
			currentIndex = jsonStr.indexOf("{", currentIndex + 1);
			countOpen++;
		}
		currentIndex = jsonStr.indexOf("}", 0);
		while(currentIndex >= 0){
			currentIndex = jsonStr.indexOf("}", currentIndex + 1);
			countClose++;
		}
		return (countOpen == countClose);
	}
}
