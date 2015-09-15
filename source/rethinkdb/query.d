module rethinkdb.query;
import std.conv;

class Query {
  private string simple_query = null;
  private Query wrapped_query = null;
  private int query_type;

  this(int query_type, string simple_query) {
    this.query_type = query_type;
    this.simple_query = simple_query;
  }

  this(int query_type, Query query) {
    this.query_type = query_type;
    this.wrapped_query = query;
  }

  string serialize() {
    if(wrapped_query is null) {
      return "[" ~ to!string(this.query_type) ~ ", \"" ~ this.simple_query ~ "\", {}]";
    } else {
      // ???
      return "";
    }
  }
}
