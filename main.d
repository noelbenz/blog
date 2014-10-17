
import blog;
static import conv = std.conv;
static import file = std.file;
static import date = std.datetime;
static import json = std.json;
static import io = std.stdio;
static import path = std.path;

string monthToStr(int month)
{
	switch (month)
	{
		case 1:
			return "January";
		case 2:
			return "February";
		case 3:
			return "March";
		case 4:
			return "April";
		case 5:
			return "May";
		case 6:
			return "June";
		case 7:
			return "July";
		case 8:
			return "August";
		case 9:
			return "September";
		case 10:
			return "October";
		case 11:
			return "November";
		case 12:
			return "December";
		default:
			return "Unknwon Month";
	}
}

int digits(int n)
{
	int count = 0;
	
	while (n > 0)
	{
		count += 1;
		n = n/10;
	}
	
	return count;
}

struct PostData
{
	int id;
	string title;
	int year;
	int month;
	int day;
	
	/**
	 * Fills in any information that can be assessed without user input (ex: date).
	 */
	void fill()
	{
		date.Date dateObj = cast(date.Date)date.Clock.currTime();
		year = dateObj.year;
		month = dateObj.month;
		day = dateObj.day;
	}
	
	string toJSON()
	{
		auto jsonValue = json.JSONValue();
		
		json.JSONValue[string] jsonObj;
		
		auto idObj = json.JSONValue();
		idObj.integer = id;
		jsonObj["id"] = idObj;
		
		auto yearObj = json.JSONValue();
		yearObj.integer = year;
		jsonObj["year"] = yearObj;
		
		auto monthObj = json.JSONValue();
		monthObj.integer = month;
		jsonObj["month"] = monthObj;
		
		auto dayObj = json.JSONValue();
		dayObj.integer = day;
		jsonObj["day"] = dayObj;
		
		auto stringObj = json.JSONValue();
		stringObj.str = title;
		jsonObj["title"] = stringObj;
		
		jsonValue.object = jsonObj;
		
		return conv.text(json.toJSON(&jsonValue, true));
	}
}


struct Post
{
	PostData data;
	string[] parts;
}

Post generatePost(string content, PostData data, string[] format)
{
	string[] parts;
	parts ~= format[0];
	parts ~= conv.text(data.id);
	parts ~= format[1];
	parts ~= data.title;
	parts ~= format[2];
	parts ~= monthToStr(data.month);
	parts ~= format[3];
	parts ~= conv.text(data.day);
	parts ~= format[4];
	parts ~= conv.text(data.year);
	parts ~= format[5];
	parts ~= content;
	parts ~= format[6];
	
	Post post = {data, parts};
	
	return post;
}

/**
 * Splits *str* at each occurence of *sep* into an array of strings.
 */
string[] split(string str, char sep)
{
	string[] results;
	
	int cur = 0;
	for (int i = 0; i <= str.length; i++)
	{
		if (i == str.length || str[i] == sep)
		{
			if (cur < i)
			{
				results ~= str[cur .. i];
			}
			cur = i+1;
		}
	}
	
	return results;
}

void main()
{
	
	auto header = cast(string)file.read("templates/header.html");
	string[] postFmt = split(cast(string)file.read("templates/post.html"), '@');
	auto style = cast(string)file.read("templates/style.css");
	
	Post[int] posts;
	
	int maxID;
	string newPostContent;
	string newPostJsonPath;
	
	foreach(f; file.dirEntries("posts", "*.txt", file.SpanMode.shallow))
	{
		auto postContent = cast(string)file.read(f.name);
		auto jsonPath = path.setExtension(f.name, ".json");
		
		if (!file.exists(jsonPath))
		{
			newPostContent = postContent;
			newPostJsonPath = jsonPath;
		}
		else
		{
			auto jsonTxt = cast(string)file.read(jsonPath);
			auto value = json.parseJSON(jsonTxt);
			auto object = value.object;
			
			int id = cast(int)object["id"].integer;
			int year = cast(int)object["year"].integer;
			int month = cast(int)object["month"].integer;
			int day = cast(int)object["day"].integer;
			string title = object["title"].str;
			
			PostData data = {id, title, year, month, day};
			
			posts[id] = generatePost(postContent, data, postFmt);
			
			maxID = id > maxID ? id : maxID;
		}
	}
	
	if (newPostContent != null)
	{
		maxID += 1;
		
		auto title = io.readln();
		if (title.length > 0)
		{
			title = title[0 .. $-1];
		}
		
		PostData data = {maxID, title};
		data.fill();
		
		file.write(newPostJsonPath, data.toJSON());
		
		posts[maxID] = generatePost(newPostContent, data, postFmt);
	}
	
	
	string[] blog;
	int size;
	
	blog ~= header;
	size += header.length;
	
	for (int i = 1; i <= posts.length; i++)
	{
		auto post = posts[i];
		blog = blog ~ post.parts;
		
		foreach(string part; post.parts)
		{
			size += part.length;
		}
	}
	
	char[] html = new char[size];
	
	int p = 0;
	for (int i = 0; i < blog.length; i++)
	{
		auto str = blog[i];
		html[p .. p+str.length] = str;
	}
	
	file.write("html/index.html", html);
}
