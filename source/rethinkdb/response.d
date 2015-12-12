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

  JSONValue opIndex(int index) {
    // hellish solution, but we don't want to respect arrays within arrays as
    // sane results for simple values
    auto value = this.value();
    if(value.length == 1 && value[0].type == JSON_TYPE.ARRAY) {
      return value[0][index];
    } else {
      return value[index];
    }
  }

  string str() {
    return this.value()[0].str();
  }

  @property
  long integer() {
    return this.value()[0].integer;
  }

  @property
  JSONValue[] array() {
    return this.value()[0].array;
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
    if(this.value().length > 0 && this.realValue.type == JSON_TYPE.ARRAY) {
      return this.array().length;
    } else {
      return this.value().length;
    }
  }

  override string toString() {
    JSONValue response = this.response["r"];
    return response.toString();
  }

  private {
    @property
    JSONValue realValue() {
      return this.value()[0];
    }
  }
}
