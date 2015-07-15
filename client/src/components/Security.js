var PriceAge = require('./PriceAge');
var React = require('react');

var PropTypes = React.PropTypes;

var GRAPH_BAR_MARGIN = 5;
var GRAPH_BAR_WIDTH = 18;

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
      graphWidth: null,
    };
  },
  _storeGraphWidth: function() {
    this.setState({
      graphWidth: React.findDOMNode(this.refs.priceGraph).clientWidth,
    });
  },
  componentDidMount: function() {
    this._storeGraphWidth();
    window.addEventListener('resize', this._storeGraphWidth);
  },
  componentWillUnmount: function() {
    window.removeEventListener('resize', this._storeGraphWidth);
  },
  renderChange: function() {
    var changeClass = 'change';
    var changeText;
    var priceHistory = this.state.priceHistory;
    if (priceHistory.length < 2) {
      changeText = '–';
    } else {
      var latestPrice = priceHistory[priceHistory.length - 1];
      var previousPrice = priceHistory[priceHistory.length - 2];
      var changePercent = (100 * ((latestPrice - previousPrice) / previousPrice));
      var sign = changePercent < 0 ? '' : '+';
      changeClass += changePercent < 0 ? ' decreasing' : ' increasing';
      changeText = sign + changePercent.toFixed(1) + '%';
    }
    return (
      <p className={changeClass}>
        {changeText}
      </p>
    );
  },
  renderPriceGraph: function() {
    var pricesToDisplay;
    if (this.state.graphWidth == null) {
      pricesToDisplay = this.state.priceHistory;
    } else {
      pricesToDisplay = this.state.priceHistory.slice(
        -Math.floor(
          (this.state.graphWidth - GRAPH_BAR_MARGIN) / (GRAPH_BAR_WIDTH + GRAPH_BAR_MARGIN)
        )
      );
    }
    var minPrice;
    var maxPrice;
    pricesToDisplay.forEach(function(price) {
      if (minPrice == null || price < minPrice) {
        minPrice = price;
      }
      if (maxPrice == null || price > maxPrice) {
        maxPrice = price;
      }
    });
    var delta = maxPrice - minPrice;
    return pricesToDisplay.map(function(price, i) {
      var heightPercent;
      if (delta === 0) {
        heightPercent = 100;
      } else {
        heightPercent = 10;
        heightPercent += 90 * (1 - ((maxPrice - price) / delta));
      }
      return (
        <li
          key={i}
          style={{height: heightPercent + '%'}}>
          {price}¢
        </li>
      );
    });
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

        <ul className="quotes" ref="priceGraph">
          {this.renderPriceGraph()}
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
