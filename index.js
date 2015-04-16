var Q = require('q');
var Native = require('NativeModules');

function Lakhu() {
  var that = this;
  this._conn = Native.Lakhu;
  return this;
};

Lakhu.prototype.connect = function(config) {
  var filename = config['filename'];
  return Q.nfcall(this._conn.connect, filename);
};

Lakhu.prototype.query = function(query) {
  return Q.nfcall(this._conn.executeSelectQuery, query);
};

module.exports = Lakhu;
