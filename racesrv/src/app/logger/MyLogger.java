package app.logger;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

public class MyLogger {
	public BufferedWriter writer;	
	public String className;
	File f;
	
	public MyLogger(String filePath, String className){
		this.className = className;
		
		f = new File(filePath);
		if (!f.exists()){
			try {
				f.createNewFile();
			} catch (Exception e) {
			}
		}
	}
	
	public void log(String msg){		
		try{
			Date d = new Date();
			Locale local = new Locale("ru","RU");
			DateFormat df = new SimpleDateFormat("HH:mm:ss yyyy/MM/dd", local);
			df.setTimeZone(TimeZone.getTimeZone("EAT"));			
			String date = df.format(d);
			String classn = "[" + className + "]";
			
			writer = new BufferedWriter(new FileWriter(f.getPath(), true));
			if (f.length() > 0){
				writer.newLine();
			}else{
				writer.write("start log...");
				writer.newLine();
			}
			writer.write(date + "  " + classn + " [log] " + msg);			
			writer.close();
			
			System.out.println(date + "  " + classn + "  " + msg);
	    }
	    catch (IOException e){	    	
	    }
	}
	
	public void error(String msg){
		try{
			Date d = new Date();
			Locale local = new Locale("ru","RU");
			DateFormat df = new SimpleDateFormat("HH:mm:ss yyyy/MM/dd", local);
			df.setTimeZone(TimeZone.getTimeZone("EAT"));			
			String date = df.format(d);
			String classn = "[" + className + "]";
			
			writer = new BufferedWriter(new FileWriter(f.getPath(), true));
			if (f.length() > 0){
				writer.newLine();
			}else{
				writer.write("start log...");
				writer.newLine();
			}
			writer.write(date + "  " + classn + " [err] " + msg);			
			writer.close();
			
			System.out.println(date + "  " + classn + "  " + msg);
	    }
	    catch (IOException e){	    	
	    }
	}
}
