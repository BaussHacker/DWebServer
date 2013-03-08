import std.string;
import std.array;
import httpserver;
import std.c.stdlib;
import std.stdio;
import tools;
import std.algorithm;

enum RequestType : string
{
	GET = "GET",
	POST = "POST"
}

enum MIMES : int
{
	WebPage = 0,
	Image = 1
}

class HttpHeaderParser
{
private:
	string[string] postData;
	string[string] queryString;
	RequestType requestType;
	string httpVersion;
	string hostIP;
	ushort hostPort;
	string userAgent;
	string acceptType;
	string acceptLanguage;
	string acceptEncoding;
	bool keepAlive;
	string requestPath;
	string remoteAddress;
	MIMES mimeType;
public:
	@property
	{
		RequestType Method()
		{
			return requestType;
		}
		string HttpVersion()
		{
			return httpVersion;
		}
		string HostIP()
		{
			return hostIP;
		}
		ushort HostPort()
		{
			return hostPort;
		}
		string UserAgent()
		{
			return userAgent;
		}
		string AcceptType()
		{
			return acceptType;
		}
		string AcceptLanguage()
		{
			return acceptLanguage;
		}
		string AcceptEncoding()
		{
			return acceptEncoding;
		}
		bool KeepAlive()
		{
			return keepAlive;
		}
		string RequestPath()
		{
			return requestPath;
		}
		string RemoteAddress()
		{
			return remoteAddress;
		}
		MIMES MimeType()
		{
			return mimeType;
		}
		string[string] PostData()
		{
			return postData;
		}
		string[string] QueryString()
		{
			return queryString;
		}
	}
public:
	bool ContainsQueryString(string query)
	{
		bool contains = false;
		foreach (string key; queryString.keys)
		{
			if (key == query)
				contains = true;
		}
		return contains;
	}
	bool ContainsPostData(string data)
	{
		bool contains = false;
		foreach (string key; postData.keys)
		{
			if (key == data)
				contains = true;
		}
		return contains;
	}
public:
static:
	HttpHeaderParser Process(HttpClient client, ubyte[] sdata)
	{
		return Process(client, cast(string)sdata);
	}
	HttpHeaderParser Process(HttpClient client, string sdata)
	{		
		sdata = replace(sdata, "\0", "");
		auto httpheader = new HttpHeaderParser;
		httpheader.remoteAddress = client.GetAddress();
		auto requestLines = splitLines(sdata, KeepTerminator.no);
		bool gotMethod = false;
		foreach (string line; requestLines)
		{
			if (line.length > 0)
			{
				if (!StringTools.IsEmpty(line))
				{
					if (!gotMethod)
					{
						auto data = split(line, " ");
						if (data.length == 3) // ex. GET(0) /page(1) HTTP(2)/1.1(2)
						{
							string method = toLower(data[0]);
							switch (method)
							{
								case "get":
									httpheader.requestType = RequestType.GET;
									break;
								case "post":
									httpheader.requestType = RequestType.POST;
									break;
								default:
									//client.Kill(); // invalid header
									break;
							}
							
							if (data[1] == "/")
							{
								httpheader.requestPath = DEFAULT_PAGE;
							}
							else if (data[1].endsWith("/"))
							{
								httpheader.requestPath = data[1] ~ DEFAULT_PAGE;
							}
							else
							{
								httpheader.requestPath = StringTools.Remove(data[1], 0);
							}
							
							string gotquery = find(httpheader.requestPath, "?");
							gotquery = replace(gotquery, "\0", "");
							if (gotquery.length > 0)
							{
								auto urldata = split(httpheader.requestPath, "?");
								httpheader.requestPath = urldata[0];
								auto queries = split(urldata[1], "&");
								foreach (string query; queries)
								{
									auto qdata = split(query, "=");
									if (qdata.length == 2)
									{
										httpheader.queryString[qdata[0]] = replace(qdata[1], "+", " ");
									}
								}
							}
							
							if (httpheader.requestPath.endsWith(".d"))
								httpheader.mimeType = MIMES.WebPage;
							else if (httpheader.requestPath.endsWith(".jpg") || 
									 httpheader.requestPath.endsWith(".jpeg") ||
									 httpheader.requestPath.endsWith(".png") ||
									 httpheader.requestPath.endsWith(".gif"))
								httpheader.mimeType = MIMES.Image;
							httpheader.httpVersion = data[2];
							gotMethod = true;
						}
						else
						{
							//client.Kill(); // invalid header
						}
					}
					else if (!ProcessHead(client, httpheader, line) && httpheader.requestType == RequestType.POST)
						ProcessPost(client, httpheader, line);
				}
			}
		}
		return httpheader;
	}
private:
static:
	bool ProcessHead(HttpClient client, HttpHeaderParser httpheader, string line)
	{
		auto data = split(line, ": ");
		if (data.length == 2)
		{
			switch (toLower(data[0]))
			{
				case "host":
				{
					auto data2 = split(data[1], ":");
					httpheader.hostIP = data2[0];
					httpheader.hostPort = cast(ushort)atoi((cast(string)data2[1]).ptr);
					break;
				}
				case "user-agent":
					httpheader.userAgent = data[1];
					break;
				case "accept":
					httpheader.acceptType = data[1];
					break;
				case "accept-language":
					httpheader.acceptLanguage = data[1];
					break;
				case "accept-encoding":
					httpheader.acceptEncoding = data[1];
					break;
				case "connection":
					httpheader.keepAlive = (data[1] == "keep-alive");
					break;
				default:
					break;
			}
			return true;
		}
		else
		{
			return false;
		}
	}
	void ProcessPost(HttpClient client, HttpHeaderParser httpheader, string line)
	{
		auto postdatas = split(line, "&");
		foreach (string postdata; postdatas)
		{
			auto data = split(postdata, "=");
			if (data.length == 2)
			{
				httpheader.postData[data[0]] = replace(data[1], "+", " ");
			}
		}
	}
}