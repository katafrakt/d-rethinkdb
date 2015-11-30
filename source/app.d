import rethinkdb.rethinkdb;
import std.stdio, std.conv, std.json;

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

	rdb.db_drop(db).run(); // control, if previous test run went wrong

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

	response = rdb.db(db).table(table).filter(filter_opts).run();
	assert(response.length == 0);

	response = rdb.db(db).table(table).insert(`{"name": "Michel", "last_name": "Pfeiffer"}`).run();

	response = rdb.db(db).table(table).filter(`{"name": "Michel"}`).run();
	assert(response.length == 1);

	JSONValue res = rdb.db(db).table_drop(table).run().objValue();
	assert(res["tables_dropped"].integer == 1);

	res = rdb.db_drop(db).run().objValue();
	assert(res["dbs_dropped"].integer == 1);
}
