module rethinkdb.term;
import rethinkdb.rethinkdb, rethinkdb.connection, rethinkdb.query;
import rethinkdb.proto, rethinkdb.datum, rethinkdb.response;
import std.stdio;

class Term {
  private RethinkDB driver;
  private Proto.Term current_term;
  private bool shall_clear_term;
  private string str_value;

  this(RethinkDB driver) {
    this.driver = driver;
    this.shall_clear_term = false;
  }

  Response run() {
    return this.run(this.driver.connection);
  }

  Response run(Connection connection) {
    connection.writeQuery(this.value());
    this.clearCurrentQuery();
    return connection.readQueryResponse();
  }

  string value() {
    return this.str_value;
  }

  Term expr(string expression) {
    this.str_value = expression;
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
    auto arg = Datum.build(name);
    this.setQuery(Proto.Term.TermType.DB, arg);
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

  /*Term _filter(string args) {
    this.setQuery(Proto.Term.TermType.FILTER, args);
    return this;
  }*/

  private void clearCurrentQuery() {
    this.shall_clear_term = true;
  }

  private void setQuery(Proto.Term.TermType term_type, string arg) {
    /*if(this.shall_clear_term) {
      this.shall_clear_term = false;
    } else if(this.current_term.type.exists()) {
      term.args ~= this.current_term;
    }*/

    this.str_value = arg;
  }

  private void setQuery(Proto.Term.TermType term_type, Proto.Datum arg) {
    auto term = new Proto.Term();
    term.type = Proto.Term.TermType.DATUM;
    term.datum = arg;
    this.setQuery(term_type, [*term]);
  }

  private void setQuery(Proto.Term.TermType term_type, Proto.Term[] args) {
    auto term = new Proto.Term();
    term.type = term_type;
    if(this.shall_clear_term) {
      this.shall_clear_term = false;
    } else if(this.current_term.type.exists()) {
      term.args ~= this.current_term;
    }

    term.args ~= args;

    this.current_term = *term;
  }
}
