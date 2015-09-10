module rethinkdb.connection;

import std.stdio, std.socket, std.socketstream, std.stream, std.string, std.conv;
import rethinkdb.proto;

class Connection {
  string hostname;
  ushort port;

  this(string hostname, ushort port) {
    this.hostname = hostname;
    this.port = port;
  }

  bool connect() {
    auto socket = new TcpSocket(AddressFamily.INET);
    auto inet = new InternetAddress(to!(char[])(this.hostname), this.port);
    socket.connect(inet);
    scope(exit) socket.close();

    Stream ss = new SocketStream(socket);

    VersionDummy vdm;

    ss.write(cast(uint) vdm.Version.V0_4);
    ss.write(cast(uint) 0);
    ss.write(cast(uint) vdm.Protocol.JSON);


    char[1024] buffer;
    socket.receive(buffer);

    if(to!string(buffer[0..7]) == "SUCCESS")
      return true;
    else
      return false;
  }
}
