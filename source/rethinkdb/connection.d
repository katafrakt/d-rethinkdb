module rethinkdb.connection;

import std.stdio, std.socket, std.socketstream, std.stream, std.string, std.conv;
import rethinkdb.proto;

class Connection {
  bool connect(string host = "localhost", ushort port = 28015) {
    auto socket = new TcpSocket(AddressFamily.INET);
  	socket.connect(new InternetAddress(to!(char[])(host), port));
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
