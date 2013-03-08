import std.stdio;
import std.socket;
import core.thread;
import httprequestheader;
import httpprocess;

const int MAX_REQUEST_SIZE = 4096;
const string DEFAULT_PAGE = "index.d";

class HttpServer
{
private:
	TcpSocket serverSocket;
	void accept()
	{
		while (true)
		{
			try
			{
				HttpClient httpClient = new HttpClient(serverSocket.accept());
				httpClient.BeginReceive();
			}
			catch (SocketOSException se)
			{
				writeln("[Socket Exception] Error Code: ", se.errorCode);
			}
			Thread.sleep(dur!("msecs")( 1 ));
		}
	}
public:
	this()
	{
		serverSocket = new TcpSocket();
	}
	void BeginHttpServer(string ipAddress, ushort port)
	{
		serverSocket.bind(new InternetAddress(ipAddress, port));
		serverSocket.listen(500);
		accept();
	}
}

class HttpClient
{
private:
	Socket clientSocket;
	
	void receive_callback()
	{
		ubyte[] buffer = new ubyte[MAX_REQUEST_SIZE];
		clientSocket.receive(buffer, SocketFlags.NONE);
		HttpHeaderParser header = HttpHeaderParser.Process(this, buffer);
		ProcessRequest(this, header);
		Thread.sleep(dur!("msecs")( 1 ));
	}
public:
	this(Socket socket)
	{
		clientSocket = socket;
	}
	void BeginReceive()
	{
		Thread clientThread = new Thread(&receive_callback);
		clientThread.start();
	}
	void Kill()
	{
		clientSocket.shutdown(SocketShutdown.BOTH);
		clientSocket.close();
	}
	int Send(ubyte[] data)
	{
		return clientSocket.send(data, SocketFlags.NONE);
	}
	int Send(string data)
	{
		return clientSocket.send(data);
	}
	string GetAddress()
	{
		return clientSocket.remoteAddress.toAddrString();
	}
}