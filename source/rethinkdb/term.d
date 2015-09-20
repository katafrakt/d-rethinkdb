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
    this.setQuery(Proto.Term.TermType.DB, name);
    return this;
  }

  Term _db_create(string name) {
    this.setQuery(Proto.Term.TermType.DB_CREATE, name);
    return this;
  }

  Term _db_drop(string name) {
    this.setQuery(Proto.Term.TermType.DB_DROP, name);
    return this;
  }

  Term _table(string name) {
    this.setQuery(Proto.Term.TermType.TABLE, name);
    return this;
  }

  Term _table_create(string name) {
    this.setQuery(Proto.Term.TermType.TABLE_CREATE, name);
    return this;
  }

  Term _table_drop(string name) {
    this.setQuery(Proto.Term.TermType.TABLE_DROP, name);
    return this;
  }

  Term _filter(string args) {
    this.setQuery(Proto.Term.TermType.FILTER, args);
    return this;
  }

  private void clearCurrentQuery() {
    this.current_query = null;
  }

  private string createRealQuery() {
    return "[1, " ~ this.current_query.serialize() ~ "]";
  }

  private void setQuery(int query_type, string args) {
    auto query = new Query(query_type, this.current_query, args);
    this.current_query = query;
  }
}
