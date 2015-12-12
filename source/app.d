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
	assert(response.str() == le_string);

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

	response = rdb.db(db).table(table).insert(parseJSON(`{"name": "Michel", "last_name": "Pfeiffer"}`)).run();

	response = rdb.db(db).table(table).filter(parseJSON(`{"name": "Michel"}`)).run();
	assert(response.length == 1);
	string uuid = response["id"].str();

	response = rdb.db(db).table(table).get(uuid).run();
	assert(response.length == 1);
	assert(response["last_name"].str() == "Pfeiffer");

	// test brackets with string
	response = rdb.db(db).table(table).get(uuid)["last_name"].run();
	assert(response.length == 1);
	assert(response.str() == "Pfeiffer");

	// test brackets with integer
	response = rdb.expr([10, 20, 30, 40, 50])[3].run();
	assert(response.integer == 40);

	response = rdb.db(db).table(table).insert(parseJSON(`{"name": "Oona", "last_name": "Pfeiffer"}`)).run();

	// test pluck
	response = rdb.db(db).table(table).pluck("last_name").run();
	assert(response.length == 2);
	assert(response[0].object.length == 1);
	assert(response[0]["last_name"].str() == "Pfeiffer");

	// test pluck with distinct
	response = rdb.db(db).table(table).pluck("last_name").distinct().run();
	assert(response.length == 1);
	assert(response[0].object.length == 1);
	assert(response[0]["last_name"].str() == "Pfeiffer");

	// add
	response = rdb.expr(2).add(2).run();
	assert(response.integer == 4);

	// also possible to add arrays!
	response = rdb.expr([1,2,5]).add([0,23]).run();
	assert(response.length == 5);
	assert(response[0].integer == 1);
	assert(response[4].integer == 23);

	// sub
	response = rdb.expr(23).sub(21).run();
	assert(response.integer == 2);

	// mul
	response = rdb.expr(234312).mul(212323).run();
	assert(response.integer == 49749826776);

	// div
	response = rdb.expr(3).div(6).run();
	assert(response.floating == 0.5);

	// mod
	response = rdb.expr(5).mod(3).run();
	assert(response.integer == 2);


	// clean up
	Response res = rdb.db(db).table_drop(table).run();
	assert(res["tables_dropped"].integer == 1);

	res = rdb.db_drop(db).run();
	assert(res["dbs_dropped"].integer == 1);
}
