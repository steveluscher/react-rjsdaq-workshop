console.warn "Using the Coffeescript version of bootstrap.jsx; If you would like to use the Javascript version, simply delete app/assets/bootstrap.jsx.coffee"

RJSDAQ = require 'rjsdaq'

SERVER_ADDRESS = 'localhost'
SERVER_PORT = 5000
SERVER_SCHEMA = 'ws'

module.exports = ->
  # Connect to the server
  RJSDAQ.connect(SERVER_ADDRESS, SERVER_PORT, SERVER_SCHEMA)

  # Handle some connection events
  RJSDAQ.on 'connect', -> console.log 'Connected to server'
  RJSDAQ.on 'disconnect', -> console.log 'Disconnected from server'
  RJSDAQ.on 'error', (evt) -> console.error 'Error:', evt.data

  # Handle some server messages
  RJSDAQ.on 'securityPriceUpdated', (securitySymbol, securityPrice) ->
    console.log 'The price of', securitySymbol.toUpperCase(), 'was updated to', securityPrice

  RJSDAQ.on 'securityListed', (securitySymbol, securityName) ->
    console.log 'A new security named', securityName, 'was listed under the symbol', securitySymbol.toUpperCase()

  RJSDAQ.on 'securityHoldingsUpdated', (securitySymbol, securityUnitsHeld) ->
    console.log 'We now hold', securityUnitsHeld, 'units of', securitySymbol.toUpperCase()

  RJSDAQ.on 'cashHoldingsUpdated', (holdingsCents) ->
    console.log 'We now hold', holdingsCents, 'cents in cash'

  # This method will get called when the RJSDAQ is ready to go
  RJSDAQ.on 'ready', (seedData) -> console.log 'Ready'

  # The following are commands that you can issue to the server

  # Buy
  # eg. 10 units of 'fxs'
  # RJSDAQ.buy 'fxs', 10, (err) -> console.log err

  # Sell
  # eg. 50 units of 'bny'
  # RJSDAQ.sell 'bny', 50, (err) -> console.log err

  # Go Public
  # ie. List your own security with a 3-letter symbol and a name
  # RJSDAQ.goPublic 'bik', 'Bikes', (err) -> console.log err
