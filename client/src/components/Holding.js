var React = require('react');
var RJSDAQ = require('../RJSDAQ');

var PropTypes = React.PropTypes;

var Holding = React.createClass({
  propTypes: {
    cashHoldings: PropTypes.number.isRequired,
    price: PropTypes.number,
    symbol: PropTypes.string.isRequired,
    unitsHeld: PropTypes.number.isRequired,
  },
  getInitialState: function () {
    return {
      canSubmit: true,
      targetUnits: '',
    };
  },
  canBuy: function () {
    var targetUnits = this.state.targetUnits;
    if (targetUnits === '') {
      return false;
    }
    return (targetUnits * this.props.price) <= this.props.cashHoldings;
  },
  canSell: function () {
    var targetUnits = this.state.targetUnits;
    if (targetUnits === '') {
      return false;
    }
    return this.props.unitsHeld >= targetUnits;
  },
  canSubmit: function () {
    return this.state.canSubmit;
  },
  handleBuyClick: function (e) {
    if (this.canBuy()) {
      this.setState({
        canSubmit: false,
      });
      RJSDAQ.buy(
        this.props.symbol,
        parseInt(this.state.targetUnits, 10),
        this.handleResponse
      );
    }
  },
  handleSellClick: function (e) {
    if (this.canSell()) {
      this.setState({
        canSubmit: false,
      });
      RJSDAQ.sell(
        this.props.symbol,
        parseInt(this.state.targetUnits, 10),
        this.handleResponse
      );
    }
  },
  handleResponse: function (err) {
    if (err) {
      alert(err);
    }
    this.setState({
      canSubmit: true,
      targetUnits: '',
    });
  },
  handleUnitsInputChange: function(e) {
    var value = e.target.value;
    if (/^(|[1-9]+[0-9]*)$/.test(value)) {
      this.setState({
        targetUnits: value,
      });
    }
  },
  render: function() {
    var targetUnitCost = (
      (parseInt(this.state.targetUnits || 0, 10) * this.props.price) / 100
    ).toFixed(2);
    return (
      <tr>
        <th>{this.props.symbol.toUpperCase()}</th>
        <td>
          {this.props.unitsHeld} unit{this.props.unitsHeld === 1 ? '' : 's'}
        </td>
        <td>
          <input
            disabled={!this.canSubmit()}
            onChange={this.handleUnitsInputChange}
            type="text"
            value={this.state.targetUnits}
          />
          {' '}
          <button
            className="buy"
            data-tooltip={'Cost: $' + targetUnitCost}
            disabled={!(this.canSubmit() && this.canBuy())}
            onClick={this.handleBuyClick}>
            Buy
          </button>
          {' '}
          <button
            className="sell"
            data-tooltip={'Earn: $' + targetUnitCost}
            disabled={!(this.canSubmit() && this.canSell())}
            onClick={this.handleSellClick}>
            Sell
          </button>
        </td>
      </tr>
    );
  }
});

module.exports = Holding;
