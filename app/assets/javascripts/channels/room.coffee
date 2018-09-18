#App.room = App.cable.subscriptions.create "RoomChannel",
  #connected: ->
    # Called when the subscription is ready for use on the server

  #disconnected: ->
    # Called when the subscription has been terminated by the server

$(document).on 'turbolinks:load', ->
  messages = $('#messages')
  #if $('#messages').length > 0

  App.room = App.cable.subscriptions.create { channel: "RoomChannel", room_id: messages.data('room_id') },

    received: (data) ->
      $('#messages').append data['message']
      scrollPosition = document.getElementById("chat-scroll").scrollTop
      scrollHeight = document.getElementById("chat-scroll").scrollHeight;
      if (scrollHeight - scrollPosition) < 1000
        document.getElementById("chat-scroll").scrollTop = scrollHeight;

    speak: (message) ->
      @perform 'speak', message: message

    $(document).on 'keypress', '[data-behavior~=room_speaker]', (event) ->
      if event.shiftKey
        if event.keyCode is 13 # return = send
          App.room.speak event.target.value
          event.target.value = ''
          event.preventDefault()

  $("#send-button").click ->
    App.room.speak $("#message_textarea").val()
    $("#message_textarea").val('')
    event.preventDefault()


