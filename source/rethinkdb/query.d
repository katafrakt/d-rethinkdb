module rethinkdb.query;
import std.conv, std.json, std.stdio;
import rethinkdb.proto;

class Query {
  private Query wrapped_query = null;
  private int query_type;
  private string options = null;
  private JSONValue argument = null;

  this(int query_type, Query query, JSONValue argument, string options = null) {
    this.query_type = query_type;
    this.wrapped_query = query;
    this.argument = argument;
    this.options = options;
  }

  this(int query_type, JSONValue argument, string options = null) {
    this.query_type = query_type;
    this.argument = argument;
    this.options = options;
  }

  string serialize() {
    string arguments;
    if(wrapped_query is null) {
      if(this.argument.type == JSON_TYPE.OBJECT) {
        arguments = this.argument.str();
      } else {
        arguments = this.argument.toString();
      }
    } else {
      arguments = wrapped_query.serialize();
      if(!this.argument.isNull()) {
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

  private string formatArg(JSONValue arg) {
    return arg.toString();
  }

  private string quote(string str) {
    return "\"" ~ str ~ "\"";
  }

  private string quote(JSONValue str) {
    return str.toString();
  }

  private string wrapInArray(string str) {
      return "[" ~ str ~ "]";
  }
}

class SimpleQuery : Query {
  private JSONValue simple_query;

  this(JSONValue expr) {
    super(1, this, JSONValue("")); // apparently D is weird about this
    this.simple_query = expr;
  }

  override string serialize() {
    return this.simple_query.toString();
  }
}
