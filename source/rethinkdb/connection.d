module rethinkdb.connection;

import std.stdio, std.socket, std.socketstream, std.stream, std.string, std.conv;
import rethinkdb.proto;

class Connection {
  private string hostname;
  private ushort port;
  private TcpSocket socket;
  private Stream stream;

  this(string hostname, ushort port) {
    this.hostname = hostname;
    this.port = port;
  }

  bool connect() {
    this.socket = new TcpSocket(AddressFamily.INET);
    auto inet = new InternetAddress(to!(char[])(this.hostname), this.port);
    this.socket.connect(inet);
    scope(exit) this.socket.close();

    this.stream = new SocketStream(this.socket);

    return this.performHanshake();
  }

  string read() {
    char[1024] buffer;
    auto received = this.socket.receive(buffer);

    // substracting 1 from received because last characted should be null
    auto response = buffer[0..received-1];

    return to!string(response);
  }

  void write(uint value) {
    this.stream.write(value);
  }

  private bool performHanshake() {
    VersionDummy vdm;

    this.write(cast(uint) vdm.Version.V0_4);
    this.write(cast(uint) 0);
    this.write(cast(uint) vdm.Protocol.JSON);

    if(this.read() == "SUCCESS")
      return true;
    else
      return false;
  }
}
