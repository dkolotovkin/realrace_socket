package app;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;


public class SocketServer {
	private ServerSocketChannel _serverSocketChannel;
	private ServerSocket _serverSocket;
	private Selector _selector;
	
	private int countKeys;
	private Set<SelectionKey> keys;
	private Iterator<SelectionKey> keysIterator;
	private SelectionKey key;
	
	private Socket socket;
	private SocketChannel socketChannel;
	
	private ServerApplication application;
	
	public SocketServer(){
	}
	
	public void init(){
		try 
		{
			_serverSocketChannel = ServerSocketChannel.open();
			_serverSocketChannel.configureBlocking(false);
			_serverSocket = _serverSocketChannel.socket();
			_serverSocket.bind(new InetSocketAddress(Config.serverHost(), Config.serverPort()), 5000);
			_selector = Selector.open();
			_serverSocketChannel.register(_selector, SelectionKey.OP_ACCEPT);
			
			application = new ServerApplication(_selector);
		}
		catch (IOException ie) 
		{
			application.logger.log("error create server socket channel" + ie.toString());
		}
		
		while (true) 
		{
			try
			{
				countKeys = _selector.select();
				if (countKeys == 0){
					continue;
				}
				keys = _selector.selectedKeys();
				keysIterator = keys.iterator();
				while (keysIterator.hasNext()) 
				{
					key = keysIterator.next();
					if (key.isValid())
					switch (key.readyOps())
					{
						case SelectionKey.OP_ACCEPT:
														socket = _serverSocket.accept();
														socketChannel = socket.getChannel();
														socketChannel.configureBlocking(false);
														socketChannel.register(_selector, SelectionKey.OP_READ);
														break;
						case SelectionKey.OP_WRITE:							
														socketChannel = (SocketChannel) key.channel();	
														if(socketChannel != null && socketChannel.isConnected()){
															if(application.sendBuffer(socketChannel)){
																socketChannel.register(_selector, SelectionKey.OP_READ);
															}
														}
														break;
						case SelectionKey.OP_READ:
														try
														{															
															socketChannel = (SocketChannel)key.channel();
															boolean result = application.onData(socketChannel);
															if (!result)
															{
																key.cancel();
																try
																{
																	socket = socketChannel.socket();																	
																	if(socket.isConnected()){
																		socket.close();
																	}
																}
																catch (IOException ie)
																{
																	application.logger.log("error closing socket " + socket + ": " + ie.toString());
																}
															}
														}
														catch( Exception ie )
														{
															application.logger.log("close socket = " + ie.toString());
															ie.printStackTrace();
															key.cancel();
															socket = socketChannel.socket();
															socket.close();
														}
														break;
					}
				}
				keys.clear();
				keys = null;
				keysIterator = null;
			}
			catch (Exception e) 
			{
				application.logger.log("socet error: " + e.toString());
				e.printStackTrace();
				if (keys != null){
					keys.clear();
					keys = null;
				}
			}
		}
	}	
}
