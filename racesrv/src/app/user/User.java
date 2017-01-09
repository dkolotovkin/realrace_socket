package app.user;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import app.Config;
import app.ServerApplication;
import app.clan.ClanUserInfo;
import app.logger.MyLogger;
import app.quests.UserQuest;
import app.shop.car.CarModel;
import app.utils.changeinfo.ChangeInfoParams;

public class User {
	public int id;
	public String idSocial;
	public String ip;
	public int sex;
	public String title;
	public int role;
	public int level;
	public int lastlvl;
		
	public int popular;
	public int experience;
	public int exphour;
	public int expday;
	public int nextLevelExperience;
	public int money;
	public int moneyreal;
	public byte bantype;
	public int setbanat;
	public int changebanat;
	public String url;
	public int inviter;
	public int loginMode;
	
	public Map<Integer, CarModel> cars;
	public CarModel activeCar;
	
	public byte countSocialFriends;
	
	public ClanUserInfo claninfo;
	
	public Map<Integer, Integer> enemies;
	
	public int getQuestTime;
	public Map<Integer, UserQuest> quests;
	public UserQuest currentQuest;
	
	public boolean incommonroom;
	
	public int vip;
	public int setvipat;
	
	public Date upddate;
	public Date gbdate;
	public Date sbdate;
	
	public String previosWinGameActions;
	public int gameStatus;
	
	public MyLogger logger = new MyLogger(Config.logPath(), User.class.getName());
	
	public User(int id, String idSocial, String ip, int sex, String title, int popular, int experience, int exphour, int expday, int lastlvl, int money, int moneyreal, int role, byte bantype, int setbanat, int changebanat, String url, ClanUserInfo claninfo, int inviter, int vip, int setvipat){
		this.id = id;
		this.idSocial = idSocial;
		this.ip = ip;
		this.sex = sex;
		this.title = title;
		this.money = money;
		this.moneyreal = moneyreal;
		this.role = role;
		this.popular = popular;
		this.experience = experience;
		this.exphour = exphour;
		this.expday = expday;
		this.lastlvl = lastlvl;
		this.bantype = bantype;
		this.setbanat = setbanat;
		this.changebanat = changebanat;
		
		this.vip = vip;
		this.setvipat = setvipat;
		
		this.url = url;
		this.claninfo = claninfo;
		this.inviter = inviter;	
		
		this.level = ServerApplication.application.userinfomanager.getLevelByExperience(experience);
		this.nextLevelExperience = ServerApplication.application.userinfomanager.levels.get(this.level + 1);
		
		cars = new ConcurrentHashMap<Integer, CarModel>();
		enemies = new ConcurrentHashMap<Integer, Integer>();
		quests = new ConcurrentHashMap<Integer, UserQuest>();
		
		previosWinGameActions = "";
	}
	
	public void setParamsByExperience(int value){
		int level = ServerApplication.application.userinfomanager.getLevelByExperience(value);
		if(this.level != level){
			ServerApplication.application.commonroom.changeUserInfoByID(this.id, ChangeInfoParams.USER_EXPERIENCE_MAXEXPERIENCE_LEVEL, this.experience, ServerApplication.application.userinfomanager.levels.get(level + 1), level);
		}
		this.level = level;
		this.nextLevelExperience = ServerApplication.application.userinfomanager.levels.get(level + 1);		
	}

