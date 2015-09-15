module rethinkdb.term;
import rethinkdb.rethinkdb, rethinkdb.connection, rethinkdb.query;

class Term {
  private RethinkDB driver;
  private Query current_query;

  this(RethinkDB driver) {
    this.driver = driver;
  }

  Term expr(string expression) {
    this.current_query = new Query(1, expression);
    return this;
  }

  string run() {
    return this.run(this.driver.connection);
  }

  string run(Connection connection) {
    connection.writeQuery(this.current_query.serialize());
    return connection.readQueryResponse();
  }
}
