package app.user.info;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.channels.SocketChannel;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import app.Config;
import app.ServerApplication;
import app.clan.ClanUserInfo;
import app.game.GameManager;
import app.logger.MyLogger;
import app.message.MessageType;
import app.quests.UserQuest;
import app.quests.UserQuestStatus;
import app.room.Room;
import app.room.game.GameRoom;
import app.shop.buyresult.BuyErrorCode;
import app.shop.buyresult.BuyResult;
import app.shop.car.CarId;
import app.shop.car.CarModel;
import app.user.ChatInfo;
import app.user.User;
import app.user.UserConnection;
import app.user.UserForTop;
import app.user.UserFriend;
import app.user.UserLoginMode;
import app.user.UserMailMessage;
import app.user.UserRole;
import app.user.VipType;
import app.user.chage.ChangeResult;
import app.utils.authorization.GameMode;
import app.utils.ban.BanResult;
import app.utils.ban.BanType;
import app.utils.changeinfo.ChangeInfoParams;
import app.utils.jsonobjectbuilder.JSONObjectBuilder;
import app.utils.jsonutil.JSONUtil;
import app.utils.md5.MD5;
import app.utils.options.Options;
import app.utils.protocol.ProtocolKeys;
import app.utils.protocol.ProtocolValues;
import app.utils.sex.Sex;
import atg.taglib.json.util.JSONArray;
import atg.taglib.json.util.JSONObject;


public class UserInfoManager{
	private MyLogger _logger = new MyLogger(Config.logPath(), UserInfoManager.class.getName());
	public Map<Integer, Integer> levels = new HashMap<Integer, Integer>();
	public List<Integer> popularparts = Arrays.asList(0, 50, 500, 5000, 20000, 60000, 150000, 300000, 1000000, 3000000, 10000000);
	public List<String> populartitles = Arrays.asList("Никому не известный", "Узнаваемый", "Известный", "Популярный", "Уважаемый", "Авторитет", "Знаменитость", "Король гонщиков", "Легендарный король гонщиков", "Верховный король гонщиков");
	
	public ArrayList<UserForTop> adminUsers = new ArrayList<UserForTop>();
	public ArrayList<UserForTop> moderatorUsers = new ArrayList<UserForTop>();
	public ArrayList<UserForTop> topUsers = new ArrayList<UserForTop>();
	public int minExperienceOfTopHourUser;
	public int minExperienceOfTopDayUser;
	public JSONArray topUsersJSON = new JSONArray();
	public ArrayList<UserForTop> topHourUsers = new ArrayList<UserForTop>();
	public JSONArray topHourUsersJSON = new JSONArray();
	public ArrayList<UserForTop> topDayUsers = new ArrayList<UserForTop>();
	public JSONArray topDayUsersJSON = new JSONArray();
	public ArrayList<UserForTop> topPopularUsers = new ArrayList<UserForTop>();
	public JSONArray topPopularUsersJSON = new JSONArray();
	public Options options = new Options();
	public int userscounter = 0;
	public int guestIdsCounter = -1;
	
	public Map<Integer, UserConnection> cheaterList;
	
