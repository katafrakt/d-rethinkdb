module rethinkdb.response;
import std.json, std.conv;
import rethinkdb.proto, rethinkdb.datum;

class Response {
  private {
    Proto.Response proto_response;
    Datum _response;
  }

  this(Proto.Response response) {
    this.proto_response = response;
  }

  bool isSuccess() {
    auto type = this.proto_response.type;
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
    return new Datum(this.proto_response.response[0]).stringValue();
  }

  Datum[string] objValue() {
    return new Datum(this.proto_response.response[0]).objValue();
  }

  ulong token() {
    return to!ulong(this.proto_response.token);
  }

  override string toString() {
    Proto.Datum response_datum = this.proto_response.response[0];
    Datum value = new Datum(response_datum);
    return value.inspect();
  }
}
