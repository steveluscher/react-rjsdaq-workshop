var React = require('react');

var PropTypes = React.PropTypes;

var PriceAge = React.createClass({
  propTypes: {
    price: PropTypes.number,
  },
  getInitialState: function() {
    return {
      lastPriceUpdate: this.props.price == null
        ? null
        : Date.now(),
    };
  },
  componentDidMount: function() {
    this._intervalId = setInterval(this.forceUpdate.bind(this), 1000);
  },
  componentWillUnmount: function() {
    clearInterval(this._intervalId);
  },
  componentWillReceiveProps: function(nextProps) {
    if (this.props.price !== nextProps.price) {
      this.setState({lastPriceUpdate: Date.now()});
    }
  },
  render: function() {
    var priceAgeString;
    if (this.state.lastPriceUpdate) {
      var priceAgeSeconds = Math.floor(
        (Date.now() - this.state.lastPriceUpdate) / 1000
      );
      priceAgeString = priceAgeSeconds === 0
        ? 'just now'
        : priceAgeSeconds + 's ago';
    } else {
      priceAgeString = 'never';
    }
    return (
      <p className="lastUpdated">Updated {priceAgeString}</p>
    )
  }
});

module.exports = PriceAge;
