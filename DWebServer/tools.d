import std.stdio;

class StringTools
{
public:
static:
	bool IsEmpty(string s)
	{
		if (s is null)
			return true;
		if (s.length == 0)
			return true;
		bool onlywhitespace = true;
		foreach (char c; s)
		{
			if (c != ' ' && c != '\r' && c != '\t')
				onlywhitespace = false;
		}
		return onlywhitespace;
	}
	bool StartsWith(string s, string ss)
	{
		if (s.length < ss.length)
			return false;
		
		for (int i = 0; i < ss.length; i++)
		{
			if (s[i] != ss[i])
				return false;
		}
		return true;
	}
	
	bool EndsWith(string s, string ss)
	{
		int count = ss.length - 1;
		for (int i = s.length - 1; i >= 0; i--)
		{
			if (count < 0)
				return true;
			if (s[i] != ss[count])
				return false;
			count--;
		}
		return false;
	}
	
	string Remove(string s, int index)
	{
		ubyte[] sbytes = new ubyte[s.length - 1];
		int sindex = 0;
		ubyte[] ssbytes = cast(ubyte[])s;
		for (int i = 0; i < ssbytes.length; i++)
		{
			if (i != index)
			{
				sbytes[sindex] = ssbytes[i];
				sindex++;
			}
		}
		return cast(string)sbytes;
	}
}