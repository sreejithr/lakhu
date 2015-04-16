var Q = require('q');
var Native = require('NativeModules');

function Lakhu() {
  var self = this;
  this.db = Native.Lakhu;
  return this;
};

Lakhu.prototype.connect = function(config) {
  var filename = config['filename'];
  return Q.nfcall(self.db.connect, filename);
};

Lakhu.prototype.query = function(query) {
  for (var cmd in query.split(' ')) {
    switch (cmd.toLowerCase()) {
    case 'select':
      return Q.nfcall(self.db.executeSelectQuery, query);

    case 'insert':
      return Q.nfcall(self.db.executeUpdateQuery, query);

    case 'delete':
      return Q.nfcall(self.db.executeUpdateQuery, query);
    }
  }
  return Q.fcall(() => (new Error("Invalid query statement"), null));
};

module.exports = Lakhu;
