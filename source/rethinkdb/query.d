module rethinkdb.query;
import std.conv;
import rethinkdb.proto;

class Query {
  private Query wrapped_query = null;
  private int query_type;
  private string options = null;
  private string argument = null;

  this(int query_type, Query query, string argument, string options = null) {
    this.query_type = query_type;
    this.wrapped_query = query;
    this.argument = argument;
    this.options = options;
  }

  string serialize() {
    string arguments;
    if(wrapped_query is null) {
      arguments = this.quote(this.argument);
    } else {
      arguments = wrapped_query.serialize();
      if(this.argument !is null) {
        arguments = arguments ~ ", " ~ this.formatArg(this.argument);
      }
    }

    auto serialized = "[" ~ to!string(this.query_type) ~ ", " ~ this.wrapInArray(arguments);
    if(this.options !is null) {
      serialized = serialized ~ ", " ~ this.formatArg(this.options);
    }
    return serialized ~ "]";
  }

  private string formatArg(string arg) {
    auto first_char = arg[0];
    if(first_char == '[' || first_char == '{') {
      return arg;
    } else {
      return this.quote(arg);
    }
  }

  private string quote(string str) {
    return "\"" ~ str ~ "\"";
  }

  private string wrapInArray(string str) {
    return "[" ~ str ~ "]";
  }
}

class SimpleQuery : Query {
  private string simple_query;

  this(string expr) {
    super(1, this, ""); // apparently D is weird about this
    this.simple_query = expr;
  }

  override string serialize() {
    return this.quote(this.simple_query);
  }
}
