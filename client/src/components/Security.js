var PriceAge = require('./PriceAge');
var React = require('react');

var PropTypes = React.PropTypes;

var Security = React.createClass({
  propTypes: {
    name: PropTypes.string.isRequired,
    price: PropTypes.number,
    symbol: PropTypes.string.isRequired,
    unitsHeld: PropTypes.number.isRequired,
  },
  getInitialState: function() {
    return {
      priceHistory: this.props.price == null
        ? []
        : [this.props.price],
    };
  },
  renderChange: function() {
    var priceHistory = this.state.priceHistory;
    if (priceHistory.length < 2) {
      return '–';
    } else {
      var latestPrice = priceHistory[priceHistory.length - 1];
      var previousPrice = priceHistory[priceHistory.length - 2];
      var changePercent = (100 * ((latestPrice - previousPrice) / previousPrice));
      var sign = changePercent < 0 ? '' : '+';
      var className = 'change ' + (changePercent < 0 ? 'decreasing' : 'increasing');
      return (
        <p className={className}>
          {sign + changePercent.toFixed(1)}
        </p>
      );
    }
  },
  componentWillReceiveProps: function(nextProps) {
    if (this.props.price !== nextProps.price) {
      var newPriceHistory = [].concat(this.state.priceHistory);
      newPriceHistory.push(nextProps.price);
      this.setState({
        priceHistory: newPriceHistory,
      });
    }
  },
  render: function() {
    var priceString = this.props.price == null
      ? '–'
      : this.props.price + '¢';
    return (
      <li>
        <h2>{this.props.name} <small>({this.props.symbol.toUpperCase()})</small></h2>
        <p className="price">{priceString}</p>

        <PriceAge price={this.props.price} />

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
          {this.renderChange()}

          <h3>Trend</h3>
          <p className="trend decreasing">-36.5%</p>
        </section>
      </li>
    );
  }
});

module.exports = Security;
