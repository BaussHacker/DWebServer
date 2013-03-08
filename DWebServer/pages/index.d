module pages.index;

import httpserver;
import httprequestheader;
import httpsession;

import pages.master;

import std.array;

import std.stdio;

class Index
{
public:
static:
	void HANDLE_INIT(HttpSession session, HttpHeaderParser header, HttpPage page)
	{
		page.BodyHtml = replace(page.BodyHtml, "@PRINT_TO_ME", header.RemoteAddress);
		page.BodyHtml = replace(page.BodyHtml, "@HTTP_METHOD", cast(string)header.Method);
	}
	
	void HANDLE_GET(HttpSession session, HttpHeaderParser header, HttpPage page)
	{
		page.BodyHtml = replace(page.BodyHtml, "@YOUR_INPUT", "");
	}
	
	void HANDLE_POST(HttpSession session, HttpHeaderParser header, HttpPage page)
	{
		page.BodyHtml = replace(page.BodyHtml, "@YOUR_INPUT", header.PostData["someinput"]);
	}
}