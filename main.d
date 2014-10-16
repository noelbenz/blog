
import blog;
static import conv = std.conv;
static import file = std.file;
static import date = std.datetime;
static import json = std.json;

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

void main()
{
	
	auto header = cast(string)file.read("templates/header.html");
	auto post = cast(string)file.read("templates/post.html");
	auto style = cast(string)file.read("templates/style.css");
	
	date.Date dateObj = cast(date.Date)date.Clock.currTime();
	int year = dateObj.year;
	string month = monthToStr(dateObj.month);
	int day = dateObj.day;
	
	int size = header.length + style.length;
	
	auto testJson = json.parseJSON(cast(string)file.read("posts/helloworld.json"));
	
	print(conv.text(testJson));
	print(conv.text(testJson.type));
	
	auto object = testJson.object;
	print(monthToStr(cast(int)object["month"].integer));
	
	file.write("test.html", "Hi.");
}
