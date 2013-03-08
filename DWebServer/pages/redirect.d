module pages.redirect;

import httpserver;
import httprequestheader;
import httpsession;

import pages.master;

import std.array;

import std.stdio;

class Redirect
{
public:
static:
	void HANDLE_INIT(HttpSession session, HttpHeaderParser header, HttpPage page)
	{
		session.Redirect(header.QueryString["url"]);
	}
}