	public void updateVip(int vip){
		Connection _sqlconnection = null;
		PreparedStatement update = null;
		
		try {		
			Date date = new Date();
			int currenttime = (int)(date.getTime() / 1000);
			date = null;
			
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			update = _sqlconnection.prepareStatement("UPDATE user SET vip=?,setvipat=? WHERE id=?");
			update.setInt(1, vip);
			update.setInt(2, currenttime);
			update.setInt(3, id);
			if (update.executeUpdate() > 0){	
				this.vip = vip;
				this.setvipat = currenttime;
			}
		} catch (SQLException e) {
			logger.error(e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (update != null) update.close();
		    	_sqlconnection = null;
		    	update = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void updateExperience(int value){
		int beexperience = Math.max(value, 0);
		int delta = beexperience - experience;
		if(delta > 0){
			expday += delta;
			exphour += delta;
		}
		experience = beexperience;
		
		checkLevelBonus();
	}
	
	public void checkLevelBonus(){		
		setParamsByExperience(experience);
		
		if(lastlvl < level){
			Connection _sqlconnection = null;				
			PreparedStatement updatelastlvl = null;
			
			try {
				_sqlconnection = ServerApplication.application.sqlpool.getConnection();
				
				updatelastlvl = _sqlconnection.prepareStatement("UPDATE user SET lastlvl=? WHERE id=?");
				updatelastlvl.setInt(1, level);
				updatelastlvl.setInt(2, id);						
				
        		if (updatelastlvl.executeUpdate() > 0){
        			lastlvl = level;
        			ServerApplication.application.userinfomanager.setBonusNewLevel(id);
        		}				
				
			} catch (SQLException e) {
				logger.error(e.toString());
			}
			finally
			{
			    try{
			    	if (_sqlconnection != null) _sqlconnection.close();		    	
			    	if (updatelastlvl != null) updatelastlvl.close(); 
			    	
			    	_sqlconnection = null;
			    	updatelastlvl = null;
			    }
			    catch (SQLException sqlx) {		     
			    }
			}
		}
	}
	
	public void updateExperience(int value, int changebanat){
		int beexperience = Math.max(value, 0);
		experience = beexperience;
		this.changebanat = changebanat;
		
		checkLevelBonus();
	}
	
	public void updatePopular(int value){
		int bepopular = Math.max(value, 0);
		popular = bepopular;
	}
	
	public void updateExpAndPopul(int exp, int pop, int changebanat){
		int beexperience = Math.max(exp, 0);		
		experience = beexperience;
		
		updatePopular(pop);
		
		this.changebanat = changebanat;
		
		checkLevelBonus();		
	}
	
	public void updateExpAndPopul(int exp, int pop){
		int beexperience = Math.max(exp, 0);		
		experience = beexperience;
		
		updatePopular(pop);
		
		checkLevelBonus();
	}
	
	public void updateMoney(int value){
		int bemoney = Math.max(value, 0);
		money = bemoney;
	}
	
	public void updateMoneyReal(int value){
		int bemoneyreal = Math.max(value, 0);
		moneyreal = bemoneyreal;
	} 
	
	
	
	public void updateMoney(int value, int addtodepositm, int adddtoeposite){		
		int bemoney = Math.max(value, 0);
		money = bemoney;
		claninfo.clandepositm += addtodepositm;
		claninfo.clandeposite += adddtoeposite;
	}
	
	public void update(int level, int experience, int energy){
		this.level = level;
		this.experience = experience;
	}
	
	public void updateGetQuestTime(){
		Connection _sqlconnection = null;
		PreparedStatement update = null;
		
		try {		
			Date date = new Date();
			int currenttime = (int)(date.getTime() / 1000);
			date = null;  
			
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			update = _sqlconnection.prepareStatement("UPDATE user SET getquesttime=? WHERE id=?");
			update.setInt(1, currenttime);
			update.setInt(2, id);
			if (update.executeUpdate() > 0){
				getQuestTime = currenttime;
			}
		} catch (SQLException e) {
			logger.error(e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (update != null) update.close(); 
		    	_sqlconnection = null;
		    	update = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void updateRentCars(){
		Connection _sqlconnection = null;
		PreparedStatement deleteCar = null;

		Set<Entry<Integer, CarModel>> set = cars.entrySet();
		for (Map.Entry<Integer, CarModel> car:set){
			if(car.getValue().rented == 1){
				Date date = new Date();
				int currenttime = (int)(date.getTime() / 1000);
				date = null;
				
				if(car.getValue().rentTime + Config.rentCarDuration() - currenttime <= 0){
					try {
						_sqlconnection = ServerApplication.application.sqlpool.getConnection();
						deleteCar = _sqlconnection.prepareStatement("DELETE FROM cars WHERE id=?");
						deleteCar.setInt(1, car.getValue().id);
						
						if(deleteCar.executeUpdate() > 0){
							cars.remove(car.getValue().id);
						}
					}catch (SQLException e) {
						logger.error(e.toString());
					}
					finally
					{
					    try{
					    	if (_sqlconnection != null) _sqlconnection.close(); 
					    	if (deleteCar != null) deleteCar.close(); 
					    	_sqlconnection = null;
					    	deleteCar = null;
					    }
					    catch (SQLException sqlx) {		     
					    }
					}
				}
			}
		}			
		set = null;
	}
}