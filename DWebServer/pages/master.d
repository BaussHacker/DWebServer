module pages.master;

import std.array;
import httpsession;
import httprequestheader;
import std.file;
import std.stdio;

class HttpPage
{
public:
	string HeadHtml;
	string BodyHtml;
}

// import page handles
import pages.index;
import pages.redirect;

string GetHtml(HttpSession session, HttpHeaderParser header, string requestpage)
{
	string masterPage = readText("www\\master.d.master");
	session.ContentType = "text/html";
	
	string path = "www\\" ~ requestpage;
	path = replace(path, "/", "\\");
	string headpath = path ~ ".head";
	string bodypath = path ~ ".body";
	
	if (!exists(headpath) && !exists(bodypath))
	{
		headpath = "www\\" ~ "404.d.head";
		bodypath = "www\\" ~ "404.d.body";
	}
	HttpPage page = new HttpPage;
	page.HeadHtml = readText(headpath);
	page.BodyHtml = readText(bodypath);

	switch (requestpage)
	{
		case "index.d":
			Index.HANDLE_INIT(session, header, page);
			if (header.Method == RequestType.GET)
				Index.HANDLE_GET(session, header, page);
			else if (header.Method == RequestType.POST)
				Index.HANDLE_POST(session, header, page);
			break;
		
		case "redirect.d":
			Redirect.HANDLE_INIT(session, header, page);
			break;
			
		default:
			break;
	}

	string ret  = replace(masterPage, "@head", page.HeadHtml);
	ret = replace(ret, "@body", page.BodyHtml);

	return ret;
}