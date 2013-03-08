import std.stdio;

class HttpSession
{
private:
	ubyte[] httpHeader;
	ubyte[] httpData;
	bool datablocked;
public:
	@property bool DataBlocked()
	{
		return datablocked;
	}
	string ContentType;
	this()
	{
		datablocked = false;
	}
	
	void AddHead(string data)
	{
		if (datablocked)
			return;
		httpHeader ~= cast(ubyte[])data;
	}
	void AddData(string data)
	{
		if (datablocked)
			return;
		httpData ~= cast(ubyte[])data;
	}
	
	void Redirect(string url)
	{
		ClearHead();
		ClearData();
		AddHead("HTTP/1.0 302 Found\r\n");
		AddHead("Location: " ~ url ~ "\r\n");
		datablocked = true;
	}
	
	void ClearHead()
	{
		httpHeader = new ubyte[0];
	}
	void ClearData()
	{
		httpData = new ubyte[0];
	}
	
	ubyte[] GetData()
	{
		ubyte[] headdata = new ubyte[0];
		if (httpHeader.length > 0)
			headdata ~= cast(ubyte[])httpHeader;
		if (httpData.length > 0)
			headdata ~= httpData;
		return headdata;
	}
}