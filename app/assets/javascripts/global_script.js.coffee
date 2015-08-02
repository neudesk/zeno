class window.GlobalScript
  constructor: (options)->
    @setup(options)

  setup: (options)->
    setInfoFadeOut()
    setClock()
#    flipTheClock()

#  flipTheClock = () ->
#    dt = moment().tz("America/New_York")
#    time = 3600 * (dt.hours() + (dt.minutes() / 60))
#    clock = $('.clock').FlipClock(time, {
#              showSeconds: false
#            })
#    $('.flip-clock-divider.seconds').next().next().css('display', 'none')
#    $('.flip-clock-divider.seconds').next().css('display', 'none')
#    $('.flip-clock-divider.seconds').hide().css('display', 'none')

  setClock = () ->
    setInterval(() ->
      $('span.seconds').css('opacity', '0.3')
      dt = moment().tz("America/New_York")
      hours = dt.format('HH')
      minutes = dt.format('mm')
      $('span.hours').text(hours)
      $('span.minutes').text(minutes)
    , 1000)
    setInterval(() ->
      $('span.seconds').css('opacity', '1.0')
    , 2000)

  setInfoFadeOut = () ->
    setTimeout(() ->
      $('#flash').fadeOut(3000)
    , 60000)