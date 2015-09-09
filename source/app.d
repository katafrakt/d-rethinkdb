import rethinkdb.connection;
import std.stdio;

void main()
{
	auto conn = new Connection();
	if(conn.connect()) {
		writeln("SUCCESS");
	} else {
		writeln("NOPE");
	}
}
