module rethinkdb.connection;

import std.stdio, std.socket, std.socketstream, std.stream, std.string, std.conv;
import rethinkdb.proto, rethinkdb.response;

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

  string readRaw() {
    char[1024] buffer;
    auto received = this.socket.receive(buffer);

    // substracting 1 from received because last characted should be null
    auto response = buffer[0..received-1];
    return to!string(response);
  }

  string readQueryResponse() {
    ulong token;
    uint length;
    ubyte[] buffer;

    this.stream.read(length);
    buffer.length = length;

    this.stream.read(buffer);

    auto response = new Proto.Response(buffer);
    return response.toJson();
  }

  void writeQuery(Proto.Term term) {
    auto query = new Proto.Query();
    query.type = Proto.Query.QueryType.START;
    query.token = this.getQueryToken();
    query.query = term;

    auto serialized_query = query.serialize();

    this.write(cast(uint)(serialized_query.length));
    this.write(serialized_query);
  }

  void write(int value) {
    this.stream.write(value);
  }

  void write(ubyte[] value) {
    foreach(bt; value) {
      this.stream.write(bt);
    }
  }

  private bool performHanshake() {
    Proto.VersionDummy vdm;

    this.write(cast(uint) vdm.Version.V0_4);
    this.write(cast(uint) 0);
    this.write(cast(uint) vdm.Protocol.PROTOBUF);

    if(this.readRaw() == "SUCCESS")
      return true;
    else
      return false;
  }

  private ulong getQueryToken() {
    return ++this.queryToken;
  }
}
