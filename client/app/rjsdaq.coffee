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
fireEvent = (eventName, data...) ->
  return unless (callbacks = eventCallbacks[eventName])?

  # Notify listeners
  cb(data...) for cb in callbacks

handleToken = (err, authToken) ->
  console.log 'handling', err, authToken
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

# Public methods
connect = (ip, port = 5000, schema = 'ws') ->
  currentState = websocket?.readyState
  if currentState? and (currentState is websocket.CONNECTING or currentState is websocket.OPEN)
    console.warn "Socket already open"
    return

  # Connect to the server
  websocket = new WebSocketImplementation("#{schema}://#{ip}:#{port}")

  # Attach event handlers
  websocket.onopen = handleOpen
  websocket.onclose = handleClose
  websocket.onmessage = handleMessage
  websocket.onerror = handleError

subscribe = (eventName, cb) ->
  return unless typeof cb is 'function'
  return cb() if eventName is 'ready' and isAuthenticated
  (eventCallbacks[eventName] ?= []).push cb

buy = (symbol, quantity, cb) -> send('Buy', symbol: symbol, quantity: quantity, cb)
sell = (symbol, quantity, cb) -> send('Sell', symbol: symbol, quantity: quantity, cb)
goPublic = (symbol, name, cb) -> send('GoPublic', symbol: symbol, name: name, cb)

module.exports =
  connect: connect
  on: subscribe
  buy: buy
  sell: sell
  goPublic: goPublic
