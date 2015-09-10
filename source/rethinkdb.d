module rethinkdb.rethinkdb;
import rethinkdb.connection;

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
}
