module rethinkdb.term;
import rethinkdb.rethinkdb, rethinkdb.connection, rethinkdb.query;
import rethinkdb.proto, rethinkdb.response;
import std.stdio, std.json, std.traits;

class Term {
  private RethinkDB driver;
  private Query query;
  private bool shall_clear_term;

  enum dict = [
    "db": Proto.Term.TermType.DB,
    "db_create": Proto.Term.TermType.DB_CREATE,
    "db_drop": Proto.Term.TermType.DB_DROP,
    "db_list": Proto.Term.TermType.DB_LIST,
    "table": Proto.Term.TermType.TABLE,
    "table_create": Proto.Term.TermType.TABLE_CREATE,
    "table_drop": Proto.Term.TermType.TABLE_DROP,
    "filter": Proto.Term.TermType.FILTER,
    "insert": Proto.Term.TermType.INSERT,
    "update": Proto.Term.TermType.UPDATE,
    "del": Proto.Term.TermType.DELETE,
    "get": Proto.Term.TermType.GET,
    "pluck": Proto.Term.TermType.PLUCK,
    "distinct": Proto.Term.TermType.DISTINCT,
    "add": Proto.Term.TermType.ADD,
    "sub": Proto.Term.TermType.SUB,
    "mul": Proto.Term.TermType.MUL,
    "div": Proto.Term.TermType.DIV,
    "mod": Proto.Term.TermType.MOD,
    "and": Proto.Term.TermType.AND,
    "or": Proto.Term.TermType.OR,
    "eq": Proto.Term.TermType.EQ,
    "ne": Proto.Term.TermType.NE,
    "gt": Proto.Term.TermType.GT,
    "lt": Proto.Term.TermType.LT,
    "ge": Proto.Term.TermType.GE,
    "le": Proto.Term.TermType.LE,
    "not": Proto.Term.TermType.NOT
   ];


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

  Term expr(T)(T expression) {
    JSONValue jexpr = this.parseArg(expression);

    this.query = new SimpleQuery(jexpr);
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
  auto opDispatch(string s, T...)(T args) {
    JSONValue jsv = null;

    static if(args.length > 0) {
      jsv = this.parseArg(args);
    }

    static if((s in dict) !is null) {
      this.setQuery(dict[s], jsv);
      return this;
    } else {
      return mixin("this._" ~ s ~ "(jsv)");
    }
  }

  auto opIndex(T)(T key) {
    this.setQuery(Proto.Term.TermType.BRACKET, JSONValue(key));
    return this;
  }

  private void clearCurrentQuery() {
    this.shall_clear_term = true;
  }

  private void setQuery(Proto.Term.TermType term_type, JSONValue arg) {
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

  private JSONValue parseArg(T)(T raw_arg) {
    JSONValue arg = raw_arg;
    if(arg.type == JSON_TYPE.ARRAY) {
      return JSONValue([JSONValue(Proto.Term.TermType.MAKE_ARRAY), arg]);
    } else {
      return arg;
    }
  }
}
