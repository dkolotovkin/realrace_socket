package app.shop;

import java.nio.channels.SocketChannel;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import app.Config;
import app.ServerApplication;
import app.logger.MyLogger;
import app.shop.buyMoneyResult.BuyMoneyErrorCode;
import app.shop.buyMoneyResult.BuyMoneyResult;
import app.shop.buyresult.BuyErrorCode;
import app.shop.buyresult.BuyResult;
import app.shop.car.CarModel;
import app.shop.car.CarPrototypeModel;
import app.shop.car.CarsModel;
import app.shop.item.ItemPresent;
import app.shop.item.ItemType;
import app.shop.itemprototype.ItemPrototype;
import app.shop.useresult.UseErrorCode;
import app.shop.useresult.UseResult;
import app.user.UserConnection;
import app.user.UserLoginMode;
import app.user.UserRole;
import app.user.VipType;
import app.utils.ban.BanType;
import app.utils.changeinfo.ChangeInfoParams;
import app.utils.jsonobjectbuilder.JSONObjectBuilder;
import app.utils.jsonutil.JSONUtil;
import app.utils.protocol.ProtocolKeys;
import app.utils.protocol.ProtocolValues;
import app.utils.sort.SortPresents;
import atg.taglib.json.util.JSONObject;

public class ShopManager{
	public MyLogger logger = new MyLogger(Config.logPath(), ShopManager.class.getName());
	
	public Map<Integer, ItemPrototype> itemprototypes = new HashMap<Integer, ItemPrototype>();
	public CarsModel carsModel;
	
	public ShopManager(){
		initializeItemPrototypes();
		carsModel = new CarsModel();
	}
	
	public void initializeItemPrototypes(){		
		Connection _sqlconnection = null;
		PreparedStatement select = null;
		ResultSet selectRes = null;
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			select = _sqlconnection.prepareStatement("SELECT * FROM itemprototype");
			
			ItemPrototype item;
			selectRes = select.executeQuery();
			while(selectRes.next()){
    			item = new ItemPrototype(selectRes.getInt("id"), selectRes.getString("title"), selectRes.getString("description"), selectRes.getInt("count"), selectRes.getInt("price"), selectRes.getInt("pricereal"), selectRes.getInt("showed"));
    			itemprototypes.put(item.id, item);
    		}
		} catch (SQLException e) {
			logger.error("SM1" + e.toString());
		}
		finally
		{
		    try{
		    	if (_sqlconnection != null) _sqlconnection.close();
		    	if (select != null) select.close();
		    	if (selectRes != null) selectRes.close();
		    	_sqlconnection = null;
		    	select = null;
		    	selectRes = null;
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
	}
	
	public void shopGetItemPrototypes(UserConnection user, JSONObject params){
		ArrayList<ItemPrototype> items = new ArrayList<ItemPrototype>();
		Set<Entry<Integer, ItemPrototype>> set = itemprototypes.entrySet();
		for (Map.Entry<Integer, ItemPrototype> item:set){
			items.add(item.getValue());
		}
		set = null;
		
		Collections.sort(items, new SortPresents());
		
		ArrayList<ItemPrototype> temp = new ArrayList<ItemPrototype>();
		for(int i = 0; i < items.size(); i++){
			temp.add(items.get(i));
			if(temp.size() >= 100){
				user.call(ProtocolValues.PROCESS_PROTOTYPES, ProtocolKeys.PROTOTYPES, 
						JSONObjectBuilder.createObjItemPrototypes(temp));
				temp = new ArrayList<ItemPrototype>();
			}
		}
		if(temp.size() > 0){
			user.call(ProtocolValues.PROCESS_PROTOTYPES, ProtocolKeys.PROTOTYPES, 
					JSONObjectBuilder.createObjItemPrototypes(temp));
			temp = new ArrayList<ItemPrototype>();
		}
		
		ServerApplication.application.sendResult(user.connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
	}	
	
	public void shopGetUserItems(SocketChannel connection, JSONObject params){
    	int offset = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	
		ArrayList<ItemPresent> items = new ArrayList<ItemPresent>();
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		Connection _sqlconnection = null;
		PreparedStatement select = null;
		ResultSet selectRes = null;
		
		if(user != null){
			try {
				_sqlconnection = ServerApplication.application.sqlpool.getConnection();
				select = _sqlconnection.prepareStatement("SELECT * FROM usersitems INNER JOIN itemprototype ON usersitems.idprototype=itemprototype.id AND usersitems.iduser=? INNER JOIN user ON usersitems.idpresenter=user.id LIMIT 50 OFFSET ?");
				select.setInt(1, user.user.id);
				select.setInt(2, offset);
				selectRes = select.executeQuery(); 		
				while(selectRes.next()){
	    			ItemPresent item = new ItemPresent(selectRes.getInt("usersitems.id"), selectRes.getInt("itemprototype.id"), selectRes.getInt("itemprototype.price"), selectRes.getInt("itemprototype.pricereal"), selectRes.getString("itemprototype.title"), selectRes.getString("itemprototype.description"), selectRes.getInt("usersitems.count"), selectRes.getString("user.title"));
	    			items.add(item);
	    		}
				user.call(ProtocolValues.PROCESS_USER_PRESENTS, ProtocolKeys.ITEMS, 
						JSONObjectBuilder.createObjItemsPresent(items));
			} catch (SQLException e) {
				logger.error("SM3" + e.toString());
			}
			finally
			{
			    try{
			    	if (_sqlconnection != null) _sqlconnection.close(); 
			    	if (select != null) select.close(); 
			    	if (selectRes != null) selectRes.close();
			    	_sqlconnection = null;
			    	select = null;
			    	selectRes = null;
			    }
			    catch (SQLException sqlx) {		     
			    }
			}			
		}
		
		user = null;
	}
	
	public void shopGetUserPresentsPrice(SocketChannel connection, JSONObject params){
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		int price = 0;
		if(user != null){
			price = getUserPresentsPrice(user);
		}
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), price);
	}
	
