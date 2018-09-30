#App.room = App.cable.subscriptions.create "RoomChannel",
  #connected: ->
    # Called when the subscription is ready for use on the server

  #disconnected: ->
    # Called when the subscription has been terminated by the server

#$(document).on 'turbolinks:load', ->
$(document).ready ->
  messages = $('#messages')

  App.room = App.cable.subscriptions.create { channel: "RoomChannel", room_id: messages.data('room_id') },

    received: (data) ->
      $('#messages').append data['message']
      sending_message = $(".chat-box:last-child")
      current_user_id = $('body').attr('id')
      scrollPosition = document.getElementById("chat-scroll").scrollTop
      scrollHeight = document.getElementById("chat-scroll").scrollHeight;
      if (sending_message.attr('id') == current_user_id)
        sending_message.find(".time-id-info").attr("class", "time-id-info-mine")
        sending_message.find(".chat-balloon-line").attr("class", "chat-balloon-line-mine")
        sending_message.find(".chat-balloon").attr("class", "chat-balloon-mine")
        sending_message.find("#msg_id").attr("class", "image-link")
        document.getElementById("chat-scroll").scrollTop = scrollHeight;
      if ( (scrollHeight - scrollPosition) < 1000 )
        document.getElementById("chat-scroll").scrollTop = scrollHeight;

    speak: (message, file_uri, original_name) ->
      @perform 'speak', message: message, file_uri: file_uri, original_name: original_name

  $(document).on 'keypress', '[data-behavior~=room_speaker]', (event) ->
    if event.shiftKey
      if event.keyCode is 13 # return = send
        if $('#message-attachment').get(0).files.length > 0
          reader = new FileReader()
          file_name = $('#message-attachment').get(0).files[0].name
          message_content = $("#message_textarea").val()
          reader.addEventListener "loadend", ->
            App.room.speak message_content, reader.result, file_name

          reader.readAsDataURL $('#message-attachment').get(0).files[0]
        else
          App.room.speak event.target.value
        event.target.value = ''
        $('#message-attachment').val('')
        event.preventDefault()

  $("#send-button").click ->
    if $('#message-attachment').get(0).files.length > 0
      reader = new FileReader()
      file_name = $('#message-attachment').get(0).files[0].name
      message_content = $("#message_textarea").val()
      reader.addEventListener "loadend", ->
        App.room.speak message_content, reader.result, file_name

      reader.readAsDataURL $('#message-attachment').get(0).files[0]
    else
      App.room.speak $("#message_textarea").val()
    $("#message_textarea").val('')
    $('#message-attachment').val('')
    event.preventDefault()
