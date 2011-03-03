show = (showing_status) ->
  statuses = ['connecting', 'connected', 'failed', 'disconnected']
  for status in statuses
    element = $("#status_" + status)
    if status == showing_status then element.show() else element.hide()

show 'connecting'

socket = new io.Socket()
socket.connect()

socket.on 'connect', ->
  show 'connected'
  
socket.on 'connect_failed', ->
  show 'failed'
  socket.connect()
  
socket.on 'disconnect', ->
  show 'disconnected'
  socket.connect()
  
socket.on 'message', ->
