module rethinkdb.response;
import std.json, std.conv;
import rethinkdb.proto;

class Response {
  private {
    JSONValue response;
    ulong _token;
  }

  this(ulong token, string response) {
    this.response = parseJSON(response);
    this._token = token;
  }

  bool isSuccess() {
    auto type = this.response["t"].integer;
    if(type == Proto.Response.ResponseType.SUCCESS_ATOM ||
      type == Proto.Response.ResponseType.SUCCESS_SEQUENCE ||
      type == Proto.Response.ResponseType.SUCCESS_PARTIAL ||
      type == Proto.Response.ResponseType.WAIT_COMPLETE
      ) {
        return true;
      } else {
        return false;
      }
  }

  JSONValue opIndex(string key) {
    return this.objValue()[key];
  }

  string str() {
    return this.value()[0].str();
  }

  @property
  long integer() {
    return this.value()[0].integer;
  }

  JSONValue objValue() {
    return this.value()[0];
  }

  JSONValue[] value() {
    return this.response["r"].array();
  }

  ulong token() {
    return this._token;
  }

  @property
  ulong length() {
    return value().length;
  }

  override string toString() {
    JSONValue response = this.response["r"];
    return response.toString();
  }
}
