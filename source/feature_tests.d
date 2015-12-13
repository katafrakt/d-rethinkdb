module feature_tests;
import std.json;
import std.stdio; // for ad-hoc debugging

debug(featureTest) {
  import feature_test;
  import rethinkdb.rethinkdb, rethinkdb.response;

  unittest {
    auto rdb = new RethinkDB();
    auto db = "dtest";
    auto table = "dtable";
    Response response;

    feature("Creating and dropping", (f) {
      f.scenario("create and drob db", {
        response = rdb.db_create(db).run();

        response.isSuccess().shouldEqual(true);
        response["dbs_created"].integer.shouldEqual(1);

        rdb.db_drop(db).run();
      });

      f.scenario("create table", {
      	response = rdb.db_create(db).run();
        response = rdb.db(db).table_create(table).run();

        response.isSuccess().shouldEqual(true);
        response["tables_created"].integer.shouldEqual(1);

        rdb.db_drop(db).run();
      });
    }, "");

    feature("Expressions", (f) {
      f.scenario("expr", {
        auto le_string = "fd fds dfs foo";
        response = rdb.expr(le_string).run();
        response.str.shouldEqual(le_string);

        response.isSuccess().shouldEqual(true);
      });

      f.scenario("brackets with integer", {
        response = rdb.expr([10, 20, 30, 40, 50])[3].run();
      	response.integer.shouldEqual(40);
      });

      f.scenario("add", {
        response = rdb.expr(2).add(2).run();
        response.integer.shouldEqual(4);
      });

      f.scenario("add with arrays", {
        response = rdb.expr([1,2,5]).add([0,23]).run();
        response.length.shouldEqual(5);
        response[0].integer.shouldEqual(1);
        response[4].integer.shouldEqual(23);
      });

      f.scenario("sub", {
        response = rdb.expr(23).sub(21).run();
        response.integer.shouldEqual(2);
      });

      f.scenario("mul", {
        response = rdb.expr(234312).mul(212323).run();
        response.integer.shouldEqual(49749826776);
      });

      f.scenario("div", {
        response = rdb.expr(3).div(6).run();
        response.floating.shouldEqual(0.5);
      });

      f.scenario("mod", {
        response = rdb.expr(5).mod(3).run();
      	response.integer.shouldEqual(2);
      });
    }, "");

    feature("data operation with no data", (f) {
      f.addBeforeAll({
        rdb.db_create(db).run();
        rdb.db(db).table_create(table).run();
      });

      f.addAfterAll({
        rdb.db_drop(db).run();
      });

      f.scenario("filter", {
        string[string] filter_opts;
      	filter_opts["name"] = "Michel";
        response = rdb.db(db).table(table).filter(filter_opts).run();
      	response.length.shouldEqual(0);
      });

      f.scenario("insert with associative array", {
        string[string] opts;
      	opts["name"] = "Armando";

        response = rdb.db(db).table(table).insert(opts).run();
        response.isSuccess().shouldEqual(true);
        response["inserted"].integer.shouldEqual(1);
      });

      f.scenario("insert with JSON", {
        auto json = parseJSON(`{"name": "Jeremiah"}`);
        response = rdb.db(db).table(table).insert(json).run();
        response.isSuccess().shouldEqual(true);
        response["inserted"].integer.shouldEqual(1);
      });
    }, "data");

    feature("data manipulation", (f) {
      string michelle_uuid;

      f.addBeforeAll({
        rdb.db_create(db).run();
        rdb.db(db).table_create(table).run();
        response = rdb.db(db).table(table).insert(parseJSON(`{"name": "Michelle", "last_name": "Pfeiffer"}`)).run();
        michelle_uuid = response["generated_keys"][0].str();
        response = rdb.db(db).table(table).insert(parseJSON(`{"name": "Dedee", "last_name": "Pfeiffer"}`)).run();
      });

      f.addAfterAll({
        rdb.db_drop(db).run();
      });

      f.scenario("filter with associative array", {
        auto params = ["name": "Michelle"];
        response = rdb.db(db).table(table).filter(params).run();
        response.length.shouldEqual(1);
        response["last_name"].str.shouldEqual("Pfeiffer");
      });

      f.scenario("filter with JSON", {
        response = rdb.db(db).table(table).filter(parseJSON(`{"name": "Michelle"}`)).run();
        response.length.shouldEqual(1);
        response["last_name"].str.shouldEqual("Pfeiffer");
      });

      f.scenario("filter with JSON", {
        response = rdb.db(db).table(table).filter(parseJSON(`{"name": "Michelle"}`)).run();
        response.length.shouldEqual(1);
        response["last_name"].str.shouldEqual("Pfeiffer");
      });

      f.scenario("get", {
        response = rdb.db(db).table(table).get(michelle_uuid).run();
        response.length.shouldEqual(1);
        response["last_name"].str.shouldEqual("Pfeiffer");
      });

      f.scenario("brackets with string", {
        response = rdb.db(db).table(table).get(michelle_uuid)["last_name"].run();
      	response.length.shouldEqual(1);
      	response.str().shouldEqual("Pfeiffer");
      });

      f.scenario("pluck", {
        response = rdb.db(db).table(table).pluck("last_name").run();
        response.length.shouldEqual(2);
      	response[0].object.length.shouldEqual(1);
      	response[0]["last_name"].str().shouldEqual("Pfeiffer");
      });

      f.scenario("pluck with distinct", {
        response = rdb.db(db).table(table).pluck("last_name").distinct().run();
        response.length.shouldEqual(1);
      	response[0].object.length.shouldEqual(1);
      	response[0]["last_name"].str().shouldEqual("Pfeiffer");
      });
    });
  }
}
