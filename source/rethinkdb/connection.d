module rethinkdb.connection;

import std.stdio, std.socket, std.socketstream, std.stream, std.string, std.conv;
import rethinkdb.proto;

class Connection {
  private string hostname;
  private ushort port;
  private Socket socket;
  private Stream stream;
  private uint queryToken;

  this(string hostname, ushort port) {
    this.hostname = hostname;
    this.port = port;
    this.queryToken = 0;
  }

  bool connect() {
    this.socket = new TcpSocket(AddressFamily.INET);
    auto inet = new InternetAddress(to!(char[])(this.hostname), this.port);
    this.socket.connect(inet);
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

  string readQueryResponse() {
    ulong token;
    uint length;
    char[] buffer;

    this.stream.read(token);
    this.stream.read(length);

    buffer = this.stream.readString(length);
    return to!string(buffer);
  }

  void writeQuery(string queryString) {
    auto token = this.getQueryToken();
    auto length = queryString.length;
    auto query = to!(char[])(queryString);

    this.write(token);
    this.write(to!uint(length));
    this.write(query);
  }

  void write(int value) {
    this.stream.write(value);
  }

  void write(ulong value) {
    this.stream.write(value);
  }

  void write(char[] value) {
    this.stream.writeString(value);
  }

  private bool performHanshake() {
    Proto.VersionDummy vdm;

    this.write(cast(uint) vdm.Version.V0_4);
    this.write(cast(uint) 0);
    this.write(cast(uint) vdm.Protocol.JSON);

    if(this.read() == "SUCCESS")
      return true;
    else
      return false;
  }

  private ulong getQueryToken() {
    return ++this.queryToken;
  }
}
