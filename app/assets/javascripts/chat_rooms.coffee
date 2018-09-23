document.addEventListener 'DOMContentLoaded', (->
  document.getElementById('scroll_down_button').addEventListener 'click', scroll_down), false

scroll_down = ->
  scrollPosition = document.getElementById('chat-scroll').scrollTop
  scrollHeight = document.getElementById('chat-scroll').scrollHeight
  document.getElementById('chat-scroll').scrollTop = scrollHeight
  return