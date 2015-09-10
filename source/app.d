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

	for(int i = 0; i < 20; i++) {
		auto query = "[1, \"foo" ~ to!string(i) ~ "\", {}]";
		rdb.connection.writeQuery(query);
		writeln(rdb.connection.readQueryResponse());
	}
}
