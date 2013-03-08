import std.stdio, std.cstream;

import httpserver;

import tools;

void main(string[] args)
{
	HttpServer server = new HttpServer();
	server.BeginHttpServer("127.0.0.1", 8080);
	din.getc();
}
