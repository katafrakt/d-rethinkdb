module rethinkdb.term;
import rethinkdb.rethinkdb, rethinkdb.connection, rethinkdb.query;
import rethinkdb.proto, rethinkdb.response;
import std.stdio, std.json, std.traits;

class Term {
  private RethinkDB driver;
  private Query query;
  private bool shall_clear_term;

  this(RethinkDB driver) {
    this.driver = driver;
    this.shall_clear_term = false;
  }

  Response run() {
    return this.run(this.driver.connection);
  }

  Response run(Connection connection) {
    connection.writeQuery(this.serialize());
    this.clearCurrentQuery();
    return connection.readQueryResponse();
  }

  string serialize() {
    return this.query.serialize();
  }

  Term expr(string expression) {
    this.query = new SimpleQuery(expression);
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
  auto opDispatch(string s, T)(T args) {
    string str;

    static if(__traits(isAssociativeArray, T)) {
      JSONValue json = args;
      str = json.toString();
    } else {
      str = args;
    }

    return mixin("this._" ~ s ~ "(str)");
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

  Term _insert(string args) {
    this.setQuery(Proto.Term.TermType.INSERT, args);
    return this;
  }

  private void clearCurrentQuery() {
    this.shall_clear_term = true;
  }

  private void setQuery(Proto.Term.TermType term_type, string arg) {
    if(this.shall_clear_term) {
      this.shall_clear_term = false;
    }

    Query query;
    if(this.query is null) {
      this.query = new Query(term_type, arg);
    } else {
      this.query = new Query(term_type, this.query, arg);
    }

  }
}
