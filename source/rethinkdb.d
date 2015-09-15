module rethinkdb.rethinkdb;
import rethinkdb.connection, rethinkdb.term;

class RethinkDB {
  Connection connection;
  bool is_connected;

  this(string hostname = "localhost", ushort port = 28015) {
    this.connection = new Connection(hostname, port);

    if(this.connection.connect()) {
      this.is_connected = true;
    } else {
      this.is_connected = false;
    }
  }

  // core of the magic: dispatch all unhandled methods to new Term
  auto opDispatch(string s, T...)(T t) {
    auto term = new Term(this);
    return mixin("term." ~ s ~ "(t)");
  }
}
