update = require('react/addons').addons.update;

TOKEN_STORAGE_KEY = 'authToken'

isAuthenticated = false
nextRequestId = 0
requestCallbacks = {}
eventCallbacks = {}
websocket = null

# Make sure we have a websocket implementation available
unless (WebSocketImplementation = window.WebSocket or window.MozWebSocket)?
  alert("Could not find a WebSocket implementation.")

# Socket event handlers
handleOpen = (evt) ->
  console.debug "Socket connected", evt
  fireEvent('connect', evt)

  storedUserId = localStorage.getItem(TOKEN_STORAGE_KEY)
  if typeof storedUserId is 'string'
    send "AuthenticateWithToken", storedUserId, handleAuthentication
  else
    send "GetToken", null, handleToken

handleClose = (evt) ->
  console.debug "Socket closing", evt
  fireEvent('disconnect', evt)

handleMessage = (evt) ->
  console.debug "Received a message", evt.data

  [ command, data... ] = JSON.parse evt.data

  if command is 'Response'
    [ requestId, responseError, responseData ] = data
    callback = requestCallbacks[requestId]
    callback?(responseError, responseData)
    delete requestCallbacks[requestId]

  else
    fireEvent("#{command[0].toLowerCase()}#{command.slice(1)}", data...)

handleError = (evt) ->
  console.error "Socket error", evt
  fireEvent('error', evt)

# Private utilities
bootstrap = (ip, port = 5000, scheme = 'ws') ->
  currentState = websocket?.readyState
  if currentState? and (currentState is websocket.CONNECTING or currentState is websocket.OPEN)
    console.warn "Socket already open"
    return

  # Connect to the server
  websocket = new WebSocketImplementation("#{scheme}://#{ip}:#{port}")

  # Attach event handlers
  websocket.onopen = handleOpen
  websocket.onclose = handleClose
  websocket.onmessage = handleMessage
  websocket.onerror = handleError

fireEvent = (eventName, data...) ->
  return unless (callbacks = eventCallbacks[eventName])?

  # Notify listeners
  cb(data...) for cb in callbacks

handleToken = (err, authToken) ->
  console.debug 'handling', err, authToken
  if err?
    console.error("Error authenticating", err)
    localStorage.removeItem(TOKEN_STORAGE_KEY)
    return

  unless typeof authToken is 'string'
    console.error("Received a malformed auth token:", authToken)
    return

  isAuthenticated = true

  console.debug "Storing auth token #{authToken} in localStorage"
  localStorage.setItem(TOKEN_STORAGE_KEY, authToken)

  send "AuthenticateWithToken", authToken, handleAuthentication

handleAuthentication = (err, seedData) ->
  fireEvent('ready', seedData)

send = (command, data, cb) ->
  if typeof cb is 'function'
    requestId = nextRequestId++
    requestCallbacks[requestId] = cb

  payload = [ requestId, command ]
  payload = payload.concat(data) if data?

  string = JSON.stringify(payload)
  websocket.send string

subscribe = (eventName, cb) ->
  return unless typeof cb is 'function'
  return cb() if eventName is 'ready' and isAuthenticated
  (eventCallbacks[eventName] ?= []).push cb

# Public methods
buy = (symbol, quantity, cb) -> send('Buy', symbol: symbol, quantity: quantity, cb)
connect = (address, port, dataUpdateHandler) ->
    # Create a data store
    data = null

    # A helper to notify the caller of new data
    inform = -> dataUpdateHandler data

    # Connect to the server
    bootstrap address, port

    # Handle some connection events
    subscribe 'connect', -> console.log 'Connected to server'
    subscribe 'disconnect', -> console.log 'Disconnected from server'
    subscribe 'error', (evt) -> console.error 'Error:', evt.data

    # Handle some server messages
    subscribe 'securityPriceUpdated', (securitySymbol, securityPrice) ->
      console.log 'The price of', securitySymbol.toUpperCase(), 'was updated to', securityPrice

      # Construct an update operation
      updateOperation = { securities: {} }
      updateOperation.securities[securitySymbol] = { price: { $set: securityPrice } }

      # Update the data using the immutability helpers
      newData = update(data, updateOperation)

      # Replace the old data with the new data
      data = newData

      # Inform subscribers that the data has changed
      inform()

    subscribe 'securityListed', (securitySymbol, securityName) ->
      console.log 'A new security named', securityName, 'was listed under the symbol', securitySymbol.toUpperCase()

      # Construct an update operation
      updateOperation = { securities: {} }
      updateOperation.securities[securitySymbol] = { $set: { name: securityName, unitsHeld: 0 } }

      # Update the data using the immutability helpers
      newData = update(data, updateOperation)

      # Replace the old data with the new data
      data = newData

      # Inform subscribers that the data has changed
      inform()

    subscribe 'securityHoldingsUpdated', (securitySymbol, securityUnitsHeld) ->
      console.log 'We now hold', securityUnitsHeld, 'units of', securitySymbol.toUpperCase()

      # Construct an update operation
      updateOperation = { securities: {} }
      updateOperation.securities[securitySymbol] = { unitsHeld: { $set: securityUnitsHeld } }

      # Update the data using the immutability helpers
      newData = update(data, updateOperation)

      # Replace the old data with the new data
      data = newData

      # Inform subscribers that the data has changed
      inform()

    subscribe 'cashHoldingsUpdated', (holdingsCents) ->
      console.log 'We now hold', holdingsCents, 'cents in cash'

      # Construct an update operation
      updateOperation = { cashHoldings: { $set: holdingsCents } }

      # Update the data using the immutability helpers
      newData = update(data, updateOperation)

      # Replace the old data with the new data
      data = newData

      # Inform subscribers that the data has changed
      inform()

    # This method will get called when the RJSDAQ is ready to go
    subscribe 'ready', (seedData) ->
      console.log 'Ready'

      # Store the seed data
      data = seedData

      # Inform subscribers that the data has changed
      inform()
sell = (symbol, quantity, cb) -> send('Sell', symbol: symbol, quantity: quantity, cb)
goPublic = (symbol, name, cb) -> send('GoPublic', symbol: symbol, name: name, cb)

module.exports =
  connect: connect
  buy: buy
  sell: sell
  goPublic: goPublic
