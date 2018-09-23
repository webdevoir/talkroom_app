$(document).ready ->
  chats = $('#chats')

  App.chat_room = App.cable.subscriptions.create { channel: "ChatRoomChannel", chat_room_id: chats.data('chat_room_id') },

    received: (data) ->
      $('#chats').append data['chat']
      sending_chat = $(".chat-box:last-child")
      current_user_id = $('body').attr('id')
      scrollPosition = document.getElementById("chat-scroll").scrollTop
      scrollHeight = document.getElementById("chat-scroll").scrollHeight;
      if (sending_chat.attr('id') == current_user_id)
        sending_chat.find(".time-id-info").attr("class", "time-id-info-mine")
        sending_chat.find(".chat-balloon-line").attr("class", "chat-balloon-line-mine")
        sending_chat.find(".chat-balloon").attr("class", "chat-balloon-mine")
        document.getElementById("chat-scroll").scrollTop = scrollHeight;

    speak: (chat) ->
      @perform 'speak', chat: chat

  $(document).on 'keypress', '[data-behavior~=chat_room_speaker]', (event) ->
    if event.shiftKey
      if event.keyCode is 13 # return = send
        App.chat_room.speak event.target.value
        event.target.value = ''
        event.preventDefault()

  $("#send-button").click ->
    App.chat_room.speak $("#chat_textarea").val()
    $("#chat_textarea").val('')
    event.preventDefault()