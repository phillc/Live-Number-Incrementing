express = require 'express'
app = express.createServer()

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
      title: 'Express'
    }
  }

app.listen(3000)
console.log("Express server listening on port %d", app.address().port)