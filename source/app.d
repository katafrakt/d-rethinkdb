import rethinkdb.rethinkdb;
import std.stdio, std.conv;

void main()
{
	auto rdb = new RethinkDB();
	assert(rdb.is_connected);

	auto db = "dtest";
	auto table = "dtable";

	auto le_string = "fd fds dfs foo";
	auto response = rdb.expr(le_string).run();

	assert(response.isSuccess());
	assert(response.stringValue() == le_string);

	response = rdb.db_create(db).run();
	assert(response.isSuccess());
	assert(response.objValue()["dbs_created"].integer == 1);

	response = rdb.db(db).table_create(table).run();

	assert(response.isSuccess());
	assert(response.objValue()["tables_created"].integer == 1);

	response = rdb.db(db).table_create(table).run();

	assert(!response.isSuccess());


	string[string] filter_opts;
	filter_opts["name"] = "Michel";
	
	auto term = rdb.db(db).table(table).filter(filter_opts);
	writeln(term.serialize());
	writeln(term.run());

	term = rdb.db(db).table(table).filter(`{"name": "Michel"}`);
	writeln(term.serialize());
	writeln(term.run());


	writeln(rdb.db(db).table_drop(table).run().objValue());
	writeln(rdb.db_drop(db).run().objValue());
}