	public UserInfoManager(){
		cheaterList = new ConcurrentHashMap<Integer, UserConnection>();
		
		Connection _sqlconnection = null;
		PreparedStatement getlevels = null;	
		ResultSet res = null;
		PreparedStatement selectusers = null;	
		ResultSet selectusersRes = null;
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			getlevels = _sqlconnection.prepareStatement("SELECT * FROM level");
			
			res = getlevels.executeQuery();					
			while(res.next()){
				levels.put(res.getInt("id"), res.getInt("experience"));
    		}
			selectusers = _sqlconnection.prepareStatement("SELECT count(id) FROM user");
			selectusersRes = selectusers.executeQuery();
			selectusersRes.next();
			userscounter = selectusersRes.getInt(1);		
		}catch (SQLException e) {
			_logger.error("UM1 " + e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (getlevels != null) getlevels.close();
		    	if (res != null) res.close();
		    	if (selectusers != null) selectusers.close();
		    	if (selectusersRes != null) selectusersRes.close();
		    	_sqlconnection = null;
		    	getlevels = null;
		    	res = null;
		    	selectusers = null;
		    	selectusersRes = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
		
		minExperienceOfTopHourUser = 0;
		minExperienceOfTopDayUser = 0;
		
		updateAdminUsers();
		updateModeratorUsers();
		updateTopUsers();
		updateTopHourUsers();
		updateTopDayUsers();
		updatePopularTopUsers();
		updateOptions();
	}
	
	public Boolean clientConnect(SocketChannel connection, String socialid, String passward, String ip, String confirmationid, int loginMode){
		Boolean good = true;		
    	if (socialid != null && socialid.length() > 0){    		
    		if (findAndAddUserToRoom(connection, socialid, ip, confirmationid, loginMode)){
    			good = true;
    		}else{
    			if(confirmationid != null)
    				return false;
    			if (insertUserToDataBase(connection, socialid) > 0){    				
    				if (findAndAddUserToRoom(connection, socialid, ip, confirmationid, loginMode)){
    	    			good = true;
    	    		}else{
    	    			good = false;
    	    		}
    			}else{
    				_logger.error("User don't create in DataBase");        				
    				good = false;
    			}
    		}
    	}else{
    		_logger.log("Connect user failed. This is not social game(send title and passward and check user)");
    		good = false;
    	}
    	return good;
	}
	
	public void removeUserByConnection(SocketChannel connection){
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		if(user != null){
			Set<Entry<String, Room>> set = ServerApplication.application.rooms.entrySet();
			for (Map.Entry<String, Room> room:set){
				room.getValue().removeUserByConnection(connection);			
			}
			
			Set<Entry<String, GameRoom>> gset = GameManager.gamerooms.entrySet();		
			for (Map.Entry<String, GameRoom> room:gset){    	
				room.getValue().removeUserByConnection(connection);			
			}
	    	user = null;
		}
	}
	
	public void updateParams(UserConnection user, String url){
		Connection _sqlconnection = null;
		PreparedStatement updateparams = null;
		
		try {
			if (user != null && (user.user.url == null || user.user.url.toLowerCase() == "null" || user.user.url.length() == 0) && url != null){
				_sqlconnection = ServerApplication.application.sqlpool.getConnection();
				updateparams = _sqlconnection.prepareStatement("UPDATE user SET url=? WHERE id=?");
				updateparams.setString(1, url);
				updateparams.setInt(2, user.user.id);				
				updateparams.executeUpdate();
				
				user.user.url = url;
			}
		}catch (SQLException e) {			
			_logger.error("UM2 " + e.toString());
		} 
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 		    	
		    	if (updateparams != null) updateparams.close();
		    	_sqlconnection = null;		    	
		    	updateparams = null;
		    }
		    catch (SQLException sqlx) {   
		    }
		}
	}
	
	private Boolean findAndAddUserToRoom(SocketChannel connection, String socialid, String ip, String confirmationid, int loginMode){
    	Boolean good = true;    	
    	Connection _sqlconnection = null;
    	PreparedStatement find = null;
    	ResultSet findRes = null;
    	PreparedStatement selectEnemies = null;
    	ResultSet selectEnemiesRes = null;
    	PreparedStatement selectCars = null;
    	ResultSet selectCarsRes = null;
    	PreparedStatement selectQuests = null;
    	ResultSet selectQuestsRes = null;
    	PreparedStatement updateparams = null;
    	PreparedStatement deleteCar = null;
    	
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		find = _sqlconnection.prepareStatement("SELECT * FROM user INNER JOIN clan ON user.clanid=clan.id WHERE idsocial=?");
    		find.setString(1, socialid);
    		findRes = find.executeQuery();    		
    		if (findRes.next()){
    			if(confirmationid != null && !confirmationid.toString().equals(findRes.getString("user.confirmationid")))
    				return false;
    				
    			UserConnection user = null;
    			ClanUserInfo claninfo = new ClanUserInfo(findRes.getInt("user.clanid"), findRes.getString("clan.title"), findRes.getInt("user.clandepositm"), findRes.getInt("user.clandeposite"), findRes.getByte("user.clanrole"), findRes.getInt("user.getclanmoneyat"));
    			
    			user = new UserConnection(findRes.getInt("user.id"), findRes.getString("user.idsocial"), ip, findRes.getInt("user.sex"), 
    										findRes.getString("user.title"), findRes.getInt("user.popular"), findRes.getInt("user.experience"), 
    										findRes.getInt("user.exphour"), findRes.getInt("user.expday"),findRes.getInt("user.lastlvl"),
    										findRes.getInt("user.money"), findRes.getInt("user.moneyreal"), findRes.getInt("user.role"), (byte)findRes.getInt("user.bantype"),
    										findRes.getInt("user.setbanat"), findRes.getInt("user.changebanat"), findRes.getString("user.url"), claninfo, findRes.getInt("user.inviter"), 
    										findRes.getInt("user.vip"), findRes.getInt("user.setvipat"), connection);
    			
    			user.user.getQuestTime = findRes.getInt("user.getquesttime");
    			if(user.user.role == UserRole.UNDEFINED || (user.user.title != null && user.user.title.indexOf(Config.lineSeparator()) != -1)){
    				connection.close();
    				return true;
    			}
    			user.user.loginMode = loginMode;
    			
    			user.user.upddate = new Date();
    			
    			if(findRes.getDate("user.gbdate") != null){
    				user.user.gbdate = new Date(findRes.getDate("user.gbdate").getTime());    				
    			}else{
    				user.user.gbdate = new Date();
    			}
    			if(findRes.getDate("user.sbdate") != null){
    				user.user.sbdate = new Date(findRes.getDate("user.sbdate").getTime());    				
    			}
    			
    			Date date = new Date();
				int currenttime = (int)(date.getTime() / 1000);
    			int timepassed = currenttime - user.user.setbanat;
    			date = null;
    			
    			int bantime = 0;
    			int viptime = ServerApplication.application.commonroom.updateVip(user, currenttime);
    			
    			if (BanType.noBan(user.user.bantype)){
    				bantime = 0;
    			}else if (BanType.by5Minut(user.user.bantype)){
    				bantime = 5 * 60 - timepassed;    				
    			}else if (BanType.by15Minut(user.user.bantype)){
    				bantime = 15 * 60 - timepassed;    				
    			}else if (BanType.by30Minut(user.user.bantype)){
    				bantime = 30 * 60 - timepassed;    			
    			}else if (BanType.byHour(user.user.bantype)){
    				bantime = 60 * 60 - timepassed;
    			}else if (BanType.byDay(user.user.bantype)){
    				bantime = 60 * 60 * 24 - timepassed;
    			}else if (BanType.byWeek(user.user.bantype)){
    				bantime = 60 * 60 * 24 * 7 - timepassed;
    			}
    			
    			selectCars = _sqlconnection.prepareStatement("SELECT * FROM cars WHERE uid=?");
    			selectCars.setInt(1, user.user.id);
    			selectCarsRes = selectCars.executeQuery();    		
	    		while(selectCarsRes.next()){
	    			CarModel car = new CarModel();
	    			car.id = selectCarsRes.getInt("id");
	    			car.prototype = ServerApplication.application.shopmanager.carsModel.getCarPrototypeById(selectCarsRes.getInt("pid"));
	    			car.color = selectCarsRes.getInt("color");
	    			car.durability = selectCarsRes.getInt("durability");
	    			car.rented = selectCarsRes.getInt("rented");
	    			car.rentTime = selectCarsRes.getInt("renttime");
	    			
	    			if(car.rented == 1 && !car.checkRentedTime()){
	    				car.rentTime = 0;
    					
    					deleteCar = _sqlconnection.prepareStatement("DELETE FROM cars WHERE id=?");
    					deleteCar.setInt(1, car.id);
    					deleteCar.executeUpdate();
    					
    					car = null;
    					continue;
	    			}
	    			user.user.cars.put(car.id, car);
	    		}
    			
    			selectEnemies = _sqlconnection.prepareStatement("SELECT * FROM enemies WHERE uid=? LIMIT 100");
    			selectEnemies.setInt(1, user.user.id);
    			selectEnemiesRes = selectEnemies.executeQuery();    		
	    		while(selectEnemiesRes.next()){
	    			user.user.enemies.put(selectEnemiesRes.getInt("eid"), selectEnemiesRes.getInt("eid"));	    			
	    		}
	    		
	    		UserQuest quest;
	    		selectQuests = _sqlconnection.prepareStatement("SELECT * FROM quests WHERE uid=?");
	    		selectQuests.setInt(1, user.user.id);
	    		selectQuestsRes = selectQuests.executeQuery();    		
	    		while(selectQuestsRes.next()){
	    			int staticQuestId = selectQuestsRes.getInt("qid");
	    			
	    			quest = new UserQuest();
	    			quest.status = (byte) selectQuestsRes.getInt("status");
	    			quest.value = selectQuestsRes.getInt("value");
	    			quest.staticData = ServerApplication.application.questsmanager.quests.get(staticQuestId);
	    			user.user.quests.put(staticQuestId, quest);
	    			
	    			if(quest.status == UserQuestStatus.PERFORMED){
	    				user.user.currentQuest = quest;
	    			}
	    		}
	    		quest = null;
    			
    			user.call(ProtocolValues.INIT_PERS_PARAMS, JSONObjectBuilder.createObjInitUser(user.user, bantime, viptime, popularparts, populartitles, ServerApplication.application.commonroom.users.size()));
    			
    			ServerApplication.application.commonroom.addUserWithoutMessage(user);
    			ServerApplication.application.commonroom.updateBan(user, currenttime);
    			if(findRes.getInt("user.sex") == Sex.UNDEFINED) ServerApplication.application.commonroom.showStartInfo(user);    			
    			good = true;
    			user = null;
    			connection = null;
    		}else{
    			good = false;
    		}
		} catch (Throwable e) {			
			_logger.error("UM3 " + e.toString() + " : " + e.getStackTrace().toString());
			good = false;
		} 
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (find != null) find.close(); 
		    	if (findRes != null) findRes.close();
		    	if (updateparams != null) updateparams.close();
		    	if (selectEnemies != null) selectEnemies.close();
		    	if (selectEnemiesRes != null) selectEnemiesRes.close();
		    	if (selectCars != null) selectCars.close();
		    	if (selectCarsRes != null) selectCarsRes.close();
		    	if (selectQuests != null) selectQuests.close();
		    	if (selectQuestsRes != null) selectQuestsRes.close();
		    	if (deleteCar != null) deleteCar.close();
		    	_sqlconnection = null;
		    	find = null;
		    	findRes = null;
		    	selectEnemies = null;
		    	selectEnemiesRes = null;
		    	selectCars = null;
		    	selectCarsRes = null;
		    	selectQuests = null;
		    	selectQuestsRes = null;
		    	updateparams = null;
		    	deleteCar = null;
		    }
		    catch (SQLException sqlx) {     
		    }
		}
    	return good;
    }
    private int insertUserToDataBase(SocketChannel conection, String socialid){
    	int countInsert = 0;
    	Connection sqlconnection = null;
    	PreparedStatement insert = null;
    	PreparedStatement insertCar = null;
    	PreparedStatement selectUser = null;
    	ResultSet selectUserRes = null;
    	
    	try {
    		sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		userscounter++;
    		
    		insert = sqlconnection.prepareStatement("INSERT INTO user (idsocial, sex, title, money) VALUES(?,?,?,?)");
    		insert.setString(1, socialid);
    		insert.setInt(2, Sex.UNDEFINED);
    		insert.setString(3, "Игрок " + userscounter);
    		insert.setInt(4, 50);
			countInsert = insert.executeUpdate();
			if(countInsert > 0){
				selectUser = sqlconnection.prepareStatement("SELECT * FROM user WHERE idsocial=?");
				selectUser.setString(1, socialid);
				selectUserRes = selectUser.executeQuery();    		
	    		if (selectUserRes.next()){
	    			insertCar = sqlconnection.prepareStatement("INSERT INTO cars (uid, pid, color, durability) VALUES(?,?,?,?)");
					insertCar.setInt(1, selectUserRes.getInt("id"));
					insertCar.setInt(2, CarId.VAZ_2110);
					insertCar.setInt(3, 0xFFFFFF);
					insertCar.setInt(4, 100);
					insertCar.executeUpdate();
	    		}
			}
		} catch (SQLException e) {
			_logger.error("UM4 " + e.toString());
		}
		finally
		{
		    try{
		    	if (sqlconnection != null) sqlconnection.close();
		    	if (insert != null) insert.close();
		    	if (insertCar != null) insertCar.close();
		    	if (selectUser != null) selectUser.close();
		    	if (selectUserRes != null) selectUserRes.close();
		    	sqlconnection = null;
		    	insert = null;
		    	insertCar = null;
		    	selectUser = null;
		    	selectUserRes = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
    	return countInsert;
    }
	
	public ChangeResult changeInfo(String title, int sex, SocketChannel connection, ChangeResult result, boolean startMode){
		UserConnection initiator = ServerApplication.application.commonroom.getUserByConnection(connection);
		
		Connection _sqlconnection = null;		
		PreparedStatement update = null;
		
		int price = Config.changeInfoPrice();
		if(initiator != null && initiator.user.loginMode == UserLoginMode.SITE){
			price = price / 2;
		}
		
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		
    		if(initiator != null && initiator.connection.isConnected()){
    			if (initiator.user.money >= price || startMode == true){
    				
    				if(startMode == false){	    					
    					initiator.user.updateMoney(initiator.user.money - price);
    					ServerApplication.application.commonroom.changeUserInfoByID(initiator.user.id, ChangeInfoParams.USER_MONEY, initiator.user.money, 0);
    				}
    				update = _sqlconnection.prepareStatement("UPDATE user SET title=?,sex=? WHERE id=?");
    				update.setString(1, title);
    				update.setInt(2, sex);    				
    				update.setInt(3, initiator.user.id);
    				
            		if (update.executeUpdate() > 0){
            			initiator.user.title = title;
            			initiator.user.sex = sex;
            			
            			result.errorCode = ChangeResult.OK;                			
            			result.user = initiator.user;
            		}else{
            			result.errorCode = ChangeResult.UNDEFINED;             			
            		}                		
    			}else{
    				result.errorCode = ChangeResult.NO_MONEY;        				
    			}
			}
    		initiator = null;	
		} catch (SQLException e) {		
			_logger.error("UM5 " + e.toString());
		}	
		finally
		{
		    try{
		    	if (_sqlconnection != null)  _sqlconnection.close(); 
		    	
		    	if (update != null)  update.close();
		    	update = null;
		    	_sqlconnection = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
		return result;
	}	
	
	public Boolean addMoney(int iduser, int addmoney, UserConnection user){
		Connection _sqlconnection = null;
		PreparedStatement pstm = null;
		ResultSet res = null;
		PreparedStatement update = null;
		
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		if(user != null){
    			user.user.updateMoney(user.user.money + addmoney);
    			ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY, user.user.money, 0);
    			
    			update = _sqlconnection.prepareStatement("UPDATE user SET money=? WHERE id=?");
				update.setInt(1, user.user.money);
				update.setInt(2, iduser);				
        		if (update.executeUpdate() > 0){
        			update.close();
        			return true;
        		}
    		}else{    		
	    		pstm = _sqlconnection.prepareStatement("SELECT * FROM user WHERE id=?");
	    		pstm.setInt(1, iduser);
	    		res = pstm.executeQuery();
	    		if (!res.next()){
	    		}else{    			
	    			update = _sqlconnection.prepareStatement("UPDATE user SET money=? WHERE id=?");
					update.setInt(1, Math.max(0, res.getInt("money") + addmoney));
					update.setInt(2, iduser);				
	        		if (update.executeUpdate() > 0){
	        			update.close();
	        			return true;
	        		}
	    		}
    		}
		} catch (SQLException e) {		
			_logger.error("UM6 " + e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (pstm != null) pstm.close(); 
		    	if (res != null) res.close(); 
		    	if (update != null) update.close();
		    	_sqlconnection = null;
		    	pstm = null;
		    	res = null;
		    	update = null;
		    }
		    catch (SQLException sqlx) {
		    }
		}
		return false;
	}
	
	public Boolean addMoneyReal(int iduser, int addmoney, UserConnection user){
		Connection _sqlconnection = null;
		PreparedStatement pstm = null;
		ResultSet res = null;
		PreparedStatement update = null;
		
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		if(user != null){
    			user.user.updateMoneyReal(user.user.moneyreal + addmoney);
    			ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_MONEYREAL, user.user.money, user.user.moneyreal);
    			
    			update = _sqlconnection.prepareStatement("UPDATE user SET moneyreal=? WHERE id=?");
				update.setInt(1, user.user.moneyreal);
				update.setInt(2, iduser);
        		if (update.executeUpdate() > 0){
        			update.close();
        			return true;
        		}
    		}else{    		
	    		pstm = _sqlconnection.prepareStatement("SELECT * FROM user WHERE id=?");
	    		pstm.setInt(1, iduser);
	    		res = pstm.executeQuery();
	    		if (!res.next()){
	    		}else{    			
	    			update = _sqlconnection.prepareStatement("UPDATE user SET moneyreal=? WHERE id=?");
					update.setInt(1, Math.max(0, res.getInt("moneyreal") + addmoney));
					update.setInt(2, iduser);				
	        		if (update.executeUpdate() > 0){
	        			update.close();
	        			return true;
	        		}
	    		}
    		}
		} catch (SQLException e) {		
			_logger.error("UM55 " + e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (pstm != null) pstm.close(); 
		    	if (res != null) res.close(); 
		    	if (update != null) update.close();
		    	_sqlconnection = null;
		    	pstm = null;
		    	res = null;
		    	update = null;
		    }
		    catch (SQLException sqlx) {
		    }
		}
		return false;
	}
	
	public byte ban(int bannedId, SocketChannel connection, byte type, boolean byip){	
		byte errorCode = 0;
		
		int price = 0;		
		if (BanType.by5Minut(type)){
			price = 100;
		}else if (BanType.by15Minut(type)){
			price = 400;
		}else if (BanType.by30Minut(type)){
			price = 800;
		}else if (BanType.byHour(type)){
			price = 2000;
		}else if (BanType.byDay(type)){
			price = 25000;
		}else if (BanType.byWeek(type)){
			price = 200000;
		}
		
		UserConnection initiator = ServerApplication.application.commonroom.getUserByConnection(connection);
		UserConnection banned = ServerApplication.application.commonroom.users.get(Integer.toString(bannedId));
		
		Connection _sqlconnection = null;
		PreparedStatement updatemoney = null;
		PreparedStatement setban = null;
		
		Date date = new Date();
		int currenttime = (int)(date.getTime() / 1000);
		date = null;
		
		if (UserRole.isModerator(initiator.user.role)){ 
			if (BanType.by5Minut(type) || BanType.by15Minut(type) || BanType.byHour(type) || BanType.by30Minut(type)){
				price = 0;
			}
		}
		
		if (UserRole.isAdministrator(initiator.user.role) || UserRole.isAdministratorMain(initiator.user.role)){
			if(BanType.byDay(type)){
				ServerApplication.application.logger.log("ADMIN BAN USER " + bannedId + " by DAY");
			}
			if(BanType.byWeek(type)){
				ServerApplication.application.logger.log("ADMIN BAN USER " + bannedId + " by WEEK");
			}
			price = 0;
		}
		
		if(type != BanType.MINUT5 && type != BanType.MINUT15){
			if (initiator.user.role != UserRole.MODERATOR && initiator.user.role != UserRole.ADMINISTRATOR &&
				initiator.user.role != UserRole.ADMINISTRATOR_MAIN){
				return BanResult.OTHER;
			}
		}
		
		if(initiator != null && initiator.connection.isConnected()){
			if (initiator.user.money >= price){
				if(banned != null && banned.user.bantype <= type){
					if(!UserRole.isAdministrator(initiator.user.role) && !UserRole.isAdministratorMain(initiator.user.role) && 
							!UserRole.isModerator(initiator.user.role)){
						if(UserRole.isAdministrator(banned.user.role) || UserRole.isAdministratorMain(banned.user.role) || 
								UserRole.isModerator(banned.user.role)){
								return BanResult.OTHER;
						}
					}
					
					initiator.user.updateMoney(initiator.user.money - price);
					ServerApplication.application.commonroom.changeUserInfoByID(initiator.user.id, ChangeInfoParams.USER_MONEY, initiator.user.money, 0);
					
					try {						
						_sqlconnection = ServerApplication.application.sqlpool.getConnection();
						
						if((UserRole.isAdministrator(initiator.user.role) || UserRole.isAdministratorMain(initiator.user.role)) && byip){
							setban = _sqlconnection.prepareStatement("UPDATE user SET bantype=?,setbanat=?,changebanat=? WHERE id=? or ip=?");
	        				setban.setInt(1, type);
	        				setban.setInt(2, currenttime);
	        				setban.setInt(3, currenttime);
	        				setban.setInt(4, bannedId);
	        				setban.setString(5, banned.user.ip);
	        				if (setban.executeUpdate() > 0){
	        					errorCode = BanResult.OK;
	        					
	        					Set<Entry<String, UserConnection>> set = ServerApplication.application.commonroom.users.entrySet();
	        					for (Map.Entry<String, UserConnection> user:set){        						
	        						if(user.getValue().user.ip.toString().equals(banned.user.ip)){
	        							user.getValue().user.setbanat = currenttime;
	        							user.getValue().user.changebanat = currenttime;
	        							user.getValue().user.bantype = type;
	            						
	                					ServerApplication.application.commonroom.sendBanMessage(user.getValue().user.id, connection, type);
	        						}
	        					}			
	        					set = null;
	        				}		       
						}else{
							setban = _sqlconnection.prepareStatement("UPDATE user SET bantype=?,setbanat=?,changebanat=? WHERE id=?");
	        				setban.setInt(1, type);
	        				setban.setInt(2, currenttime);
	        				setban.setInt(3, currenttime);
	        				setban.setInt(4, bannedId);
	        				if (setban.executeUpdate() > 0){
	        					errorCode = BanResult.OK;
	        					
	        					banned.user.setbanat = currenttime;
	        					banned.user.changebanat = currenttime;
	        					banned.user.bantype = type;
	        					
            					ServerApplication.application.commonroom.sendBanMessage(banned.user.id, connection, type);
	        				}
						}
					}catch (SQLException e) {
						_logger.error("UM8 " + e.toString());
					}
					finally
					{
					    try{
					    	if (_sqlconnection != null) _sqlconnection.close();
					    	if (updatemoney != null) updatemoney.close();
					    	if (setban != null) setban.close();		
					    	_sqlconnection = null;
					    	updatemoney = null;
					    	setban = null;
					    }
					    catch (SQLException sqlx) {   
					    }
					}
				}else{
					errorCode = BanResult.OTHER; 
				}
			}else{
				errorCode = BanResult.NO_MONEY; 
			}
		}else{
			errorCode = BanResult.OTHER;
		}
		
		initiator = null;
		banned = null;
		return errorCode;
	}	
	
	public void banoff(int userId, String userIp){
		Connection _sqlconnection = null;
		PreparedStatement banoffst = null;		
				
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			banoffst = _sqlconnection.prepareStatement("UPDATE user SET bantype=?,setbanat=? WHERE id=?");
			banoffst.setInt(1, BanType.NO_BAN);
			banoffst.setInt(2, 0);
			banoffst.setInt(3, userId);			
			if (banoffst.executeUpdate() > 0){
			}   			
		}catch (SQLException e) {
			_logger.error("UM9 " + e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (banoffst != null) banoffst.close();
		    	_sqlconnection = null;
		    	banoffst = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void vipoff(int userId){
		Connection _sqlconnection = null;
		PreparedStatement coloroffst = null;		
				
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			coloroffst = _sqlconnection.prepareStatement("UPDATE user SET vip=?,setvipat=? WHERE id=?");
			coloroffst.setInt(1, VipType.NONE);
			coloroffst.setInt(2, 0);
			coloroffst.setInt(3, userId);
			if (coloroffst.executeUpdate() > 0){
			}   			
		}catch (SQLException e) {
			_logger.error("vipoff error " + e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (coloroffst != null) coloroffst.close();
		    	_sqlconnection = null;
		    	coloroffst = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void getInvitedUsers(SocketChannel connection, JSONObject params){
    	UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
    	
    	ArrayList<UserForTop> invitedUsers = new ArrayList<UserForTop>();
    	if (user != null){
    		Connection _sqlconnection = null;
    		PreparedStatement pstm = null;	
    		ResultSet resExp = null;
    		
    		try {
    			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    			pstm = _sqlconnection.prepareStatement("SELECT * FROM user WHERE inviter=?");
    			pstm.setInt(1, user.user.id);
    			resExp = pstm.executeQuery();
    			while(resExp.next()){
    				UserForTop u = new UserForTop(resExp.getInt("id"), resExp.getInt("role"), resExp.getInt("sex"), resExp.getString("title"), getLevelByExperience(resExp.getInt("experience")), resExp.getInt("exphour"), resExp.getInt("expday"), resExp.getInt("popular"), resExp.getInt("vip"), resExp.getString("url"));
    				
    				if(ServerApplication.application.commonroom.users.get(Integer.toString(u.id)) != null){
        				u.isonline = true;
        			}else{
        				u.isonline = false;
        			}
    				
    				invitedUsers.add(u);
        		}
    		}catch (SQLException e) {
    			_logger.error("get invited users error " + e.toString());
    		}
    		finally
    		{
    		    try{		    	
    		    	if (_sqlconnection != null) _sqlconnection.close();
    		    	if (pstm != null) pstm.close();
    		    	if (resExp != null) resExp.close();
    		    	_sqlconnection = null;
    		    	pstm = null;
    		    	resExp = null;
    		    }
    		    catch (SQLException sqlx) {		     
    		    }
    		}
    	}
    	
    	ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), ProtocolKeys.USERS, JSONObjectBuilder.createObjUsersForTop(invitedUsers));		
    }
	
	public void updateAdminUsers(){		
		Connection _sqlconnection = null;
		PreparedStatement pstm = null;	
		ResultSet resExp = null;
		
		adminUsers.clear();
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			pstm = _sqlconnection.prepareStatement("SELECT * FROM user WHERE role=? OR role=?");
			pstm.setInt(1, UserRole.ADMINISTRATOR);
			pstm.setInt(2, UserRole.ADMINISTRATOR_MAIN);
			resExp = pstm.executeQuery();
			while(resExp.next()){
				UserForTop u = new UserForTop(resExp.getInt("id"), resExp.getInt("role"), resExp.getInt("sex"), resExp.getString("title"), getLevelByExperience(resExp.getInt("experience")), resExp.getInt("exphour"), resExp.getInt("expday"), resExp.getInt("popular"), resExp.getInt("vip"), resExp.getString("url"));
				
				if(ServerApplication.application.commonroom.users.get(Integer.toString(u.id)) != null){
    				u.isonline = true;
    			}else{
    				u.isonline = false;
    			}
				adminUsers.add(u);
    		}
		}catch (SQLException e) {
			_logger.error("select admin users error " + e.toString());
		}
		finally
		{
		    try{		    	
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (pstm != null) pstm.close();
		    	if (resExp != null) resExp.close();
		    	_sqlconnection = null;
		    	pstm = null;
		    	resExp = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}   	
    }
	
	public void updateModeratorUsers(){		
		Connection _sqlconnection = null;
		PreparedStatement pstm = null;	
		ResultSet resExp = null;
		
		moderatorUsers.clear();
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			pstm = _sqlconnection.prepareStatement("SELECT * FROM user WHERE role=?");
			pstm.setInt(1, UserRole.MODERATOR);
			resExp = pstm.executeQuery();
			while(resExp.next()){				
				UserForTop u = new UserForTop(resExp.getInt("id"), resExp.getInt("role"), resExp.getInt("sex"), resExp.getString("title"), getLevelByExperience(resExp.getInt("experience")), resExp.getInt("exphour"), resExp.getInt("expday"), resExp.getInt("popular"), resExp.getInt("vip"), resExp.getString("url"));
				
				if(ServerApplication.application.commonroom.users.get(Integer.toString(u.id)) != null){
    				u.isonline = true;
    			}else{
    				u.isonline = false;
    			}
				
				moderatorUsers.add(u);
    		}
		}catch (SQLException e) {
			_logger.error("select moderator users error " + e.toString());
		}
		finally
		{
		    try{		    	
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (pstm != null) pstm.close();
		    	if (resExp != null) resExp.close();
		    	_sqlconnection = null;
		    	pstm = null;
		    	resExp = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}   	
    }
	
	public void updateTopUsers(){		
		byte from = 1;
		byte to = 125;
		byte limit = 30;
		
		Connection _sqlconnection = null;
		PreparedStatement pstm = null;	
		ResultSet resExp = null;
		
		int fromvalue = Integer.MAX_VALUE;
		int tovalue = Integer.MAX_VALUE;
		if(levels.get(new Integer(from)) != null) fromvalue = levels.get(new Integer(from));
		if (levels.get(new Integer(to + 1)) != null) tovalue = levels.get(new Integer(to + 1)) - 1;
		
		topUsers.clear();
		topUsersJSON = null;
		topUsersJSON = new JSONArray();
		
		try {
			int second = 1000;
			int minute = 60 * second;
			int hour = 60 * minute;
			long day = 24 * hour;
			long month = 30 * day;
			
			Date date = new Date();
			java.sql.Date sqlDate = new java.sql.Date(date.getTime() - month);
				
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			pstm = _sqlconnection.prepareStatement("SELECT * FROM user WHERE experience>=? AND experience<=? AND upddate>? ORDER BY experience DESC LIMIT ?");
			pstm.setInt(1, fromvalue);
			pstm.setInt(2, tovalue);
			pstm.setDate(3, sqlDate);
			pstm.setInt(4, limit);
			resExp = pstm.executeQuery();
			while(resExp.next()){				
				UserForTop u = new UserForTop(resExp.getInt("id"), resExp.getInt("role"), resExp.getInt("sex"), resExp.getString("title"), getLevelByExperience(resExp.getInt("experience")), resExp.getInt("exphour"), resExp.getInt("expday"), resExp.getInt("popular"), resExp.getInt("vip"), resExp.getString("url"));
				
				if(ServerApplication.application.commonroom.users.get(Integer.toString(u.id)) != null){
    				u.isonline = true;
    			}else{
    				u.isonline = false;
    			}
				
				topUsers.add(u);
    		}
			topUsersJSON = JSONObjectBuilder.createObjUsersForTop(topUsers);			
		}catch (SQLException e) {
			_logger.error("UM12 " + e.toString());
		}
		finally
		{
		    try{		    	
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (pstm != null) pstm.close();
		    	if (resExp != null) resExp.close();
		    	_sqlconnection = null;
		    	pstm = null;
		    	resExp = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}   	
    }
	
	public void updateTopHourUsers(){	
		byte limit = 10;
		
		Connection _sqlconnection = null;
		PreparedStatement pstm = null;	
		ResultSet resExp = null;		
		
		topHourUsers.clear();
		topHourUsersJSON = null;
		topHourUsersJSON = new JSONArray();
		
		minExperienceOfTopHourUser = Integer.MAX_VALUE;
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			pstm = _sqlconnection.prepareStatement("SELECT * FROM user ORDER BY exphour DESC LIMIT ?");			
			pstm.setInt(1, limit);
			resExp = pstm.executeQuery();
			while(resExp.next()){				
				UserForTop u = new UserForTop(resExp.getInt("id"), resExp.getInt("role"), resExp.getInt("sex"), resExp.getString("title"), getLevelByExperience(resExp.getInt("experience")), resExp.getInt("exphour"), resExp.getInt("expday"), resExp.getInt("popular"), resExp.getInt("vip"), resExp.getString("url"));
				
				if(ServerApplication.application.commonroom.users.get(Integer.toString(u.id)) != null){
    				u.isonline = true;
    			}else{
    				u.isonline = false;
    			}
				
				topHourUsers.add(u);
				
				if(u.exphour < minExperienceOfTopHourUser){
					minExperienceOfTopHourUser = u.exphour;
				}
    		}
			topHourUsersJSON = JSONObjectBuilder.createObjUsersForTop(topHourUsers);
		}catch (SQLException e) {
			_logger.error("UM12 " + e.toString());
		}
		finally
		{
		    try{		    	
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (pstm != null) pstm.close();
		    	if (resExp != null) resExp.close();
		    	_sqlconnection = null;
		    	pstm = null;
		    	resExp = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
    }
	
	public void updateTopDayUsers(){	
		byte limit = 10;
		
		Connection _sqlconnection = null;
		PreparedStatement pstm = null;	
		ResultSet resExp = null;		
		
		topDayUsers.clear();
		topDayUsersJSON = null;
		topDayUsersJSON = new JSONArray();
		
		minExperienceOfTopDayUser = Integer.MAX_VALUE;
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			pstm = _sqlconnection.prepareStatement("SELECT * FROM user ORDER BY expday DESC LIMIT ?");			
			pstm.setInt(1, limit);
			resExp = pstm.executeQuery();
			while(resExp.next()){				
				UserForTop u = new UserForTop(resExp.getInt("id"), resExp.getInt("role"), resExp.getInt("sex"), resExp.getString("title"), getLevelByExperience(resExp.getInt("experience")), resExp.getInt("exphour"), resExp.getInt("expday"), resExp.getInt("popular"), resExp.getInt("vip"), resExp.getString("url"));
				
				if(ServerApplication.application.commonroom.users.get(Integer.toString(u.id)) != null){
    				u.isonline = true;
    			}else{
    				u.isonline = false;
    			}
				
				topDayUsers.add(u);
				
				if(u.expday < minExperienceOfTopDayUser){
					minExperienceOfTopDayUser = u.expday;
				}
    		}
			topDayUsersJSON = JSONObjectBuilder.createObjUsersForTop(topDayUsers);
		}catch (SQLException e) {
			_logger.error("UM12 " + e.toString());
		}
		finally
		{
		    try{		    	
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (pstm != null) pstm.close();
		    	if (resExp != null) resExp.close();
		    	_sqlconnection = null;
		    	pstm = null;
		    	resExp = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}   	
    }
	
	public void updatePopularTopUsers(){		
		byte limit = 30;
		
		Connection _sqlconnection = null;
		PreparedStatement pstm = null;	
		ResultSet resExp = null;		
		
		topPopularUsers.clear();
		topPopularUsersJSON = null;
		topPopularUsersJSON = new JSONArray();
		
		try {
			int second = 1000;
			int minute = 60 * second;
			int hour = 60 * minute;
			long day = 24 * hour;
			long month = 30 * day;
			
			Date date = new Date();
			java.sql.Date sqlDate = new java.sql.Date(date.getTime() - month);
			
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			pstm = _sqlconnection.prepareStatement("SELECT * FROM user WHERE upddate>? ORDER BY popular DESC LIMIT ?");			
			pstm.setDate(1, sqlDate);
			pstm.setInt(2, limit);
			resExp = pstm.executeQuery();				
			while(resExp.next()){
				UserForTop u = new UserForTop(resExp.getInt("id"), resExp.getInt("role"), resExp.getInt("sex"), resExp.getString("title"), getLevelByExperience(resExp.getInt("experience")), resExp.getInt("exphour"), resExp.getInt("expday"), resExp.getInt("popular"), resExp.getInt("vip"), resExp.getString("url"));
				
				if(ServerApplication.application.commonroom.users.get(Integer.toString(u.id)) != null){
    				u.isonline = true;
    			}else{
    				u.isonline = false;
    			}
				
				topPopularUsers.add(u);
    		}
			topPopularUsersJSON = JSONObjectBuilder.createObjUsersForTop(topPopularUsers);
		}catch (SQLException e) {
			_logger.error("UM13 " + e.toString());
		}
		finally
		{
		    try{		    	
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (pstm != null) pstm.close();
		    	if (resExp != null) resExp.close();
		    	_sqlconnection = null;
		    	pstm = null;
		    	resExp = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
    }
	
	public boolean addToFriend(int uid,int fid, String note){
		Connection _sqlconnection = null;
		PreparedStatement findfriend = null;
		ResultSet findfriendRes = null;
		PreparedStatement insertfriend = null;
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		findfriend = _sqlconnection.prepareStatement("SELECT * FROM friends WHERE uid=? AND fid=?");
    		findfriend.setInt(1, uid);
    		findfriend.setInt(2, fid);
    		findfriendRes = findfriend.executeQuery();
    		
    		if (findfriendRes.next()){    			
    			return false;		
    		}else{
    			findfriend = _sqlconnection.prepareStatement("SELECT count(*) FROM friends WHERE uid=?");
        		findfriend.setInt(1, uid);
        		findfriendRes = findfriend.executeQuery();
        		
        		if(findfriendRes.next()){
        			if(findfriendRes.getInt("count(*)") < 100){
        				insertfriend = _sqlconnection.prepareStatement("INSERT INTO friends (uid, fid, note) VALUES(?,?,?)");
            			insertfriend.setInt(1, uid);
            			insertfriend.setInt(2, fid);
            			insertfriend.setString(3, note);
            			insertfriend.executeUpdate();
            			return true;
        			}
        		}
    		}
		}catch (SQLException e){		
			_logger.error("UM14 " + e.toString());
		}	
		finally
		{
		    try{
		    	if (_sqlconnection != null)  _sqlconnection.close();
		    	if (findfriend != null)  findfriend.close(); 
		    	if (findfriendRes != null)  findfriendRes.close(); 
		    	if (insertfriend != null)  insertfriend.close();
		    	findfriend = null;
		    	findfriendRes = null;
		    	insertfriend = null;		    	
		    	_sqlconnection = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
		return false;
	}
	
	public void addToEnemy(int uid,int eid){
		Connection _sqlconnection = null;
		PreparedStatement findenemy = null;
		ResultSet findenemyRes = null;
		PreparedStatement insertenemy = null;		
		
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		findenemy = _sqlconnection.prepareStatement("SELECT * FROM enemies WHERE uid=? AND eid=?");
    		findenemy.setInt(1, uid);
    		findenemy.setInt(2, eid);
    		findenemyRes = findenemy.executeQuery();    		
    		if (findenemyRes.next()){    			
    			return;		
    		}else{
    			insertenemy = _sqlconnection.prepareStatement("INSERT INTO enemies (uid, eid) VALUES(?,?)");    			
    			insertenemy.setInt(1, uid);
    			insertenemy.setInt(2, eid); 			    		
    			insertenemy.executeUpdate();
    		}	
		} catch (SQLException e) {		
			_logger.error("UM40 " + e.toString());
		}	
		finally
		{
		    try{
		    	if (_sqlconnection != null)  _sqlconnection.close();
		    	if (findenemy != null)  findenemy.close(); 
		    	if (findenemyRes != null)  findenemyRes.close(); 
		    	if (insertenemy != null)  insertenemy.close();
		    	findenemy = null;
		    	findenemyRes = null;
		    	insertenemy = null;		    	
		    	_sqlconnection = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void removeFriend(int uid,int fid){
		Connection _sqlconnection = null;
		PreparedStatement deletefriend = null;			
		
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		
    		deletefriend = _sqlconnection.prepareStatement("DELETE FROM friends WHERE uid=? AND fid=?");
    		deletefriend.setInt(1, uid);
    		deletefriend.setInt(2, fid);
    		deletefriend.executeUpdate();
		} catch (SQLException e) {		
			_logger.error("UM15 " + e.toString());
		}	
		finally
		{
		    try{
		    	if (_sqlconnection != null)  _sqlconnection.close();
		    	if (deletefriend != null)  deletefriend.close();
		    	deletefriend = null;
		    	_sqlconnection = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void removeEnemy(int uid,int eid){
		Connection _sqlconnection = null;
		PreparedStatement deleteenemy = null;			
		
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		
    		deleteenemy = _sqlconnection.prepareStatement("DELETE FROM enemies WHERE uid=? AND eid=?");
    		deleteenemy.setInt(1, uid);
    		deleteenemy.setInt(2, eid);
    		deleteenemy.executeUpdate();
		} catch (SQLException e) {		
			_logger.error("UM15 " + e.toString());
		}	
		finally
		{
		    try{
		    	if (_sqlconnection != null)  _sqlconnection.close();
		    	if (deleteenemy != null)  deleteenemy.close();
		    	deleteenemy = null;
		    	_sqlconnection = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public ArrayList<UserFriend> getFiends(int uid, int offset){		
    	Connection _sqlconnection = null;
    	PreparedStatement find = null;
    	ResultSet findRes = null;
    	
    	ArrayList<UserFriend> friends = new ArrayList<UserFriend>();
    	
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();    		    		
    		find = _sqlconnection.prepareStatement("SELECT * FROM friends INNER JOIN user ON friends.fid=user.id WHERE friends.uid=? LIMIT 50 OFFSET ?");
    		find.setInt(1, uid);
    		find.setInt(2, offset);
    		findRes = find.executeQuery();    		
    		while (findRes.next()){
    			UserFriend user = new UserFriend(findRes.getInt("user.id"), findRes.getInt("user.role"), findRes.getString("user.title"), findRes.getInt("user.experience"), findRes.getInt("user.popular"), findRes.getString("user.url"), findRes.getString("friends.note"));
    			
    			if(ServerApplication.application.commonroom.users.get(Integer.toString(user.id)) != null){
    				user.isonline = true;
    			}else{
    				user.isonline = false;
    			}
    			
    			friends.add(user);    			
    		}
		} catch (SQLException e) {			
			_logger.error("UM16 " + e.toString());
			
		} 
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (find != null) find.close(); 
		    	if (findRes != null) findRes.close();		    	
		    	_sqlconnection = null;
		    	find = null;
		    	findRes = null;		    	
		    }
		    catch (SQLException sqlx) {     
		    }
		}
    	return friends;
	}
	
	public ArrayList<UserFriend> getEnemies(int uid, int offset){		
    	Connection _sqlconnection = null;
    	PreparedStatement find = null;
    	ResultSet findRes = null;
    	
    	ArrayList<UserFriend> friends = new ArrayList<UserFriend>();
    	
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();    		    		
    		find = _sqlconnection.prepareStatement("SELECT * FROM enemies INNER JOIN user ON enemies.eid=user.id WHERE enemies.uid=? LIMIT 50 OFFSET ?");
    		find.setInt(1, uid);
    		find.setInt(2, offset);
    		findRes = find.executeQuery();    		
    		while (findRes.next()){
    			UserFriend user = new UserFriend(findRes.getInt("user.id"), findRes.getInt("user.role"), findRes.getString("user.title"), findRes.getInt("user.experience"), findRes.getInt("user.popular"), findRes.getString("user.url"), "");
    			
    			if(ServerApplication.application.commonroom.users.get(Integer.toString(user.id)) != null){
    				user.isonline = true;
    			}else{
    				user.isonline = false;
    			}
    			
    			friends.add(user);    			
    		}
		} catch (SQLException e) {			
			_logger.error("UM16 " + e.toString());
			
		} 
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (find != null) find.close(); 
		    	if (findRes != null) findRes.close();		    	
		    	_sqlconnection = null;
		    	find = null;
		    	findRes = null;		    	
		    }
		    catch (SQLException sqlx) {     
		    }
		}
    	return friends;
	}
	
	public UserConnection getOfflineUser(int userID){    	
    	Connection _sqlconnection = null;
    	PreparedStatement find = null;
    	ResultSet findRes = null;
    	
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();    		    		
    		find = _sqlconnection.prepareStatement("SELECT * FROM user INNER JOIN clan ON user.clanid=clan.id WHERE user.id=?");
    		find.setInt(1, userID);
    		findRes = find.executeQuery();    		
    		if (findRes.next()){
    			UserConnection user = null;
    			ClanUserInfo claninfo = new ClanUserInfo(findRes.getInt("user.clanid"), findRes.getString("clan.title"), findRes.getInt("user.clandepositm"), findRes.getInt("user.clandeposite"), findRes.getByte("user.clanrole"), findRes.getInt("user.getclanmoneyat"));
    			
    			user = new UserConnection(findRes.getInt("user.id"), findRes.getString("user.idsocial"), findRes.getString("user.ip"), findRes.getInt("user.sex"), 
    										findRes.getString("user.title"), findRes.getInt("user.popular"), findRes.getInt("user.experience"), 
    										findRes.getInt("user.exphour"), findRes.getInt("user.expday"), findRes.getInt("user.lastlvl"),
    										findRes.getInt("user.money"), findRes.getInt("user.moneyreal"), findRes.getByte("user.role"), (byte)findRes.getInt("user.bantype"),
    										findRes.getInt("user.setbanat"), findRes.getInt("user.changebanat"), findRes.getString("user.url"), claninfo, findRes.getInt("user.inviter"),
    										findRes.getInt("user.vip"), findRes.getInt("user.setvipat"), null);
    			claninfo = null;
    			return user;
    		}
		} catch (SQLException e) {			
			_logger.error("UM17 " + e.toString());
		} 
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (find != null) find.close(); 
		    	if (findRes != null) findRes.close();		    	
		    	_sqlconnection = null;
		    	find = null;
		    	findRes = null;		    	
		    }
		    catch (SQLException sqlx) {     
		    }
		}
		return null;
    }
	
	public BuyResult sendMail(UserConnection fromUser, int toID, String msg){
		BuyResult buyresult = new BuyResult();
		buyresult.error = BuyErrorCode.OTHER;
		
		Connection _sqlconnection = null;		
		PreparedStatement insert = null;
		
		Date date = new Date();
		java.sql.Date sqlDate = new java.sql.Date(date.getTime());
		
		if(fromUser != null){		
			if(fromUser.user.money > Config.sendMailPrice()){		
		    	try {		    		
		    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
		    		insert = _sqlconnection.prepareStatement("INSERT INTO messages (fromid, toid, msg, ctime) VALUES(?,?,?,?)");
		    		insert.setInt(1, fromUser.user.id);
		    		insert.setInt(2, toID);
		    		insert.setString(3, msg);
		    		insert.setDate(4, sqlDate);
		    		insert.executeUpdate();
					
					buyresult.error = BuyErrorCode.OK;
					
					fromUser.user.updateMoney(fromUser.user.money - Config.sendMailPrice());
					ServerApplication.application.commonroom.changeUserInfoByID(fromUser.user.id, ChangeInfoParams.USER_MONEY, fromUser.user.money, 0);
				} catch (SQLException e) {		
					_logger.error("UM18 " + e.toString());
				}	
				finally
				{
				    try{
				    	if (_sqlconnection != null)  _sqlconnection.close();		    	
				    	if (insert != null)  insert.close();		    	
				    	insert = null;		    	
				    	_sqlconnection = null;
				    }
				    catch (SQLException sqlx) {		     
				    }
				}
			}else{
				buyresult.error = BuyErrorCode.NOT_ENOUGH_MONEY;
			}
		}
		return buyresult;
	}
	
	public ArrayList<UserMailMessage> getMailMessages(int uid, int offset){		
    	Connection _sqlconnection = null;
    	PreparedStatement find = null;
    	ResultSet findRes = null;
    	
    	ArrayList<UserMailMessage> friends = new ArrayList<UserMailMessage>();
    	
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();    		    		
    		find = _sqlconnection.prepareStatement("SELECT * FROM messages INNER JOIN user ON messages.fromid=user.id WHERE messages.toid=? ORDER BY messages.id DESC LIMIT 20 OFFSET ?");
    		find.setInt(1, uid);
    		find.setInt(2, offset);
    		findRes = find.executeQuery();
    		while (findRes.next()){
    			String ctime = "";
    			if(findRes.getDate("messages.ctime") != null){
    				ctime = findRes.getDate("messages.ctime").toString();
    			}
    			UserMailMessage user = new UserMailMessage(findRes.getInt("user.id"), findRes.getString("user.title"), findRes.getInt("user.experience"), findRes.getInt("user.popular"), findRes.getString("user.url"), ctime);
    			
    			if(ServerApplication.application.commonroom.users.get(Integer.toString(user.id)) != null){
    				user.isonline = true;
    			}else{
    				user.isonline = false;
    			}
    			user.message = findRes.getString("messages.msg");
    			user.messageid = findRes.getInt("messages.id");
    			
    			friends.add(user);
    		}
		} catch (SQLException e) {			
			_logger.error("UM19 " + e.toString());
			
		} 
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close(); 
		    	if (find != null) find.close(); 
		    	if (findRes != null) findRes.close();		    	
		    	_sqlconnection = null;
		    	find = null;
		    	findRes = null;		    	
		    }
		    catch (SQLException sqlx) {     
		    }
		}
    	return friends;
	}
	
	public void removeMailMessage(int mid){
		Connection _sqlconnection = null;
		PreparedStatement delete = null;			
		
    	try {
    		_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    		
    		delete = _sqlconnection.prepareStatement("DELETE FROM messages WHERE id=?");
    		delete.setInt(1, mid);
    		delete.executeUpdate();
		} catch (SQLException e) {		
			_logger.error("UM20 " + e.toString());
		}	
		finally
		{
		    try{
		    	if (_sqlconnection != null)  _sqlconnection.close();
		    	if (delete != null)  delete.close();
		    	delete = null;
		    	_sqlconnection = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public JSONObject getFriendsBonus(UserConnection user, String vid, int mode, int appID, String sessionKey){
		if(user != null){
			if (mode == GameMode.DEBUG){			
		    	return JSONObjectBuilder.createObjFriendsBonusResult(6, 0);
	    	}else if (mode == GameMode.VK){
	    		return JSONObjectBuilder.createObjFriendsBonusResult(0, 0);
	    	}else if (mode == GameMode.OD){
	    		//в vid передаем секретный сессионный ключ для того чтобы не заводить дополнительных параметров
	    		//этот параметр нужен для подписи sig
	    		int countfriends = 0;
	    		String sig = MD5.getMD5("application_key=" + Config.publicSecretOD() + "session_key=" + sessionKey + vid);
	    		
	    		try{sessionKey = URLEncoder.encode(sessionKey, "UTF-8");
	    		}catch(Throwable e){ServerApplication.application.logger.log("UM30 " + e.toString());} 
	    				
	    		try{
	    			URL url = new URL(Config.apiUrlOD() + "api/friends/getAppUsers" + "?application_key=" + Config.publicSecretOD() + "&session_key=" + sessionKey + "&sig=" + sig);
	    			
	    			HttpURLConnection urlConnection = (HttpURLConnection)url.openConnection();
	    			urlConnection.setDoInput(true);
	    			urlConnection.setDoOutput(true);
	    			urlConnection.setUseCaches(false);
	    			urlConnection.setRequestMethod("GET");
	    					         
	    			InputStream is = urlConnection.getInputStream();
	    			BufferedReader rd = new BufferedReader(new InputStreamReader(is));
	    			String line;
	    			StringBuffer response = new StringBuffer(); 
	    			while((line = rd.readLine()) != null) {
	    				response.append(line);
	    				response.append('\r');
	    			}
	    			String[] friendsArr = response.toString().split(",");
	    			countfriends = Math.min(10, friendsArr.length);
	    	  	
	    			rd.close();
	    			rd = null;
	    			is.close();
	    	        is = null;
	    			
	    	        urlConnection.disconnect();
	    	        urlConnection = null;
	    	        url = null;
	    		}catch(IOException e){
	    			ServerApplication.application.logger.log("AM10" + e.toString());
	    		}
	    		
	    		return JSONObjectBuilder.createObjFriendsBonusResult(setBonusFriends(user, countfriends), countfriends);
	    	}else if (mode == GameMode.MM){
	    		int countfriends = 0;
	    		
	    		String sigstr = "app_id=" + appID + "format=xmlmethod=friends.getAppUserssecure=1session_key=" + sessionKey + Config.protectedSecretMM();
	    		String sig = MD5.getMD5(sigstr);		 
				
				String urlstr = "http://www.appsmail.ru/platform/api?method=friends.getAppUsers&app_id=" +
				Config.appIdMM() + "&format=xml" +"&session_key=" + sessionKey + "&secure=1" + "&sig=" + sig;
				
				try{			 
					URL url = new URL(urlstr);
					
					HttpURLConnection urlConnection = (HttpURLConnection)url.openConnection();
					urlConnection.setDoInput(true);
					urlConnection.setDoOutput(true);
					urlConnection.setUseCaches(false);
					urlConnection.setRequestMethod("GET");
							         
					InputStream is = urlConnection.getInputStream();
					BufferedReader rd = new BufferedReader(new InputStreamReader(is));
					String line;
					StringBuffer response = new StringBuffer(); 
					while((line = rd.readLine()) != null) {
						response.append(line);
						response.append('\r');
					}
					rd.close();
					String answer = response.toString();			
					
					Document document = null;
			        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
			        factory.setValidating(false);
			        factory.setNamespaceAware(true);       
			        try
			        { 
						if(answer.indexOf("user") == -1) {
							//ServerMouseApplication.application.logger.log("BAD ANSWER BONUS: " + answer);
							answer = "bad answer";	
							 
							countfriends = 0;
						}else{
							InputStream istr = new ByteArrayInputStream(answer.getBytes());
							DocumentBuilder builder = factory.newDocumentBuilder();
							document = builder.parse(istr);
							document.getDocumentElement().normalize();
							NodeList nodelist = document.getDocumentElement().getElementsByTagName("user");
							
							countfriends = Math.min(10, nodelist.getLength());
							
				            istr.close();
				            istr = null;
				            builder = null;
				            nodelist = null;
						}
			        }
			        catch (Exception e){
			        	ServerApplication.application.logger.log("UM21 " + e.toString());        	
			        }
			         
			        factory = null;
			        document = null;
				
			        is.close();
			        is = null;
			        urlConnection = null;
				}catch(IOException e){
					ServerApplication.application.logger.log("UM22 " + e.toString());
				}
				
				return JSONObjectBuilder.createObjFriendsBonusResult(setBonusFriends(user, countfriends), countfriends);
	    	}
		}
		return JSONObjectBuilder.createObjFriendsBonusResult(0, 0);
	}
	
	private int setBonusFriends(UserConnection user, int countfriends){
		int friendsdelta = 0;
		
		Connection _sqlconnection = null;
		PreparedStatement find = null;
		ResultSet findRes = null;	
		PreparedStatement update = null;
		
		user.user.countSocialFriends = (byte) countfriends;
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			find = _sqlconnection.prepareStatement("SELECT * FROM user WHERE id=?");
			find.setInt(1, user.user.id);
			findRes = find.executeQuery();    		
			if(findRes.next()){
				int countfriendsDB = 0;
				countfriendsDB = findRes.getInt("countfriends");
				friendsdelta = Math.max(0, (countfriends - countfriendsDB));
				
				if(friendsdelta > 0){
					//ServerMouseApplication.application.logger.log("User id = " + user.user.id + " invite " + friendsdelta + " new friends. Bonus: " + (friendsdelta * Config.friendBonus()));
					
					user.user.updateMoney(user.user.money + friendsdelta * Config.friendBonus());
					ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY, user.user.money, 0);
    				
    				update = _sqlconnection.prepareStatement("UPDATE user SET countfriends=? WHERE id=?");
    				update.setInt(1, countfriends);
    				update.setInt(2, user.user.id);
    				update.executeUpdate();
				}
    		}
		} catch (SQLException e) {				
			ServerApplication.application.logger.error("UM23 " + e.toString());
		}
		finally
		{
		    try{
		    	if (find != null) find.close();
		    	if (findRes != null) findRes.close();		    	
		    	if (update != null) update.close();
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	find = null;
		    	findRes = null;
		    	update = null;
		    	_sqlconnection = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
		
		return friendsdelta;
	}
	
	public void setBonusNewLevel(int userID){
		UserConnection user = ServerApplication.application.commonroom.users.get(Integer.toString(userID));
		if(user != null){
			Connection _sqlconnection = null;
			PreparedStatement insertstatment = null;
			
			int prize = user.user.level * user.user.level * 8;
			user.user.updateMoney(user.user.money + prize);
			
			user.call(ProtocolValues.PROCESS_MESSAGE, JSONObjectBuilder.createObjMessageNewLevel(MessageType.NEW_LEVEL, 0, user.user.level, prize));
			
			if(user.user.inviter > 0){
				try {
					_sqlconnection = ServerApplication.application.sqlpool.getConnection();
					
					insertstatment = _sqlconnection.prepareStatement("INSERT INTO usersextractions (userid, type, money) VALUES(?,?,?)");
					insertstatment.setInt(1, user.user.inviter);
					insertstatment.setInt(2, MessageType.FRIEND_BONUS);
					insertstatment.setInt(3, user.user.level * user.user.level * 5);
					insertstatment.executeUpdate();
					
				}catch (SQLException e){
				}
				finally
				{
				    try{
				    	if (_sqlconnection != null) _sqlconnection.close();		    	
				    	if (insertstatment != null) insertstatment.close(); 
				    	
				    	_sqlconnection = null;
				    	insertstatment = null;
				    }
				    catch (SQLException sqlx) {		     
				    }
				}
			}
		}
	}
	
	public int getLevelByExperience(int exp){
		for(int i = 1; i <= levels.size(); i++){
			if (levels.get(new Integer(i)) >  exp){
				return (i - 1);
			}
		}
		return 1;
	}
	
	public void updateUser(User user){
		if(user != null){			
			Connection _sqlconnection = null;				
			PreparedStatement uppdate = null;
			PreparedStatement uppdateQuest = null;
			PreparedStatement uppdateCar = null;
			
			Date date = new Date();
			java.sql.Date sqlDate = new java.sql.Date(date.getTime());
			
			try {
				_sqlconnection = ServerApplication.application.sqlpool.getConnection();
				
				uppdate = _sqlconnection.prepareStatement("UPDATE user SET ip=?,experience=?,exphour=?,expday=?,money=?,moneyreal=?,clandepositm=?,clandeposite=?,getclanmoneyat=?,changebanat=?,popular=?,upddate=? WHERE id=?");
				uppdate.setString(1, user.ip);
				uppdate.setInt(2, user.experience);
				uppdate.setInt(3, user.exphour);
				uppdate.setInt(4, user.expday);
				uppdate.setInt(5, user.money);
				uppdate.setInt(6, user.moneyreal);
				uppdate.setInt(7, user.claninfo.clandepositm);
				uppdate.setInt(8, user.claninfo.clandeposite);
				uppdate.setInt(9, user.claninfo.getclanmoneyat);
				uppdate.setInt(10, user.changebanat);
				uppdate.setInt(11, user.popular);
				uppdate.setDate(12, sqlDate);
				uppdate.setInt(13, user.id);
				
				uppdate.executeUpdate();
				
				if(user.currentQuest != null && user.currentQuest.change){
					uppdateQuest = _sqlconnection.prepareStatement("UPDATE quests SET value=? WHERE uid=? AND qid=?");
					uppdateQuest.setInt(1, user.currentQuest.value);
					uppdateQuest.setInt(2, user.id);
					uppdateQuest.setInt(3, user.currentQuest.staticData.id);
					
					if(uppdateQuest.executeUpdate() > 0){
						user.currentQuest.change = false;
					}
				}
				
				user.updateRentCars();
				
				Set<Entry<Integer, CarModel>> set = user.cars.entrySet();
				for (Map.Entry<Integer, CarModel> car:set){
					if(car.getValue().changed){
						uppdateCar = _sqlconnection.prepareStatement("UPDATE cars SET color=?,durability=? WHERE id=?");
						uppdateCar.setInt(1, car.getValue().color);
						uppdateCar.setInt(2, car.getValue().durability);
						uppdateCar.setInt(3, car.getValue().id);
						
						if(uppdateCar.executeUpdate() > 0){
							car.getValue().changed = false;
						}
					}
				}			
				set = null;
			} catch (SQLException e) {
				ServerApplication.application.logger.error(e.toString());
			}
			finally
			{
			    try{
			    	if (_sqlconnection != null) _sqlconnection.close();		    	
			    	if (uppdate != null) uppdate.close(); 
			    	if (uppdateQuest != null) uppdateQuest.close();
			    	if (uppdateCar != null) uppdateCar.close(); 
			    	
			    	_sqlconnection = null;
			    	uppdate = null;
			    	uppdateQuest = null;
			    	uppdateCar = null;
			    }
			    catch (SQLException sqlx) {		     
			    }
			}
		}else{
			ServerApplication.application.logger.error("Null user Update");
		}
	}
	
	public int getOnlineTimeMoneyInfo(UserConnection initiator){
		if(initiator != null){
			Date date = new Date();
			int currenttime = (int)(date.getTime() / 1000);
			int starttime = ServerApplication.application.commonroom.userstimeonline.get(initiator.user.id);
			if(starttime > 0){
				int seconds = (currenttime - starttime);
				int minute = (int) Math.floor((float)seconds / 60);
				int money = (int) Math.floor((float) minute * 8 / 15);
				return money;
			}
		}
		return 0;
	}
	
	public void getOnlineTimeMoney(UserConnection initiator){		
		int money = getOnlineTimeMoneyInfo(initiator);
		if(money > 0){
			Date date = new Date();			
			int currenttime = (int)(date.getTime() / 1000);
			ServerApplication.application.commonroom.userstimeonline.remove(initiator.user.id);
			ServerApplication.application.commonroom.userstimeonline.put(initiator.user.id, currenttime);
			
			initiator.user.updateMoney(initiator.user.money + money);
			initiator.user.updatePopular(initiator.user.popular - (int)Math.ceil((float) money / 5));
			ServerApplication.application.commonroom.changeUserInfoByID(initiator.user.id, ChangeInfoParams.USER_MONEY_POPULAR, initiator.user.money, initiator.user.popular, 0);
		}
	}
	
	public void updateOptions(){
		Connection _sqlconnection = null;
		ResultSet selectRes = null;
		PreparedStatement select = null;
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();			
			select = _sqlconnection.prepareStatement("SELECT * FROM options");	
			
			selectRes = select.executeQuery();
			while(selectRes.next()){
				options.action = selectRes.getInt("action");
    		}
		} catch (SQLException e) {		
			ServerApplication.application.logger.error(" error updateOptions" + e.toString());
		}
		finally
		{
		    try{	    	
		    	if (select != null) select.close();		    	
		    	if (selectRes != null) selectRes.close();
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	select = null;
		    	selectRes = null;
		    	_sqlconnection = null;
		    }
		    catch (SQLException sqlx) {
		    }
		}
	}
	
	public int getDailyBonus(UserConnection initiator){
		int days = 0;
		int moneyBonus;
		if(initiator != null && initiator.user != null && initiator.connection != null && initiator.connection.isConnected()){
			if(initiator.user.sbdate == null){
				days = 1;

				updateUserBonusDate(initiator, true);
			}else{
				int second = 1000;
				int minute = 60 * second;
				int hour = 60 * minute;
				long day = 24 * hour;
				
				long dtime = initiator.user.upddate.getTime() - initiator.user.gbdate.getTime();
				if(dtime < day){
					days = 0;
				}else if(dtime >= 2 * day){
					days = 1;
					updateUserBonusDate(initiator, true);
				}else{
					dtime = initiator.user.upddate.getTime() - initiator.user.sbdate.getTime();
					
					if(dtime >= 4 * day){
						days = 5;
					}else if(dtime >= 3 * day){
						days = 4;
					}else if(dtime >= 2 * day){
						days = 3;
					}else if(dtime >= 1 * day){
						days = 2;
					}
					
					if(days == 5){
						updateUserBonusDate(initiator, true);
					}else{
						updateUserBonusDate(initiator, false);
					}
				}
			}
			
			moneyBonus = ((int) Math.ceil((double) ((double) initiator.user.level / 5) * 10) * days);
			initiator.user.updateMoney(initiator.user.money + moneyBonus);
			ServerApplication.application.commonroom.changeUserInfoByID(initiator.user.id, ChangeInfoParams.USER_MONEY, initiator.user.money, 0, 0);
		}
		return days;
	}
	
	private void updateUserBonusDate(UserConnection user, boolean resetStartDate){
		if(user != null){
			Connection _sqlconnection = null;				
			PreparedStatement uppdate = null;
			
			Date date = new Date();
			java.sql.Date sqlDate = new java.sql.Date(date.getTime());
			
			try {
				_sqlconnection = ServerApplication.application.sqlpool.getConnection();
				
				user.user.gbdate= date;
				if(resetStartDate){
					uppdate = _sqlconnection.prepareStatement("UPDATE user SET gbdate=?,sbdate=? WHERE id=?");
					uppdate.setDate(1, sqlDate);
					uppdate.setDate(2, sqlDate);
					uppdate.setInt(3, user.user.id);
					user.user.sbdate= date;
				}else{
					uppdate = _sqlconnection.prepareStatement("UPDATE user SET gbdate=? WHERE id=?");
					uppdate.setDate(1, sqlDate);
					uppdate.setInt(2, user.user.id);
				}
				
				uppdate.executeUpdate();
			} catch (SQLException e) {
				ServerApplication.application.logger.error(e.toString());
			}
			finally
			{
			    try{
			    	if (_sqlconnection != null) _sqlconnection.close();		    	
			    	if (uppdate != null) uppdate.close();
			    	
			    	_sqlconnection = null;
			    	uppdate = null;
			    }
			    catch (SQLException sqlx) {		     
			    }
			}
		}else{
			ServerApplication.application.logger.error("updateUserBonusDate error");
		}
	}
	
	public void addToCheaterList(UserConnection user, int code){
		if(user != null){
			if(cheaterList.get(user.user.id) == null){
				if(code != 2){
					cheaterList.put(user.user.id, user);
					ServerApplication.application.modsroom.sendSystemMessage(user.user.id + " " + user.user.title + " добавлен(а) в список возможных читеров. Код: " + code);
					ServerApplication.application.logger.log("ADD USER TO CHEATER LIST: " + user.user.id + " " + user.user.title + " code: " + code);
				}
			}
			try{
				user.connection.close();
			}catch(Throwable e){
			}
		}
	}
	
	public void blockCheater(SocketChannel connection, JSONObject params){
		int userID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
		UserConnection user = ServerApplication.application.commonroom.users.get(Integer.toString(userID));
    	if(user != null && user.connection.isConnected()){
    		try{
				user.connection.close();    			
			}catch(Throwable e){
			}
    	}    	
    	if(cheaterList.get(userID) != null){
    		Connection _sqlconnection = null;
    		PreparedStatement update = null;
    		
    		try {
    			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
    			
    			update = _sqlconnection.prepareStatement("UPDATE user SET role=-1 WHERE id=?");
    			update.setInt(1, userID);
    			update.executeUpdate();
    		} catch (SQLException e) {
    			ServerApplication.application.logger.error("blockCheater error " + e.toString());
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
    		    user = null;
    		}
    		
			cheaterList.remove(userID);
		}
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
	}
	
	public void removeFromCheaterList(SocketChannel connection, JSONObject params){
    	int userID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
		if(cheaterList.get(userID) != null){
			cheaterList.remove(userID);
		}
		
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
	}
	
	public void setSocialPostCount(SocketChannel connection, JSONObject params){
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		if(user != null){
		}
	}
	
	public void getOnlineUsers(SocketChannel connection, JSONObject params){
		String searchStr = JSONUtil.getString(params, ProtocolKeys.PARAM1);
		
		UserConnection initiator = ServerApplication.application.commonroom.getUserByConnection(connection);

		if(initiator != null && initiator.connection.isConnected() && searchStr != null && searchStr.length() > 0){
			List<ChatInfo> onlineUsers = new ArrayList<ChatInfo>();
			
			String userTitle = null;
			
			Set<Entry<String, UserConnection>> set = ServerApplication.application.commonroom.users.entrySet();
			for (Map.Entry<String, UserConnection> user:set){
				userTitle = user.getValue().user.title;
				if(userTitle.toLowerCase().indexOf(searchStr.toLowerCase()) != -1){
					if(onlineUsers.size() < 20){
						onlineUsers.add(ChatInfo.createFromUser(user.getValue().user));
					}else{
						break;
					}
				}
			}
			set = null;

			JSONObject jsonMessage = JSONObjectBuilder.createObjOnlineUsers(onlineUsers);
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), jsonMessage);
			
			onlineUsers = null;
			initiator = null;
		}
	}
	
	public void startChangeInfo(SocketChannel connection, JSONObject params){
    	String title = JSONUtil.getString(params, ProtocolKeys.PARAM1);
    	int sex = JSONUtil.getInt(params, ProtocolKeys.PARAM2);
    	
		UserConnection u = ServerApplication.application.commonroom.getUserByConnection(connection);
		
		ChangeResult result = new ChangeResult();
		if(u != null && u.connection != null && u.connection.isConnected() && u.user.level < 2 && u.user.sex == Sex.UNDEFINED){
			result = changeInfo(title, sex, connection, result, true);
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjChangeResult(result));
		}
		result = null;
    }
	
	public void setActiveCar(SocketChannel connection, JSONObject params){
		int carID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
		
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		
		if(user != null && user.connection != null){
			CarModel userCar = user.user.cars.get(carID);
			if(userCar != null){
				user.user.activeCar = userCar;
			}
		}
	}
}
