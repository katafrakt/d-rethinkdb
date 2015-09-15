module rethinkdb.proto;
import dproto.dproto;

const proto_def = import("ql2.proto");

struct Proto {
  mixin ProtocolBufferFromString!proto_def;
}
