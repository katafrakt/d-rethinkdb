module rethinkdb.datum;

import rethinkdb.proto;

struct Datum {
  static Proto.Datum build(string str) {
    auto datum = new Proto.Datum();
    datum.type = Proto.Datum.DatumType.R_STR;
    datum.r_str = str;
    return *datum;
  }
}
