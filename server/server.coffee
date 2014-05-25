WebSocketServer = require("ws").Server
http = require 'http'
guid = require 'guid'
extend = require 'extend'

{ isInteger } = require './utils'
Market = require './market'
Bank = require './bank'

# Constants
PORT = 5000

# Keep track of users and their connected sockets
socketsByAuthToken = {}

# Keep track of clients by ID
nextClientId = 0

# Log header for debugging
getLogHeader = (ws) ->
  "[Server – Client #{ws.clientId} (#{if ws.userAuthToken? then "#{ws.userAuthToken}" else 'Unauthenticated'})] "

# Send a message to all clients
broadcast = (command, data...) ->
  send(ws, command, data...) for ws in wss.clients

# Send messages
send = (wsOrAuthToken, command, data...) ->
  payload = [command]
  payload = payload.concat(data) if data.length

  string = JSON.stringify payload

  sockets =
    if typeof wsOrAuthToken is 'string'
      # Grab all of the sockets this user has connected
      socketsByAuthToken[wsOrAuthToken]
    else
      # Just this socket alone
      [wsOrAuthToken]

  for ws in sockets
    ws.send string, (err) ->
      if err
        console.log "#{getLogHeader(ws)}Error sending message: #{err.message}"
      else
        console.log "#{getLogHeader(ws)}Message sent: #{payload}"

# Respond to request-response type commands
respond = (ws, requestId, err, data...) ->
  payload = [requestId]
  payload.push(err) if err? or data.length
  payload = payload.concat(data) if data.length

  send(ws, 'Response', payload...)

# Method to get seed data
getSeedData = (ws) ->
  # Get the securities, and the units held of each by this socket's user
  securities = {}
  for symbol, securityData of Market.getSecurities()
    securities[symbol] = unitsHeld: Bank.getSecurityHoldings(ws.userAuthToken, symbol)
    extend securities[symbol], securityData

  # Return the seed data
  cashHoldings: Bank.getCashHoldings(ws.userAuthToken)
  securities: securities

# Authentication assertions
assertAuthenticated = (ws) -> ws.userAuthToken?
assertUnauthenticated = (ws) -> not assertAuthenticated(ws)

# Argument validators
validateSymbol = (putativeSymbol) -> typeof putativeSymbol is 'string' and putativeSymbol.length is 3
validateQuantity = (putativeQuantity) -> isInteger(putativeQuantity)
validateName = (putativeName) -> typeof putativeName is 'string' and putativeName.length > 0

# Methods to authenticate and deauthenticate sockets
authenticateSocket = (ws, authenticatingUserId) ->
  # Store the auth token
  ws.userAuthToken = authenticatingUserId

  # Index this socket by auth token
  (socketsByAuthToken[authenticatingUserId] ?= []).push(ws)

  # Plug this socket into the market
  Market.subscribe ws.marketListener

deauthenticateSocket = (ws) ->
  # Remove this socket from the index
  indexedSockets = (socketsByAuthToken[ws.userAuthToken] ?= [])
  socketIndex = indexedSockets.indexOf(ws)
  indexedSockets.splice(socketIndex, 1) unless socketIndex is -1

  # Unplug this socket from the market
  Market.unsubscribe ws.marketListener

# Socket event handlers
handleSocketConnection = (ws) ->
  # Assign the client an ID
  ws.clientId = nextClientId++

  # A method to subscribe to the market
  ws.marketListener = (eventName, data...) -> send(ws, eventName, data...)

  console.log "#{getLogHeader(ws)}Connected"

  ws.on 'message', handleSocketMessage
  ws.on 'close', handleSocketClose

