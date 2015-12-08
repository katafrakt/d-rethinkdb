import rethinkdb.rethinkdb, rethinkdb.response;
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
	assert(response["dbs_created"].integer == 1);

	response = rdb.db(db).table_create(table).run();

	assert(response.isSuccess());
	assert(response["tables_created"].integer == 1);

	response = rdb.db(db).table_create(table).run();

	assert(!response.isSuccess());


	string[string] filter_opts;
	filter_opts["name"] = "Michel";

	response = rdb.db(db).table(table).filter(filter_opts).run();
	assert(response.length == 0);

	response = rdb.db(db).table(table).insert(`{"name": "Michel", "last_name": "Pfeiffer"}`).run();

	response = rdb.db(db).table(table).filter(`{"name": "Michel"}`).run();
	assert(response.length == 1);
	string uuid = response["id"].str();

	response = rdb.db(db).table(table).get(uuid).run();
	assert(response.length == 1);
	assert(response["last_name"].str() == "Pfeiffer");

	Response res = rdb.db(db).table_drop(table).run();
	assert(res["tables_dropped"].integer == 1);

	res = rdb.db_drop(db).run();
	assert(res["dbs_dropped"].integer == 1);
}
