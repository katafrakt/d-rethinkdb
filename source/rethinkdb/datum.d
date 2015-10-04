module rethinkdb.datum;
import std.conv, std.stdio;
import rethinkdb.proto;

class Datum {
  static Proto.Datum build(string str) {
    auto datum = new Proto.Datum();
    datum.type = Proto.Datum.DatumType.R_STR;
    datum.r_str = str;
    return *datum;
  }

  private Proto.Datum proto_datum;

  this(Proto.Datum datum) {
    this.proto_datum = datum;
  }

  string stringValue() {
    return this.proto_datum.r_str;
  }

  double numValue() {
    return this.proto_datum.r_num;
  }

  bool boolValue() {
    return this.proto_datum.r_bool;
  }

  Datum[string] objValue() {
    return this.parseObject(this.proto_datum.r_object);
  }

  Datum[] arrayValue() {
    return this.parseArray(this.proto_datum.r_array);
  }

  string inspect() {
    auto type = this.proto_datum.type;
    alias DT = Proto.Datum.DatumType;
    if(type == DT.R_STR) {
      return this.stringValue();
    } else if(type == DT.R_NULL) {
      return "null"; // TODO: convert to exception
    } else if(type == DT.R_BOOL) {
      return to!string(this.boolValue());
    } else if(type == DT.R_NUM) {
      return to!string(this.numValue());
    } else if(type == DT.R_ARRAY) {
      writeln(this.proto_datum.toJson());
      return "array";
    } else if(type == DT.R_OBJECT) {
      auto assoc = parseObject(this.proto_datum.r_object);
      return to!string(assoc);
    } else {
      writeln("TYPE: " ~ to!string(type));
      return "UNKNOWN TYPE";
    }
  }

  override string toString() {
    return this.inspect();
  }

  private Datum[string] parseObject(Proto.Datum.AssocPair[] obj) {
    Datum[string] array;
    foreach(kv; obj) {
      array[kv.key] = new Datum(kv.val);
    }

    return array;
  }

  private Datum[] parseArray(Proto.Datum[] ary) {
    Datum[] array = [];
    foreach(datum; ary) {
      array[array.length] = new Datum(datum);
    }
    return array;
  }
}