handleSocketMessage = (message) ->
  # Try to parse the message as JSON
  try
    [ requestId, command, data ] = JSON.parse message
    console.log "#{getLogHeader(this)}Received a #{command} command: #{data} with requestId #{requestId}"
  catch error
    console.error "#{getLogHeader(this)}Received malformed message: “#{message}”"

  switch command
    when 'Buy'
      unless assertAuthenticated(this)
        console.warn "#{getLogHeader(this)}Unauthenticated client tried to issue a Buy command"
        break

      # Unpack the request
      { symbol, quantity } = data

      # Validate
      symbolIsValid = validateSymbol(symbol)
      quantityIsValid = validateQuantity(quantity)
      unless symbolIsValid and quantityIsValid
        if requestId?
          errorString = "You supplied invalid arguments to the Buy command:"
          errorString += " symbol must be a three-character string." unless symbolIsValid
          errorString += " quantity must be an integer." unless quantityIsValid
          respond(this, requestId, errorString)
        break

      # Make the purchase
      Bank.purchaseSecurity @userAuthToken, symbol, quantity, (err, securityHoldingsAfterPurchase, cashHoldingsAfterPurchase) =>
        if err
          respond(this, requestId, err) if requestId?
        else
          send(@userAuthToken, 'CashHoldingsUpdated', cashHoldingsAfterPurchase)
          send(@userAuthToken, 'SecurityHoldingsUpdated', symbol, securityHoldingsAfterPurchase)
          respond(this, requestId) if requestId?

    when 'Sell'
      unless assertAuthenticated(this)
        console.warn "#{getLogHeader(this)}Unauthenticated client tried to issue a Sell command"
        break

      # Unpack the request
      { symbol, quantity } = data

      # Validate
      symbolIsValid = validateSymbol(symbol)
      quantityIsValid = validateQuantity(quantity)
      unless symbolIsValid and quantityIsValid
        if requestId?
          errorString = "You supplied invalid arguments to the Sell command:"
          errorString += " symbol must be a three-character string." unless symbolIsValid
          errorString += " quantity must be an integer." unless quantityIsValid
          respond(this, requestId, errorString)
        break

      # Make the sale
      Bank.sellSecurity @userAuthToken, symbol, quantity, (err, securityHoldingsAfterSale, cashHoldingsAfterSale) =>
        if err
          respond(this, requestId, err) if requestId?
        else
          send(@userAuthToken, 'CashHoldingsUpdated', cashHoldingsAfterSale)
          send(@userAuthToken, 'SecurityHoldingsUpdated', symbol, securityHoldingsAfterSale)
          respond(this, requestId) if requestId?

    when 'GoPublic'
      unless assertAuthenticated(this)
        console.warn "#{getLogHeader(this)}Unauthenticated client tried to issue a GoPublic command"
        break

      # Unpack the request
      { symbol, name } = data

      # Validate
      symbolIsValid = validateSymbol(symbol)
      nameIsValid = validateName(name)
      unless symbolIsValid and nameIsValid
        if requestId?
          errorString = "You supplied invalid arguments to the GoPublic command:"
          errorString += " symbol must be a three-character string." unless symbolIsValid
          errorString += " name must be a non-blank string." unless nameIsValid
          respond(this, requestId, errorString)
        break

      # List the security
      Market.listSecurity symbol, name, (err, securitySymbol, securityName) =>
        if err
          respond(this, requestId, err) if requestId?
        else
          broadcast('SecurityListed', securitySymbol, securityName)
          respond(this, requestId) if requestId?

    when 'GetToken'
      unless assertUnauthenticated(this)
        console.warn "#{getLogHeader(this)}Already-authenticated client asked for an auth token"
        break

      unless requestId?
        console.error "#{getLogHeader(this)}GetToken command issued without a request ID; we have no way of returning the ID to the client"
        break

      # Allocate a new auth token
      freshAuthToken = guid.raw()

      console.log "#{getLogHeader(this)}Issuing auth token #{freshAuthToken}"

      # Authenticate this socket
      authenticateSocket(this, freshAuthToken)

      # Let the client know what its auth token is
      respond(this, requestId, null, freshAuthToken)

    when 'AuthenticateWithToken'
      unless assertUnauthenticated(this)
        console.warn "#{getLogHeader(this)}Already-authenticated client asked to authenticate with token #{data}"
        break

      unless requestId?
        console.error "#{getLogHeader(this)}AuthenticateWithToken command issued without a request ID; we have no way of returning the token to the client"
        break

      if typeof data isnt 'string'
        console.error "#{getLogHeader(this)}Received a malformed token"
        respond(this, requestId, "#{data} is not a valid authentication token")
        break

      else
        console.log "#{getLogHeader(this)}Client authenticating with token #{data}"

        # Authenticate this socket
        authenticateSocket(this, data)

        # Send the client some seed data
        respond(this, requestId, null, getSeedData(this))

    else console.warn "#{getLogHeader(this)}Unrecognized command “#{command}”"

handleSocketClose = ->
  deauthenticateSocket(this)
  console.log "#{getLogHeader(this)}Disconnected"

# Create a websocket server
wss = new WebSocketServer(port: PORT)
wss.on "connection", handleSocketConnection

# Log the start of the market
console.log "RJSDAQ server running at port #{PORT}\n"
