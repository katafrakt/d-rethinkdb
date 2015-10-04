module rethinkdb.term;
import rethinkdb.rethinkdb, rethinkdb.connection, rethinkdb.query;
import rethinkdb.proto, rethinkdb.datum, rethinkdb.response;
import jsonizer.tojson, std.stdio;

class Term {
  private RethinkDB driver;
  private Proto.Term current_term;
  private bool shall_clear_term;

  this(RethinkDB driver) {
    this.driver = driver;
    this.shall_clear_term = false;
  }

  Response run() {
    return this.run(this.driver.connection);
  }

  Response run(Connection connection) {
    connection.writeQuery(this.current_term);
    this.clearCurrentQuery();
    return connection.readQueryResponse();
  }

  /*string serialize() {
    return this.current_query.serialize();
  }*/

  Term expr(string expression) {
    auto term = new Proto.Term();
    term.type = Proto.Term.TermType.DATUM;

    // possibly simplify? (call datum right away)
    auto datum = new Proto.Datum();
    datum.type = Proto.Datum.DatumType.R_STR;
    datum.r_str = expression;

    term.datum = *datum;
    this.current_term = *term; // why asterisk?
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
    auto arg = Datum.build(name);
    this.setQuery(Proto.Term.TermType.DB_CREATE, arg);
    return this;
  }

  Term _db_drop(string name) {
    auto arg = Datum.build(name);
    this.setQuery(Proto.Term.TermType.DB_DROP, arg);
    return this;
  }

  Term _table(string name) {
    auto arg = Datum.build(name);
    this.setQuery(Proto.Term.TermType.TABLE, arg);
    return this;
  }

  Term _table_create(string name) {
    auto arg = Datum.build(name);
    this.setQuery(Proto.Term.TermType.TABLE_CREATE, arg);
    return this;
  }

  Term _table_drop(string name) {
    auto arg = Datum.build(name);
    this.setQuery(Proto.Term.TermType.TABLE_DROP, arg);
    return this;
  }

  /*Term _filter(string args) {
    this.setQuery(Proto.Term.TermType.FILTER, args);
    return this;
  }*/

  private void clearCurrentQuery() {
    this.shall_clear_term = true;
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
