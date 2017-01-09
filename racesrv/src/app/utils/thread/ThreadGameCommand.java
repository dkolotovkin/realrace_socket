package app.utils.thread;

import java.nio.channels.SocketChannel;

import app.utils.protocol.ProtocolValues;
import app.ServerApplication;
import atg.taglib.json.util.JSONObject;

public class ThreadGameCommand implements Runnable{
	public int command = 0;
	public SocketChannel connection;
	public JSONObject params;
	
	public ThreadGameCommand(int command, SocketChannel connection, JSONObject params){
		this.command = command;
		this.connection = connection;
		this.params = params;
	}
	
	public void run(){
		if(connection != null && connection.isConnected()){
			if(command == ProtocolValues.GAME_GO_TO_LEFT){
				ServerApplication.application.gamemanager.gameLeft(connection, params);
			}else if(command == ProtocolValues.GAME_GO_TO_RIGHT){
				ServerApplication.application.gamemanager.gameRight(connection, params);
			}else if(command == ProtocolValues.GAME_FORWARD){
				ServerApplication.application.gamemanager.gameForward(connection, params);
			}else if(command == ProtocolValues.GAME_BACK){
				ServerApplication.application.gamemanager.gameBack(connection, params);
			}else if(command == ProtocolValues.GAME_BRAKE){
				ServerApplication.application.gamemanager.gameBrake(connection, params);
			}else if(command == ProtocolValues.GAME_GET_BET_GAMES_INFO){
				ServerApplication.application.gamemanager.gameGetBetGamesInfo(connection, params);
			}else if(command == ProtocolValues.GAME_CREATE_BET_GAME){
				ServerApplication.application.gamemanager.gameCreateBetGame(connection, params);
			}else if(command == ProtocolValues.GAME_ADD_TO_BET_GAME){
				ServerApplication.application.gamemanager.gameAddToBetGame(connection, params);
			}else if(command == ProtocolValues.GAME_START_REQUEST){
				ServerApplication.application.gamemanager.gameStartRequest(connection, params);
			}else if(command == ProtocolValues.GAME_USER_EXIT){
				ServerApplication.application.gamemanager.gameUserExit(connection, params);
			}else if(command == ProtocolValues.GAME_SENSOR_START){
				ServerApplication.application.gamemanager.gameSensorStart(connection, params);
			}else if(command == ProtocolValues.GAME_SENSOR_FINISH){
				ServerApplication.application.gamemanager.gameSensorFinish(connection, params);
			}else if(command == ProtocolValues.GAME_SENSOR_ADDITIONAL_ZONE){
				ServerApplication.application.gamemanager.gameSensorAdditionalZone(connection, params);
			}
		}
	}
}
