{ isInteger } = require './utils'
Market = require './market'

class Bank
  INITIAL_CASH_HOLDINGS = 100 * 100 # cents

  # Storage for the available holdings by user
  holdingsByAuthToken = {}

  # Private getter/setter for accounts
  getHoldingsForAuthToken = (authToken) -> holdingsByAuthToken[authToken] ?= {}
  getCashHoldings = (authToken) ->
    getHoldingsForAuthToken(authToken).cash ?= INITIAL_CASH_HOLDINGS
  setCashHoldings = (authToken, cents) ->
    getHoldingsForAuthToken(authToken).cash = cents
    return
  getSecurityHoldings = (authToken, symbol) ->
    getHoldingsForAuthToken(authToken)[symbol] ?= 0
  setSecurityHoldings = (authToken, symbol, units) ->
    getHoldingsForAuthToken(authToken)[symbol] = units
    return

  # Public methods
  @getCashHoldings: (authToken) ->
    unless typeof authToken is 'string'
      console.error "[Bank.getCashHoldings – #{authToken}] authToken must be a string"
      return false

    # Return the value of the user's cash holdings
    getCashHoldings(authToken)

  @getSecurityHoldings: (authToken, symbol) ->
    unless typeof authToken is 'string'
      console.error "[Bank.getCashHoldings – #{authToken}] authToken must be a string"
      return false

    unless typeof symbol is 'string' and symbol.length is 3
      console.error "[Bank.getCashHoldings – #{authToken}] symbol must be a three-character string"
      return false

    # Return the value of the user's cash holdings
    getSecurityHoldings(authToken, symbol.toLowerCase())

  @deposit: (authToken, cents, cb) ->
    errors = undefined

    unless isInteger(cents)
      (errors ?= []).push 'cents must be an integer'

    if errors?
      console.log("[Bank.deposit – #{authToken}] #{error}") for error in errors
      return cb(errors)

    # How much cash do we currently have?
    currentCashHoldings = @getCashHoldings(authToken)

    # What is the post-deposit value of the cash holdings?
    cashHoldingsAfterDeposit = currentCashHoldings + cents

    # Set the cash holdings to the post-deposit value
    setCashHoldings(authToken, cashHoldingsAfterDeposit)

    cb(null, cashHoldingsAfterDeposit)

  @withdraw: (authToken, cents, cb) ->
    errors = undefined

    unless isInteger(cents)
      (errors ?= []).push 'cents must be an integer'

    if errors?
      console.log("[Bank.withdrawal – #{authToken}] #{error}") for error in errors
      return cb(errors)

    # How much cash do we currently have?
    currentCashHoldings = @getCashHoldings(authToken)

    # What is the post-withdrawal value of the user's cash holdings?
    cashHoldingsAfterWithdrawl = currentCashHoldings - cents

    if cashHoldingsAfterWithdrawl < 0
      # You tried to withdraw more money than you have
      cb("You have insufficient funds to withdraw #{cents} cents")
    else
      # Set the user's cash holdings to the post-withdrawal value
      setCashHoldings(authToken, cashHoldingsAfterWithdrawl)
      cb(null, cashHoldingsAfterWithdrawl)

  @purchaseSecurity: (authToken, symbol, quantity, cb) ->
    errors = undefined

    unless isInteger(quantity) and quantity > 0
      (errors ?= []).push 'quantity must be a positive, non-zero integer'

    # What is the unit price of this security?
    unitPrice = Market.getSecurityPrice(symbol)
    if unitPrice is false
      (errors ?= []).push "Could find no security with symbol #{symbol}"

    if errors?
      console.log "[Bank.purchaseSecurity – #{authToken}] #{error}" for error in errors
      return cb(errors)

    # How much will it cost to buy the requested number of units?
    costCents = unitPrice * quantity

    # Withdraw the money
    @withdraw authToken, costCents, (err, cashHoldingsAfterPurchase) ->
      return cb(err) if err

      # How many units do we currently hold?
      currentSecurityHoldings = getSecurityHoldings(authToken, symbol.toLowerCase())

      # What is the post purchase number of units?
      securityHoldingsAfterPurchase = currentSecurityHoldings + quantity

      # Set the security holdings to the post-purchase value
      setSecurityHoldings(authToken, symbol, securityHoldingsAfterPurchase)

      cb(null, securityHoldingsAfterPurchase, cashHoldingsAfterPurchase)

  @sellSecurity: (authToken, symbol, quantity, cb) ->
    errors = undefined

    unless isInteger(quantity) and quantity > 0
      (errors ?= []).push 'quantity must be a positive, non-zero integer'

    # What is the unit price of this security?
    unitPrice = Market.getSecurityPrice(symbol)
    if unitPrice is false
      (errors ?= []).push "Could find no security with symbol #{symbol}"

    if errors?
      console.log "[Bank.sellSecurity – #{authToken}] #{error}" for error in errors
      return cb(errors)

    # How many units of this security do we own?
    currentSecurityHoldings = getSecurityHoldings(authToken, symbol)

    # Do we have enough units to sell?
    if currentSecurityHoldings >= quantity
      # How much will we earn by selling them?
      earningsCents = unitPrice * quantity

      @deposit authToken, earningsCents, (err, cashHoldingsAfterSale) ->
        # What is the post purchase number of units?
        securityHoldingsAfterSale = currentSecurityHoldings - quantity

        # Set the security holdings to the post-purchase value
        setSecurityHoldings(authToken, symbol, securityHoldingsAfterSale)

        cb(null, securityHoldingsAfterSale, cashHoldingsAfterSale)

    else
      errorString = "Insufficient units of #{symbol} to sell #{quantity}"
      console.log "[Bank.sellSecurity – #{authToken}] #{errorString}"
      cb(errorString)

module.exports = Bank