	public int getUserPresentsPrice(UserConnection user){
    	
		Connection _sqlconnection = null;
		PreparedStatement select = null;
		ResultSet selectRes = null;
		
		int money = 0;
		
		if(user != null){
			try {
				_sqlconnection = ServerApplication.application.sqlpool.getConnection();
				select = _sqlconnection.prepareStatement("SELECT * FROM usersitems INNER JOIN itemprototype ON usersitems.idprototype=itemprototype.id AND usersitems.iduser=? INNER JOIN user ON usersitems.idpresenter=user.id");
				select.setInt(1, user.user.id);
				selectRes = select.executeQuery(); 		
				
				int price = 0;
				while(selectRes.next()){
	    			ItemPresent item = new ItemPresent(selectRes.getInt("usersitems.id"), selectRes.getInt("itemprototype.id"), selectRes.getInt("itemprototype.price"), selectRes.getInt("itemprototype.pricereal"), selectRes.getString("itemprototype.title"), selectRes.getString("itemprototype.description"), selectRes.getInt("usersitems.count"), selectRes.getString("user.title"));
	    			
	    			price = (int)Math.floor((float)item.price * 0.3);					
					if(item.pricereal > 0){
						price = (int)Math.floor((float)item.pricereal * 10 * 0.3);
					}
					money += price;
	    		}
			} catch (SQLException e) {
				logger.error("SM3" + e.toString());
			}
			finally
			{
			    try{
			    	if (_sqlconnection != null) _sqlconnection.close(); 
			    	if (select != null) select.close(); 
			    	if (selectRes != null) selectRes.close();
			    	_sqlconnection = null;
			    	select = null;
			    	selectRes = null;
			    }
			    catch (SQLException sqlx) {		     
			    }
			}			
			user = null;
		}
		
		return money;
	}
	
