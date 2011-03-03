express = require 'express'
app = express.createServer()

number_history = [{amount: 0, user: undefined}]
ready_connections = []


app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyDecoder()
  app.use express.methodOverride()
  app.use app.router
  app.use express.staticProvider(__dirname + '/public')


app.configure 'development', ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', ->
  app.use express.errorHandler()

app.get '/', (req, res) -> 
  res.render 'index', {
    locals: {
      title: 'Home'
    }
  }

app.get '/user/:id', (req, res) -> 
  user_id = req.params.id
  res.render 'game', {
    locals: {
      title: 'Game',
      user_id: user_id,
      current_number: number_history[number_history.length-1].amount
    }
  }

app.listen(3000)
console.log("Express server listening on port %d", app.address().port)

io = require 'socket.io'
socket = io.listen app
socket.on 'connection', (client) ->
  console.log "connection made"
  client.on 'disconnect', ->
    console.log "disconnected"
    #####################
    #####################
    #####################
    #### need to remove from connections
    #####################
    #####################
    #####################
  client.on 'message', (data) ->
    switch data.message_type
      when 'ready'
        for number in number_history[data.last_seen_raise...number_history.length]
          client.send { message_type: 'raise', number: number }
        ready_connections.push(client)
      when 'raise'
        console.log "received raise to amount of " + data.amount
        handle_raise data.amount, data.user_id, data.message_id, client
      when 'refresh'
        console.log "received refresh request from raise " + data.last_raise
      else
        console.log "received " + data

handle_raise = (amount, user_id, message_id, client) ->
  if amount > number_history[number_history.length-1].amount
    number = {amount: amount, user_id: user_id}
    number_history.push(number)
    for connection in ready_connections
      connection.send { message_type: 'raise', number: number }
  client.send { message_type: 'clear', message_id: message_id }
