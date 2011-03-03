pending_message_responses = []
raise_history = []

##########
# Array Extension
# Thanks http://stackoverflow.com/questions/4825812/clean-way-to-remove-element-from-javascript-array-with-jquery-coffeescript
##########

Array::remove = (e) -> @[t..t] = [] if (t = @.indexOf(e)) > -1

##########
# Status showing
##########

show = (showing_status) ->
  statuses = ['connecting', 'connected', 'failed', 'disconnected']
  for status in statuses
    element = $("#status_" + status)
    if status == showing_status then element.show() else element.hide()

show 'connecting'

#########
# Socket IO
#########

socket = new io.Socket()
socket.connect()

socket.on 'connect', ->
  show 'connected'
  socket.send { message_type: 'ready', last_seen_raise : window.last_seen_raise }
  
socket.on 'connect_failed', ->
  show 'failed'
  socket.connect()
  
socket.on 'disconnect', ->
  show 'disconnected'
  socket.connect()
  
socket.on 'message', (message) ->
  switch message.message_type
    when 'ready'
      enable_buttons_if_unblocked()
    when 'raise'
      console.log("received raise message")
      raise_history.push message.number
      if message.number.user_id == window.user_id
        $('#history').prepend ('<li class="from_self">' + message.number.amount + '</li>')
      else
        $('#history').prepend ('<li>' + message.number.amount + '</li>')
      window.current_number = message.number.amount
      $('#current_number').html window.current_number
      enable_buttons_if_unblocked()
    when 'clear'
      console.log("received clear message")
      pending_message_responses.remove message.message_id
      enable_buttons_if_unblocked()
    else
      console.log message

########
# Sending a raise
########

send_raise = (amount) ->
  console.log "sending raise to " + amount
  message_id = 'u' + window.user_id + 't' + (new Date().getTime())
  pending_message_responses.push(message_id)
  socket.send {
    message_type : 'raise',
    message_id : message_id
    amount : amount,
    user_id : window.user_id
  }

buttons = ['#trigger_100', '#trigger_200']

enable_buttons_if_unblocked = ->
  history_length = raise_history.length
  if pending_message_responses.length == 0 and ((raise_history[history_length - 1] == undefined) || (raise_history[history_length - 1].user_id != window.user_id))
    enable_buttons()

disable_buttons = ->
  console.log("disabling buttons")
  for button in buttons
    $(button).attr "disabled", "disabled"

enable_buttons = ->
  console.log("enabling buttons")
  for button in buttons
    $(button).removeAttr "disabled"

$('#trigger_100').click ->
  disable_buttons()
  send_raise (current_number + 100)
$('#trigger_200').click -> 
  disable_buttons()
  send_raise (current_number + 200)