	public void shopBuyPresent(SocketChannel connection, JSONObject params){
    	int ipid = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
    	int userid = JSONUtil.getInt(params, ProtocolKeys.PARAM2);
	
		BuyResult buyresult = new BuyResult();
		
		Connection _sqlconnection = null;		
		PreparedStatement insertitem = null;		
		
		try {
			_sqlconnection = ServerApplication.application.sqlpool.getConnection();
			ItemPrototype prototype = itemprototypes.get(ipid);
			
			if(prototype != null){   			
    			UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
    			if(user != null && user.connection.isConnected()){
	    			if ((prototype.pricereal <= 0 && prototype.price > 0 && user.user.money >= prototype.price) || (prototype.pricereal > 0 && user.user.moneyreal >= prototype.pricereal)){    				
	    				insertitem = _sqlconnection.prepareStatement("INSERT INTO usersitems (iduser, idpresenter, idprototype, count) VALUES(?,?,?,?)");
		    			insertitem.setInt(1, userid);
		    			insertitem.setInt(2, user.user.id);
		    			insertitem.setInt(3, prototype.id);
		    			insertitem.setInt(4, prototype.count);
		    			if (insertitem.executeUpdate() > 0){
		    			}else{
		    				buyresult.error = BuyErrorCode.OTHER;
		    				//return BuyResult
		    				ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
		    				return;
		    			}
		    			
		    			int popularBonus = 0;
		    			if(prototype.pricereal > 0){
		    				user.user.updateMoneyReal(user.user.moneyreal - prototype.pricereal);
		    				popularBonus = prototype.pricereal * 2;
		    			}else{
		    				user.user.updateMoney(user.user.money - prototype.price);
		    				popularBonus = (int) Math.floor((double) prototype.price / 10);
		    			}
		    			
		    			if(user.user.vip == VipType.VIP_BRONZE){
	    					popularBonus += (int) ((double) popularBonus * 0.1);
	    				}else if(user.user.vip == VipType.VIP_SILVER){
	    					popularBonus += (int) ((double) popularBonus * 0.2);
	    				}else if(user.user.vip == VipType.VIP_GOLD){
	    					popularBonus += (int) ((double) popularBonus * 0.3);
	    				}
		    			user.user.updatePopular(user.user.popular + popularBonus);
	    					    				
	    				ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_MONEYREAL_POPULAR, user.user.money, user.user.moneyreal, user.user.popular);	    				
	    				ServerApplication.application.commonroom.sendMessagePresent(prototype.id, prototype.price, prototype.pricereal, user.connection, Integer.toString(userid));
	    				
	    				buyresult.itemprototype = prototype;
	    				buyresult.error = BuyErrorCode.OK;
	    				
	    				prototype = null;
	    				user = null;
	    			}else{
	    				buyresult.error = BuyErrorCode.NOT_ENOUGH_MONEY;
	    			}
    			}else{
    				buyresult.error = BuyErrorCode.OTHER;
    				//return BuyResult
    				ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
    				return;
    			}
    		}else{
    			buyresult.error = BuyErrorCode.NOT_PROTOTYPE;
    		}		
		} catch (SQLException e) {
			buyresult.error = BuyErrorCode.SQL_ERROR;
			logger.error("SM4" + e.toString());
		}
		finally
		{
		    try{		    	
		    	if (insertitem != null) insertitem.close();		    	
		    	if (_sqlconnection != null) _sqlconnection.close();	    
		    	insertitem = null;		    	
		    	_sqlconnection = null;	    			    	
		    }
		    catch (SQLException sqlx) {		     
		    }
		}
		//return BuyResult
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
		return;
	}
	
	public void shopSaleAllPresents(SocketChannel connection, JSONObject params){
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		if(user != null){
			int price = getUserPresentsPrice(user);			
			if(price > 0){				
				Connection _sqlconnection = null;				
				PreparedStatement deleteitem = null;
				
				try {
					_sqlconnection = ServerApplication.application.sqlpool.getConnection();
					deleteitem = _sqlconnection.prepareStatement("DELETE FROM usersitems WHERE iduser=?");
					deleteitem.setInt(1, user.user.id);
	        		if (deleteitem.executeUpdate() > 0){
	        			user.user.updateMoney(user.user.money + price);
	    				ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY, user.user.money, 0);
	        		}
				}catch (SQLException e) {
					logger.error("SM5" + e.toString());
				}
				finally
				{
				    try{
				    	if (_sqlconnection != null) _sqlconnection.close();   	
				    	if (deleteitem != null) deleteitem.close();
				    	_sqlconnection = null;    	
				    	deleteitem = null;
				    }
				    catch (SQLException sqlx) {		     
				    }
				    user = null;
				}
			}
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), true);
		}else{
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), false);
		}
	}
	
	public void shopSaleItem(SocketChannel connection, JSONObject params){
    	int itemid = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
	
		Boolean sqlok = false;
		UseResult result = new UseResult();
		result.itemid = itemid;		
		
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		if(user != null && user.connection.isConnected()){		
			Connection _sqlconnection = null;
			PreparedStatement finditem = null;
			ResultSet finditemRes = null;
			PreparedStatement deleteitem = null;
			PreparedStatement updatemoney = null;
			
			try {
				_sqlconnection = ServerApplication.application.sqlpool.getConnection();
				finditem = _sqlconnection.prepareStatement("SELECT * FROM usersitems WHERE id=? AND iduser=?");    				
				finditem.setInt(1, itemid);
				finditem.setInt(2, user.user.id);
				finditemRes = finditem.executeQuery(); 		
				if(finditemRes.next()){
					deleteitem = _sqlconnection.prepareStatement("DELETE FROM usersitems WHERE id=?");
					deleteitem.setInt(1, itemid);			
	        		if (deleteitem.executeUpdate() > 0){
	        			sqlok = true;
	        			result.count = 0;
	        		}else{        			
	        			result.error = UseErrorCode.ERROR;
	        		}   
					
					if (sqlok){
						ItemPrototype prototype = itemprototypes.get(finditemRes.getInt("idprototype"));						
						if(prototype != null){
							int price = (int)Math.floor((float)prototype.price * 0.3);
							
							if(prototype.pricereal > 0){
								price = (int)Math.floor((float)prototype.pricereal * 10 * 0.3);
							}
							
							user.user.updateMoney(user.user.money + price);
							ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_MONEYREAL, user.user.money, user.user.moneyreal);
		    				
		            		result.error = UseErrorCode.GAMEACTION_OK;
						}
					}
	    		}else{
	    			result.error = UseErrorCode.ERROR;
	    		}			
			} catch (SQLException e) {
				logger.error("SM5" + e.toString());
			}
			finally
			{
			    try{
			    	if (_sqlconnection != null) _sqlconnection.close(); 
			    	if (finditem != null) finditem.close(); 
			    	if (finditemRes != null) finditemRes.close();		    	
			    	if (deleteitem != null) deleteitem.close();	 
			    	if (updatemoney != null) updatemoney.close();
			    	_sqlconnection = null;
			    	finditem = null;
			    	finditemRes = null;		    	
			    	deleteitem = null;
			    	updatemoney = null;
			    }
			    catch (SQLException sqlx) {		     
			    }
			    user = null;
			}
		}
		
		//return UseResult
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjUseResult(result));
		return;
	}

	public void shopExchangeMoney(SocketChannel connection, JSONObject params){
    	int moneyreal = JSONUtil.getInt(params, ProtocolKeys.PARAM1);

		BuyMoneyResult result = new BuyMoneyResult();	
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		
		if(user != null && user.connection.isConnected()){		
			if (user.user.moneyreal >= moneyreal && user.user.moneyreal > 0 && moneyreal > 0){
				
				user.user.updateMoney(user.user.money + moneyreal * Config.exchangeMoneyK());
				user.user.updateMoneyReal(user.user.moneyreal - moneyreal);
				
				result.money = user.user.money;
				result.moneyreal = user.user.moneyreal;
    			result.error = BuyMoneyErrorCode.OK;
			}else{
				result.error = BuyMoneyErrorCode.NOT_ENOUGH_MONEY;
			}
		}else{
			result.error = BuyMoneyErrorCode.ERROR;
			//return BuyMoneyResult
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyMoneyResult(result));
			return;
		}
		user = null;
		//return BuyMoneyResult
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyMoneyResult(result));
		return;
	}
	
	public void shopBuyLink(SocketChannel connection, JSONObject params){
		BuyResult result = new BuyResult();	
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);		
		
		boolean needbuy = true;
		if (UserRole.isAdministrator(user.user.role) || UserRole.isAdministratorMain(user.user.role) || UserRole.isModerator(user.user.role) || (user.user.loginMode == UserLoginMode.SITE)){
			needbuy = false;
		}
		
		if(user != null && user.connection.isConnected()){
		
			if (user.user.money >= Config.showLinkPrice() || !needbuy){
				if(needbuy){
					user.user.updateMoney(user.user.money - Config.showLinkPrice());
					ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY, user.user.money, 0);
				}    			
    			result.error = BuyErrorCode.OK;
			}else{
				result.error = BuyErrorCode.NOT_ENOUGH_MONEY;
			}
		}else{
			result.error = BuyErrorCode.OTHER;
			//return BuyResult
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(result));
			return;
		}
		user = null;		
		//return BuyResult
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(result));
		return;
	}
	
	public void shopGetPriceBanOff(SocketChannel connection, JSONObject params){
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		
		int allduration = 0;
		if (BanType.by5Minut(user.user.bantype)){
			allduration = 5 * 60;
		}else if (BanType.by15Minut(user.user.bantype)){
			allduration = 15 * 60;
		}else if (BanType.by30Minut(user.user.bantype)){
			allduration = 30 * 60;
		}else if (BanType.byHour(user.user.bantype)){
			allduration = 60 * 60;
		}else if (BanType.byDay(user.user.bantype)){
			allduration = 60 * 60 * 24;
		}else if (BanType.byWeek(user.user.bantype)){
			allduration = 60 * 60 * 24 * 7;
		}
		
		int price = (int) Math.ceil((float)(Math.max(0, user.user.setbanat + allduration - user.user.changebanat)) / 60) * Config.banminutePrice();
		
		if(UserRole.isAdministrator(user.user.role) || UserRole.isModerator(user.user.role)){
			if(!BanType.byDay(user.user.bantype) && !BanType.byWeek(user.user.bantype)){
				price = price / 10;
			}
		}
		
		user = null;		
		//return int
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), price);
		return;
	}
	
	public void shopBuyBanOff(SocketChannel connection, JSONObject params){
		BuyResult result = new BuyResult();	
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		
		if(user != null && user.connection.isConnected()){
			int allduration = 0;
			if (BanType.by5Minut(user.user.bantype)){
				allduration = 5 * 60;
			}else if (BanType.by15Minut(user.user.bantype)){
				allduration = 15 * 60;
			}else if (BanType.by30Minut(user.user.bantype)){
				allduration = 30 * 60;
			}else if (BanType.byHour(user.user.bantype)){
				allduration = 60 * 60;
			}else if (BanType.byDay(user.user.bantype)){
				allduration = 60 * 60 * 24;
			}else if (BanType.byWeek(user.user.bantype)){
				allduration = 60 * 60 * 24 * 7;
			}else{
				return;
			}
			
			int price = (int) Math.ceil((float)(Math.max(0, user.user.setbanat + allduration - user.user.changebanat)) / 60) * Config.banminutePrice();
			
			if(UserRole.isAdministrator(user.user.role) || UserRole.isModerator(user.user.role)){
				if(!BanType.byDay(user.user.bantype) && !BanType.byWeek(user.user.bantype)){
					price = price / 10;
				}
			}
			
			if (UserRole.isAdministratorMain(user.user.role)){
				price = 0;
			}
			
			if (user.user.money >= price){
				user.user.updateMoney(user.user.money - Math.abs(price));
				
				ServerApplication.application.userinfomanager.banoff(user.user.id, user.user.ip);
    			result.error = BuyErrorCode.OK;
    			
    			user.user.bantype = BanType.NO_BAN;
				
				ServerApplication.application.commonroom.sendBanOutMessage(user.user.id);
    			ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_BANTYPE, user.user.money, user.user.bantype);
			}else{
				result.error = BuyErrorCode.NOT_ENOUGH_MONEY;
			}
		}else{
			result.error = BuyErrorCode.OTHER;
			//return BuyResult
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(result));
			return;
		}
		user = null;
		
		//return BuyResult
		ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(result));
		return;
	}
	
	public void shopBuyVipStatus(SocketChannel connection, JSONObject params){
		int prototypeID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
		
		BuyResult buyresult = new BuyResult();
		
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		if(user != null && user.connection.isConnected()){
			int price = 0;
			int priceReal = 0;
			int itemPrototypeId = 0;
			if(prototypeID == VipType.VIP_BRONZE){
				price = 2000;
				itemPrototypeId = ItemType.VIP_BRONZE;
			}else if(prototypeID == VipType.VIP_SILVER){
				price = 5000;
				itemPrototypeId = ItemType.VIP_SILVER;
			}else if(prototypeID == VipType.VIP_GOLD){
				priceReal = 300;
				itemPrototypeId = ItemType.VIP_GOLD;
			}
			
			if ((priceReal <= 0 && price > 0 && user.user.money >= price) || 
				(priceReal > 0 && user.user.moneyreal >= priceReal)){
				user.user.updateVip(prototypeID);
				
				if(priceReal > 0){
    				user.user.updateMoneyReal(user.user.moneyreal - priceReal);
    				user.user.updatePopular(user.user.popular + priceReal * 2);
    			}else{
    				user.user.updateMoney(user.user.money - price);
    				user.user.updatePopular(user.user.popular + (int) Math.floor((double) price / 10));
    			}
				ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_MONEYREAL_POPULAR, user.user.money, user.user.moneyreal, user.user.popular);
				
				buyresult.itemprototype = new ItemPrototype(itemPrototypeId, "", "", 1, 0, 0, 1);
				buyresult.error = BuyErrorCode.OK;
			}else{
				buyresult.error = BuyErrorCode.NOT_ENOUGH_MONEY;
			}
			user = null;
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
		}
	}
	
	public void shopBuyCar(SocketChannel connection, JSONObject params){
		int prototypeID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
		
		Connection sqlconnection = null;
		PreparedStatement findCar = null;
		ResultSet findCarRes = null;
		PreparedStatement insertCar = null;
		
		BuyResult buyresult = new BuyResult();	
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		
		if(user != null && user.connection.isConnected()){
			user.user.updateRentCars();
			
			CarPrototypeModel carPrototype = carsModel.getCarPrototypeById(prototypeID);
			if(carPrototype != null){
				if(carPrototype.minLevel <= user.user.level){
					if ((carPrototype.priceReal <= 0 && carPrototype.price > 0 && user.user.money >= carPrototype.price) || 
						(carPrototype.priceReal > 0 && user.user.moneyreal >= carPrototype.priceReal)){
						
						try{
							sqlconnection = ServerApplication.application.sqlpool.getConnection();
							findCar = sqlconnection.prepareStatement("SELECT * FROM cars WHERE pid=? AND uid=?");    				
							findCar.setInt(1, carPrototype.id);
							findCar.setInt(2, user.user.id);
							findCarRes = findCar.executeQuery(); 		
							if(findCarRes.next()){
								buyresult.error = BuyErrorCode.EXIST;
							}else{
								insertCar = sqlconnection.prepareStatement("INSERT INTO cars (uid, pid, color, durability) VALUES(?,?,?,?)");
								insertCar.setInt(1, user.user.id);
								insertCar.setInt(2, carPrototype.id);
								insertCar.setInt(3, 0xFFFFFF);
								insertCar.setInt(4, 100);
				    			if (insertCar.executeUpdate() > 0){
				    				findCar = sqlconnection.prepareStatement("SELECT * FROM cars WHERE pid=? AND uid=?");    				
									findCar.setInt(1, carPrototype.id);
									findCar.setInt(2, user.user.id);
									findCarRes = findCar.executeQuery(); 		
									if(findCarRes.next()){
										CarModel car = new CarModel();
										car.id = findCarRes.getInt("id");
										car.color = findCarRes.getInt("color");
										car.durability = findCarRes.getInt("durability");
										car.prototype = carPrototype;
										
										user.user.cars.put(car.id, car);
										
										buyresult.car = car;
										buyresult.error = BuyErrorCode.OK;
									}
				    			}else{
				    				buyresult.error = BuyErrorCode.OTHER;
				    				ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
				    				return;
				    			}
				    			
				    			double k = 1;
				    			if(user.user.vip == VipType.VIP_BRONZE){
			    					k = 1.1;
			    				}else if(user.user.vip == VipType.VIP_SILVER){
			    					k = 1.2;
			    				}else if(user.user.vip == VipType.VIP_GOLD){
			    					k = 1.3;
			    				}
				    			
				    			if(carPrototype.priceReal > 0){
				    				user.user.updateMoneyReal(user.user.moneyreal - carPrototype.priceReal);
				    				user.user.updatePopular(user.user.popular + (int) Math.floor((double) k * carPrototype.priceReal * 2));
				    			}else{
				    				user.user.updateMoney(user.user.money - carPrototype.price);
				    				user.user.updatePopular(user.user.popular + (int) Math.floor((double) k * carPrototype.price / 10));
				    			}
			    				ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_MONEYREAL_POPULAR, user.user.money, user.user.moneyreal, user.user.popular);
							}
						}catch (SQLException e) {
							logger.error("shopBuyCar error: " + e.toString());
						}
						finally
						{
						    try{
						    	if (sqlconnection != null) sqlconnection.close(); 
						    	if (findCar != null) findCar.close(); 
						    	if (findCarRes != null) findCarRes.close();
						    	if (insertCar != null) insertCar.close();
						    	sqlconnection = null;
						    	findCar = null;
						    	findCarRes = null;
						    	insertCar = null;
						    }
						    catch (SQLException sqlx) {		     
						    }
						}
					}else{
						buyresult.error = BuyErrorCode.NOT_ENOUGH_MONEY;
					}
				}else{
					buyresult.error = BuyErrorCode.LOW_LEVEL;
				}
				carPrototype = null;
			}
			user = null;
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
		}
	}
	
	public void shopBuyCarColor(SocketChannel connection, JSONObject params){
		int carID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
		int color = JSONUtil.getInt(params, ProtocolKeys.PARAM2);
		int priceReal = 100;
		
		BuyResult buyresult = new BuyResult();	
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		if(user != null && user.connection.isConnected()){
			CarModel car = user.user.cars.get(carID);
			if(car != null){
				priceReal = 100 * car.prototype.carClass;
				
				if (user.user.moneyreal >= priceReal){
					car.color = color;
					car.changed = true;
					
					int popularBonus = priceReal * 2;
	    			if(user.user.vip == VipType.VIP_BRONZE){
    					popularBonus += (int) ((double) popularBonus * 0.1);
    				}else if(user.user.vip == VipType.VIP_SILVER){
    					popularBonus += (int) ((double) popularBonus * 0.2);
    				}else if(user.user.vip == VipType.VIP_GOLD){
    					popularBonus += (int) ((double) popularBonus * 0.3);
    				}
	    			user.user.updateMoneyReal(user.user.moneyreal - priceReal);
	    			user.user.updatePopular(user.user.popular + popularBonus);
    					    				
    				ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_MONEYREAL_POPULAR, user.user.money, user.user.moneyreal, user.user.popular);
					
					buyresult.error = BuyErrorCode.OK;
					buyresult.car = car;
					
				}else{
					buyresult.error = BuyErrorCode.NOT_ENOUGH_MONEY;
				}
			}else{
				buyresult.error = BuyErrorCode.OTHER;
			}
			user = null;
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
		}
	}
	
	public void shopRentCar(SocketChannel connection, JSONObject params){
		int prototypeID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
		int color = JSONUtil.getInt(params, ProtocolKeys.PARAM2);
		
		Connection sqlconnection = null;
		PreparedStatement findCar = null;
		ResultSet findCarRes = null;
		PreparedStatement insertCar = null;
		
		BuyResult buyresult = new BuyResult();	
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		
		if(user != null && user.connection.isConnected()){
			user.user.updateRentCars();
			
			CarPrototypeModel carPrototype = carsModel.getCarPrototypeById(prototypeID);
			if(carPrototype != null){
				if(carPrototype.minLevel <= user.user.level){
					if (carPrototype.rentPriceReal > 0 && user.user.moneyreal >= carPrototype.rentPriceReal){
						try{
							sqlconnection = ServerApplication.application.sqlpool.getConnection();
							findCar = sqlconnection.prepareStatement("SELECT * FROM cars WHERE pid=? AND uid=?");    				
							findCar.setInt(1, carPrototype.id);
							findCar.setInt(2, user.user.id);
							findCarRes = findCar.executeQuery(); 		
							if(findCarRes.next()){
								buyresult.error = BuyErrorCode.EXIST;
							}else{
								Date date = new Date();
								int currenttime = (int)(date.getTime() / 1000);
								date = null;
								
								insertCar = sqlconnection.prepareStatement("INSERT INTO cars (uid, pid, color, durability, rented, renttime) VALUES(?,?,?,?,?,?)");
								insertCar.setInt(1, user.user.id);
								insertCar.setInt(2, carPrototype.id);
								insertCar.setInt(3, color);
								insertCar.setInt(4, 100);
								insertCar.setInt(5, 1);
								insertCar.setInt(6, currenttime);
				    			if (insertCar.executeUpdate() > 0){
				    				findCar = sqlconnection.prepareStatement("SELECT * FROM cars WHERE pid=? AND uid=?");    				
									findCar.setInt(1, carPrototype.id);
									findCar.setInt(2, user.user.id);
									findCarRes = findCar.executeQuery(); 		
									if(findCarRes.next()){
										CarModel car = new CarModel();
										car.id = findCarRes.getInt("id");
										car.color = findCarRes.getInt("color");
										car.durability = findCarRes.getInt("durability");
										car.prototype = carPrototype;
										car.rented = findCarRes.getInt("rented");
										car.rentTime = findCarRes.getInt("renttime");
										
										user.user.cars.put(car.id, car);
										
										buyresult.car = car;
										buyresult.error = BuyErrorCode.OK;
									}
				    			}else{
				    				buyresult.error = BuyErrorCode.OTHER;
				    				ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
				    				return;
				    			}
				    			
				    			double k = 1;
				    			if(user.user.vip == VipType.VIP_BRONZE){
			    					k = 1.1;
			    				}else if(user.user.vip == VipType.VIP_SILVER){
			    					k = 1.2;
			    				}else if(user.user.vip == VipType.VIP_GOLD){
			    					k = 1.3;
			    				}
				    			
				    			if(carPrototype.rentPriceReal > 0){
				    				user.user.updateMoneyReal(user.user.moneyreal - carPrototype.rentPriceReal);
				    				user.user.updatePopular(user.user.popular + (int) Math.floor((double) k * carPrototype.rentPriceReal * 2));
				    			}
			    				ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_MONEYREAL_POPULAR, user.user.money, user.user.moneyreal, user.user.popular);
							}
						}catch (SQLException e) {
							logger.error("shopBuyCar error: " + e.toString());
						}
						finally
						{
						    try{
						    	if (sqlconnection != null) sqlconnection.close(); 
						    	if (findCar != null) findCar.close(); 
						    	if (findCarRes != null) findCarRes.close();
						    	if (insertCar != null) insertCar.close();
						    	sqlconnection = null;
						    	findCar = null;
						    	findCarRes = null;
						    	insertCar = null;
						    }
						    catch (SQLException sqlx) {		     
						    }
						}
					}else{
						buyresult.error = BuyErrorCode.NOT_ENOUGH_MONEY;
					}
				}else{
					buyresult.error = BuyErrorCode.LOW_LEVEL;
				}
				carPrototype = null;
			}
			user = null;
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
		}
	}
	
	public void shopRepairCar(SocketChannel connection, JSONObject params){
		int carID = JSONUtil.getInt(params, ProtocolKeys.PARAM1);
		boolean byReal = JSONUtil.getBoolean(params, ProtocolKeys.PARAM2);
		
		BuyResult buyresult = new BuyResult();	
		UserConnection user = ServerApplication.application.commonroom.getUserByConnection(connection);
		if(user != null && user.connection.isConnected()){
			CarModel car = user.user.cars.get(carID);
			if(car != null){
				if(car.durability < car.durabilityMax){
					int carPrice = car.prototype.price;
					if(car.prototype.priceReal > 0){
						carPrice = car.prototype.priceReal * 10;
					}
					double kFromCarPrice = 0.02;
					int repairPrice = (int) Math.ceil((double) carPrice * kFromCarPrice);
					int repairPriceReal = (int) Math.ceil((double) carPrice * kFromCarPrice * 0.1 * 0.5);
					
					if(!byReal && user.user.money >= repairPrice || byReal && user.user.moneyreal >= repairPriceReal){
						car.durability = car.durabilityMax;
						car.changed = true;
						
						if(byReal){
							user.user.updateMoneyReal(user.user.moneyreal - repairPriceReal);
						}else{
							user.user.updateMoney(user.user.money - repairPrice);
						}
						ServerApplication.application.commonroom.changeUserInfoByID(user.user.id, ChangeInfoParams.USER_MONEY_MONEYREAL, user.user.money, user.user.moneyreal);
						
						buyresult.error = BuyErrorCode.OK;
					}else{
						buyresult.error = BuyErrorCode.NOT_ENOUGH_MONEY;
					}
				}else{
					buyresult.error = BuyErrorCode.NOTHING;
				}
			}else{
				buyresult.error = BuyErrorCode.OTHER;
			}
			
			user = null;
			ServerApplication.application.sendResult(connection, JSONUtil.getInt(params, ProtocolKeys.CALLBACKID), JSONObjectBuilder.createObjBuyResult(buyresult));
		}
	}
}