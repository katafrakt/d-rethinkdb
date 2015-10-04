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

	auto db = "dtest";
	auto table = "dtable";

	auto le_string = "fd fds dfs foo";
	auto response = rdb.expr(le_string).run();
	assert(response.stringValue() == le_string);

	writeln(rdb.db_create(db).run());
	writeln(rdb.db(db).table_create(table).run());
	writeln(rdb.db(db).table_create(table).run()); // should return that it already exists

	string[string] filter_opts;
	filter_opts["name"] = "Michel";
	/*auto term = rdb.db(db).table(table).filter(filter_opts);*/
	/*writeln(term.serialize());*/
	/*writeln(term.run());*/

	/*term = rdb.db(db).table(table).filter(`{"name": "Michel"}`);*/
	/*writeln(term.serialize());*/
	/*writeln(term.run());*/


	writeln(rdb.db(db).table_drop(table).run());
	writeln(rdb.db_drop(db).run());
}
