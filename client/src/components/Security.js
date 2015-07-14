var React = require('react');

var Security = React.createClass({
  render: function() {
    return (
      <li>
        <h2>Bunnies <small>(BNY)</small></h2>
        <p className="price">33¢</p>

        <p className="lastUpdated">Updated 36s ago</p>

        <ul className="quotes">
          <li style={{height: '59.09%'}}>42¢</li>
          <li style={{height: '63.18%'}}>43¢</li>
          <li style={{height: '87.72%'}}>49¢</li>
          <li style={{height: '91.82%'}}>50¢</li>
          <li style={{height: '95.91%'}}>51¢</li>
          <li style={{height: '100%'}}>52¢</li>
          <li style={{height: '63.18%'}}>43¢</li>
          <li style={{height: '18.18%'}}>32¢</li>
          <li style={{height: '10%'}}>30¢</li>
          <li style={{height: '22.27%'}}>33¢</li>
        </ul>

        <section className="analytics">
          <h3>Change</h3>
          <p className="change increasing">+10.0%</p>

          <h3>Trend</h3>
          <p className="trend decreasing">-36.5%</p>
        </section>
      </li>
    );
  }
});

module.exports = Security;
