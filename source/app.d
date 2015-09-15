import rethinkdb.rethinkdb;
import std.stdio, std.conv;

void main()
{
	auto rdb = new RethinkDB();
	if(rdb.is_connected) {
		writeln("SUCCESS");
	} else {
		writeln("NOPE");
	}

	auto response = rdb.expr("foo").run();
	writeln(response);
}
