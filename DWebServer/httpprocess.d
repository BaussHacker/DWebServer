import httpserver;
import httprequestheader;

import std.stdio;

import pages.master;
import httpsession;

import std.file;

import std.array;

import std.c.string;

import std.conv;

void ProcessRequest(HttpClient client, HttpHeaderParser header)
{
	switch (header.MimeType)
	{
		default:
		case MIMES.WebPage:
		{
			HttpSession session = new HttpSession;
			session.AddHead("HTTP/1.0 200 OK\r\n");
			session.AddHead("Content-Type: text/html\r\n");
			string html = GetHtml(session, header, header.RequestPath);
			if (!session.DataBlocked)	
			{
				session.AddHead("Content-Length: " ~to!string(html.length) ~ "\r\n");
				session.AddData(html);
			}
			client.Send(session.GetData());
			client.Kill();
			break;
		}
		case MIMES.Image:
		{
			string img = "www\\" ~ replace(header.RequestPath, "/", "\\");
    		ubyte[] data = cast(ubyte[]) read(img);
			
			client.Send("HTTP/1.0 200 OK\r\n");
    		client.Send("Content-Type: image/" ~ split(img, ".")[$ - 1]  ~ "\r\n");
    		client.Send("Content-Length: " ~ to!string(data.length)  ~ "\r\n");
    		client.Send("\r\n");
    		client.Send(data);
			break;
		}	
	}
}

ubyte[] crop(ubyte[] buffer, int length)
{
	ubyte[] nbuffer = new ubyte[buffer.length - length];
	for (int i = 0; i < nbuffer.length; i++)
	{
		nbuffer[i] = buffer[i + length];
	}	
	return nbuffer;
}