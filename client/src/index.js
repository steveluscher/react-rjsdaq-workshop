var React = require('react');
var RJSDAQ = require('./RJSDAQ');

var SERVER_ADDRESS = 'localhost';
var SERVER_PORT = 5000;

// Connect to the server
RJSDAQ.connect(SERVER_ADDRESS, SERVER_PORT, function(newData) {
  // This function will be called every time new data becomes available
});

/* The following are commands that you can issue to the server
*
* - Buy (eg. 10 units of 'fxs')
*
*   RJSDAQ.buy('fxs', 10, function(err) { console.log(err); });
*
* - Sell (eg. 50 units of 'bny')
*
*   RJSDAQ.sell('bny', 50, function(err) { console.log(err); });
*
* - Go Public (ie. List your own security with a 3-letter symbol and a name)
*
*   RJSDAQ.goPublic('bik', 'Bikes', function(err) { console.log(err); });
*
*/
