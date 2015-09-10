import rethinkdb.rethinkdb;
import std.stdio;

void main()
{
	auto rdb = new RethinkDB();
	if(rdb.is_connected) {
		writeln("SUCCESS");
	} else {
		writeln("NOPE");
	}
}
