var React = require('react');

var Holding = React.createClass({
  render: function() {
    return (
      <tr>
        <th>BNY</th>
        <td>101 units</td>
        <td>
          <input type="text" />
          {' '}
          <button className="buy" disabled="disabled">Buy</button>
          {' '}
          <button className="sell" disabled="disabled">Sell</button>
        </td>
      </tr>
    );
  }
});

module.exports = Holding;
