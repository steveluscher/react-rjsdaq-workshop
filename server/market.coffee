class Market
  MAX_PRICE_CHANGE = 8 # cents
  MIN_UPDATE_INTERVAL_PER_SECURITY = 1000 # ms
  MAX_UPDATE_INTERVAL_PER_SECURITY = 10000 # ms

  getRandomTimeInterval = ->
    numSecurities = Object.keys(securities).length
    randomPerSecurityInterval = MIN_UPDATE_INTERVAL_PER_SECURITY + (Math.random() * (MAX_UPDATE_INTERVAL_PER_SECURITY - MIN_UPDATE_INTERVAL_PER_SECURITY))
    randomPerSecurityInterval / numSecurities

  # Storage for the security prices (with some defaults)
  securities =
    bny:
      name: 'Bunnies'
      price: 42
    fxs:
      name: 'Foxes'
      price: 77
    pce:
      name: 'Peaches'
      price: null

  # Storage for market subscribers
  subscribers = []

  # Method to broadcast price updates
  broadcastSecurityPriceUpdate = (symbol) ->
    return unless subscribers.length

    # Get the current price
    currentPrice = securities[symbol].price

    console.log '[Market] Broadcasting security price update', symbol, currentPrice, "to #{subscribers.length} subscriber(s)"

    # Send the update(s)
    subscriber('SecurityPriceUpdated', symbol, currentPrice) for subscriber in subscribers

  @start: ->
    run = =>
      # Revalue a random security
      @revalueRandomSecurity()
      
      # Schedule another random security update
      setTimeout run, getRandomTimeInterval()
    run()

  @getRandomSecurity: ->
    symbols = Object.keys(securities)
    randomSymbol = symbols[symbols.length * Math.random() << 0]
    randomSecurity = securities[randomSymbol]
    [randomSymbol, randomSecurity]

  @revalueRandomSecurity: ->
    # Choose a security at random to revalue
    [randomSymbol, randomSecurity] = @getRandomSecurity()

    # Choose a new price for the security
    sign = -1 + (Math.round(Math.random()) * 2)
    priceChange = sign * Math.ceil(Math.random() * MAX_PRICE_CHANGE)
    currentPrice = randomSecurity.price
    newPrice = currentPrice + priceChange

    # Ensure that
    # * the new price is in the interval [1, 99]
    # * the new price is different than the old price
    if newPrice < 1
      newPrice = if currentPrice is 1 then 2 else 1
    else if newPrice > 99
      newPrice = if currentPrice is 99 then 98 else 99

    # Set the price
    randomSecurity.price = newPrice

    # Message interested clients
    broadcastSecurityPriceUpdate(randomSymbol)

  @listSecurity: (symbol, name, cb) ->
    errors = undefined

    symbolIsValid = typeof symbol is 'string' and symbol.length is 3

    # Sanitize the symbol
    sanitizedSymbol = symbol.toLowerCase() if symbolIsValid

    unless symbolIsValid
      (errors ?= []).push 'symbol must be a three-character string'

    unless typeof name is 'string' and name.length > 0
      (errors ?= []).push 'name must be a non-empty string'

    if sanitizedSymbol? and securities[sanitizedSymbol]?
      (errors ?= []).push "A security with symbol #{sanitizedSymbol} is already listed on this exchange"

    if errors?
      console.error "[Market.listSecurity] #{error}" for error in errors
      return cb(errors)

    # List the security
    securities[sanitizedSymbol] = { name: name, price: null }

    cb(null, sanitizedSymbol, name)

  @getSecurities: -> securities

  @getSecurityPrice: (symbol) ->
    unless typeof symbol is 'string' and symbol.length is 3
      console.error "[Market.getSecurityPrice – #{authToken}] symbol must be a three-character string"
      return false

    unless security = securities[symbol.toLowerCase()]
      console.error "[Market] Could not find a security with symbol #{symbol}"
      return false

    # Return the price
    security.price

  @subscribe: (listener) ->
    subscribers.push(listener)
    console.log "[Market] Added a subscriber (now have #{subscribers.length})"

  @unsubscribe: (listener) ->
    listenerIndex = subscribers.indexOf(listener)
    subscribers.splice(listenerIndex, 1) unless listenerIndex is -1
    console.log "[Market] Removed a subscriber (now have #{subscribers.length})"

# Open the market for business
Market.start()

module.exports = Market
