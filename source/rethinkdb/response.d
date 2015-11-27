module rethinkdb.response;
import std.json, std.conv;
import rethinkdb.proto, rethinkdb.datum;

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

  string stringValue() {
    return this.value()[0].str();
  }

  JSONValue objValue() {
    return parseJSON(this.value()[0].str());
  }

  JSONValue[] value() {
    return this.response["r"].array();
  }

  ulong token() {
    return this._token;
  }



  override string toString() {
    return this.response["r"].str();
  }
}
