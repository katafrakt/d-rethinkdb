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

  // Trying to be smart here.
  // As arguments to pretty much any of queries can be either string or a hash
  // we define a convenience method here. The naming convention for actual expressions
  // is with underscore and opDispatch takes care of converting associative arrays
  // into a string, which is passed as an argument to actual method.
  // This behaviour can be of course superseded by defining a method without underscore
  // opDispatch won't catch it in that case, but you are on your own with implementing
  // support for both types of argument (if allowed).
  auto opDispatch(string s)(string args) {
    return mixin("this._" ~ s ~ "(args)");
  }

  auto opDispatch(string s)(string[string] args) {
    string serialized_args = args.toJSONString(PrettyJson.no);
    return mixin("this._" ~ s ~ "(serialized_args)");
  }

  Term _db(string name) {
    this.current_query = new Query(Proto.Term.TermType.DB, null, name);
    return this;
  }

  Term _table(string name) {
    this.current_query = new Query(Proto.Term.TermType.TABLE, this.current_query, name);
    return this;
  }

  Term _filter(string args) {
    this.current_query = new Query(Proto.Term.TermType.FILTER, this.current_query, args);
    return this;
  }

  private void clearCurrentQuery() {
    this.current_query = null;
  }

  private string createRealQuery() {
    return "[1, " ~ this.current_query.serialize() ~ "]";
  }
}
