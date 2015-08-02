class window.Map
  constructor: ->
    @setup()

  setup: ->
    @chartContent = $(".main .map")
    @initMap()

  initMap: ->