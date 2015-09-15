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
	string[string] filter_opts;
	filter_opts["name"] = "Michel";
	auto term = rdb.db("blog").table("users").filter(filter_opts);
	writeln(term.serialize());
	writeln(term.run());

	term = rdb.db("blog").table("users").filter(`{"name": "Michel"}`);
	writeln(term.serialize());
	writeln(term.run());
}
