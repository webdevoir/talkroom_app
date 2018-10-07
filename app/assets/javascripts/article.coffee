down_button = ->
  scrollPosition = document.getElementById('chat-scroll').scrollTop
  scrollHeight = document.getElementById('chat-scroll').scrollHeight
  document.getElementById('chat-scroll').scrollTop = scrollHeight
  return