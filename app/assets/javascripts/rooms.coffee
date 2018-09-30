document.addEventListener 'DOMContentLoaded', (->
  messages_count = $('.time-stamp').length
  if messages_count > 0
    for i in [1..messages_count]
      time_stamp = $('.time-stamp').eq(i - 1)
      time_stamp.wrapInner('<a>' + i + '. </a>')
      time_stamp.attr('id', i)
  document.getElementById('scroll_down_button').addEventListener 'click', scroll_down), false

scroll_down = ->
  scrollPosition = document.getElementById('chat-scroll').scrollTop
  scrollHeight = document.getElementById('chat-scroll').scrollHeight
  document.getElementById('chat-scroll').scrollTop = scrollHeight
  return

$ ->
  $('#image-form-view').click ->
    if $('.image-send-form').css('display') == 'none'
      $('.image-send-form').show()
    else
      $('.image-send-form').hide()
