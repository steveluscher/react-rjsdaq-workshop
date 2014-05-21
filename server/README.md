# The RJSDAQ server

This is a node process that exposes a websocket API, allowing you to interact with a fake “stock market”.

## Requirements

To run the RJSDAQ server, you will need Node/NPM. Installation instructions can be found [here](http://nodejs.org/download/).

## Running

To run the RJSDAQ server:

1. Run `npm install` to install some prerequisites
2. Start the server with `npm start`

## The Websocket API

Use any [compliant](https://github.com/einaros/ws#protocol-support) websocket implementation to connect to the server.

### Message format

The socket will emit messages as serialized JSON data structures, having the following format:

    [ eventName[, data...] ]

Where:

* `eventName` is a string
* `data...` represents any number of elements, each of which could be an object, array, or a Javascript primitive

### Command format

To send a command to the server, serialize the following JSON data structure as a string, and send it down the wire:

    [ requestId, commandName, data ]

Where:

* `requestId`: (optional) is an integer or null
* `commandName`: (required) is a string representing a valid command name
* `data`: (optional) is an object, array, or a Javascript primitive

### Request-response pattern

If you pass an integer for the requestId parameter in your command, you are guaranteed to receive a response message from the server, having the following format:

    [ 'Response', requestId[, err, data...] ]

You can use the `requestId` to correlate the response with a request made earlier (eg. for the purpose of invoking a callback).

## Commands

The server responds to the commands listed below.

### GetToken

Send this command with a requestId and no data, and the server will respond with a token. You can store this token, and use it to authenticate at a later date.

* `requestId`: an integer (required)
* `commandName`: (required) the string 'GetToken'
* `data`: null

Responds with:

    [ 'Response', requestId, token ]

Where:

* `token`: a string representing an auth token

### AuthenticateWithToken

Send this command with a requestId, and the token as a string, and the server will respond with some seed data if you were successfully authenticated, or an error.

* `requestId`: (required) an integer
* `commandName`: (required) the string 'AuthenticateWithToken'
* `data`: (required) a string representing an auth token

Responds with:

    [ 'Response', requestId, {
      cashHoldings: holdingsCents,
      securities: {
        securitySymbol: { name: securityName, price: securityPrice, unitsHeld: securityUnitsHeld },
        ...
      }
    } ]

Where:

* `holdingsCents`: an integer representing your available cash holdings, in cents
* `securitySymbol`: a three-letter lowercase string representing a listed security
* `securityName`: a string representing the name of the security
* `securityPrice`: an integer representing the current price of the security, in cents
* `securityUnitsHeld`: an integer representing the number of units of this security the authenticated user holds

### Buy

Use this command to buy a security, given a security symbol and a number of units. If you supply a requestId, the server will send you a response when finished. The response may include an error if you had insufficient funds.

* `requestId`: (optional) an integer
* `commandName`: (required) the string 'Buy'
* `data`: (required) an object with the following format:
  * `symbol`: (required) a three-letter string representing a listed security
  * `quantity`: (required) an integer representing the number of units to be bought

### Sell

Use this command to sell a security, given a security symbol and a number of units. If you supply a requestId, the server will send you a response when the sale has been completed (sales always succeed).

* `requestId`: (optional) an integer
* `commandName`: (required) the string 'Sell'
* `data`: (required) an object with the following format:
  * `symbol`: (required) a three-letter string representing a listed security
  * `quantity`: (required) an integer representing the number of units to sell

### GoPublic

Use this command to list a new security, given a security symbol and name. If you supply a requestId, the server will send you a response when finished. The response may include an error if your IPO failed (eg. the input was invalid, or the security is a duplicate).

* `requestId`: (optional) an integer
* `commandName`: (required) the string 'GoPublic'
* `data`: (required) an object with the following format:
  * `symbol`: (required) a three-letter string representing a listed security
  * `name`: (required) a string representing the name of the security

## Messages

From time to time, the server will emit the following messages:

### SecurityPriceUpdated

When the price of a security changes, a message having this format will be emitted from the socket:

    [ 'SecurityPriceUpdated', securitySymbol, securityPrice ]

Where:

* `securitySymbol`: a three-letter lowercase string representing a listed security
* `securityPrice`: an integer representing the current price of the security, in cents

### SecurityListed

When a new security is listed, a message having this format will be emitted from the socket:

    [ 'SecurityListed', securitySymbol, securityName ]

Where:

* `securitySymbol`: a three-letter lowercase string representing a listed security
* `securityName`: a string representing the name of the security

### SecurityHoldingsUpdated

When your securities holdings change, a message having this format will be emitted from the socket:

    [ 'SecurityHoldingsUpdated', securitySymbol, securityUnitsHeld ]

Where:

* `securitySymbol`: a three-letter lowercase string representing a listed security
* `securityUnitsHeld`: an integer representing the number of units held

### CashHoldingsUpdated

When your cash holdings change, a message having this format will be emitted from the socket:

    [ 'CashHoldingsUpdated', holdingsCents ]

Where:

* `holdingsCents`: an integer representing your available cash holdings, in cents
