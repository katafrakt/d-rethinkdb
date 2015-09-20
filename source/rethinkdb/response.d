module rethinkdb.response;
import std.json, std.conv;

class Response {
  private string string_response;
  JSONValue value;
  int status;


  this(string response) {
    this.string_response = response;
  }

  Response parse() {
    this._parse();
    return this;
  }

  override string toString() {
    if(this.value.array().length == 0)
      return null; // empty string? null? something smarter?

    auto type = this.value[0].type();
    if(type == JSON_TYPE.STRING) {
      return this.value[0].str;
    } else {
      return toJSON(&this.value);
    }
  }

  private void _parse() {
    JSONValue j = parseJSON(this.string_response);
    this.status = to!int(j["t"].integer);
    this.value = j["r"];
  }
}
