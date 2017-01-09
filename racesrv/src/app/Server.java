package app;

public class Server{
	private static SocketServer socketServer;
	
	public static void main(String[] args)
    {		
        try{
        	socketServer = new SocketServer();
        	socketServer.init();
        }catch(Exception e){
            System.out.println("create server error: " + e.toString());
        }
    }
}
