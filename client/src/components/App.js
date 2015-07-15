var Holding = require('./Holding');
var React = require('react');
var Security = require('./Security');

var PropTypes = React.PropTypes;

var App = React.createClass({
  propTypes: {
    cashHoldings: PropTypes.number.isRequired,
    securities: PropTypes.objectOf(
      PropTypes.shape({
        name: PropTypes.string.isRequired,
        price: PropTypes.number,
        unitsHeld: PropTypes.number.isRequired,
      })
    ),
  },
  getInitialState: function() {
    return {
      sortKey: 'name',
      sortOrder: 'asc',
    };
  },
  _handleSortKeyChange: function(e) {
    this.setState({
      sortKey: e.target.value,
    });
  },
  _handleSortOrderChange: function(e) {
    this.setState({
      sortOrder: e.target.value,
    });
  },
  renderSecurity: function(symbol) {
    var security = this.props.securities[symbol];
    return (
      <Security
        key={symbol}
        name={security.name}
        price={security.price}
        symbol={symbol}
        unitsHeld={security.unitsHeld}
      />
    );
  },
  renderSecurities: function() {
    var securities = this.props.securities;
    var securitySymbols = Object.keys(this.props.securities);
    var sortOrder = this.state.sortOrder;
    var sortedSecuritySymbols;
    if (this.state.sortKey === 'name') {
      sortedSecuritySymbols = securitySymbols.sort(function(a, b) {
        if (sortOrder === 'desc') {
          return securities[a].name < securities[b].name;
        } else {
          return securities[b].name < securities[a].name;
        }
      });
    } else {
      sortedSecuritySymbols = securitySymbols.sort(function(a, b) {
        if (sortOrder === 'desc') {
          return securities[a].price < securities[b].price;
        } else {
          return securities[b].price < securities[a].price;
        }
      });
    }
    return sortedSecuritySymbols.map(this.renderSecurity);
  },
  render: function() {
    return (
      <div>
        <section className="console">
          <h1>The RJSDAQ</h1>

          <label htmlFor="sortKey">Sort by</label>
          {' '}
          <select
            id="sortKey"
            onChange={this._handleSortKeyChange}
            value={this.state.sortKey}>
            <option value="name">Name</option>
            <option value="price">Price</option>
          </select>
          {' '}
          <select
            id="sortOrder"
            onChange={this._handleSortOrderChange}
            value={this.state.sortOrder}>
            <option value="asc">Ascending</option>
            <option value="desc">Descending</option>
          </select>

          <h2>My portfolio</h2>

          <p>You have <strong>$100.00</strong> in cash reserves</p>

          <section id="portfolio">
            <table>
              <tbody>
                <Holding />
              </tbody>
            </table>
          </section>

          <h2>Go public</h2>
          <p>You've earned it</p>

          <form id="goPublic">
            <input id="newSecurityName" placeholder="Name (eg. Alphabet soup)" type="text" />
            <input id="newSecuritySymbol" placeholder="Symbol (eg. ABC)" type="text" />
            <input disabled="disabled" type="submit" value="Go public!" />
          </form>
        </section>

        <ul id="securities">
          {this.renderSecurities()}
        </ul>
      </div>
    );
  }
});

module.exports = App;
