module rethinkdb.term;
import rethinkdb.rethinkdb, rethinkdb.connection;

class Term {
  private RethinkDB driver;
  private string current_query;

  this(RethinkDB driver) {
    this.driver = driver;
  }

  Term expr(string expression) {
    this.current_query = "[1, \"" ~ expression ~ "\", {}]";
    return this;
  }

  string run() {
    return this.run(this.driver.connection);
  }

  string run(Connection connection) {
    connection.writeQuery(this.current_query);
    return connection.readQueryResponse();
  }
}
