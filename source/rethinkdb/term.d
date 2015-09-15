module rethinkdb.term;
import rethinkdb.rethinkdb, rethinkdb.connection, rethinkdb.query;
import rethinkdb.proto;
import jsonizer.tojson;

class Term {
  private RethinkDB driver;
  private Query current_query;

  this(RethinkDB driver) {
    this.driver = driver;
  }

  string run() {
    return this.run(this.driver.connection);
  }

  string run(Connection connection) {
    connection.writeQuery(this.createRealQuery());
    this.clearCurrentQuery();
    return connection.readQueryResponse();
  }

  string serialize() {
    return this.current_query.serialize();
  }

  Term expr(string expression) {
    this.current_query = new SimpleQuery(expression);
    return this;
  }

  Term db(string name) {
    this.current_query = new Query(Proto.Term.TermType.DB, null, name);
    return this;
  }

  Term table(string name) {
    this.current_query = new Query(Proto.Term.TermType.TABLE, this.current_query, name);
    return this;
  }

  Term filter(string args) {
    this.current_query = new Query(Proto.Term.TermType.FILTER, this.current_query, args);
    return this;
  }

  Term filter(string[string] options) {
    return this.filter(options.toJSONString(PrettyJson.no));
  }

  private void clearCurrentQuery() {
    this.current_query = null;
  }

  private string createRealQuery() {
    return "[1, " ~ this.current_query.serialize() ~ "]";
  }
}
