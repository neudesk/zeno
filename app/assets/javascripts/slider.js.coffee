class window.Slider
  constructor: ->
    @setup()

  setup: ->
    get_searched_stations('')
    $('.search_form').on('submit', ->
      false
    )

    $('#rca_id').change () =>
      $('#current_page').val(1)
      get_searched_stations('')

    $('#searchStation').click () =>
      $('#current_page').val(1)
      get_searched_stations('')

  $('#country_id').change () =>
    $('#current_page').val(1)
    get_searched_stations('')

  $('.search-query').keydown((e) =>
    if e.keyCode == 13
      $('#current_page').val(1)
      get_searched_stations('')
  )

  $('.slider_content .prev').click (e) =>
    e.preventDefault()
    if $(e.target).hasClass('enabled')
      $('#current_page').val(parseInt($('#current_page').val()) - 1)
      get_searched_stations('left')

  $('.slider_content .next').click (e) =>
    e.preventDefault()
    if $(e.target).hasClass('enabled')
      $('#current_page').val(parseInt($('#current_page').val()) + 1)
      get_searched_stations('right')

  get_searched_stations = (direction) ->
    $('.slider-loading').show()
    gateway_id = if get_params('station_id') == null then get_params('gateway_id') else get_params('station_id')
    $('#controller_name').val(window.location.pathname)
    $('#gateway_id').val(gateway_id)
    $.ajax
      url: '/application/slider_search',
      type: 'POST',
      data: $('.search_form').serialize()
      success: (data) ->
        if direction == 'left'
          $(data.partial).insertBefore('.carousel .items')
          $('.carousel').attr('style', 'left:-950px')
          $('.carousel').animate {'left': '0px'}, 500, ->
            $('.items').last().remove()
            display_slide_btn()
            true
        else if direction == 'right'
          $('.carousel').append(data.partial)
          $('.carousel').animate {'left': '-950px'}, 500, ->
            $(this).attr('style', 'left:0px')
            $('.items').first().remove()
            display_slide_btn()
        else
          $('.carousel').html(data.partial)
          display_slide_btn()
          true

        if(data.prev_enabled)
          $('.slider_content .prev').addClass('enabled')
          $('.slider_content .prev').show()
        else
          $('.slider_content .prev').removeClass('enabled')
          $('.slider_content .prev').hide()
        if(data.next_enabled)
          $('.slider_content .next').addClass('enabled')
          $('.slider_content .next').show()
        else
          $('.slider_content .next').removeClass('enabled')
          $('.slider_content .next').hide()
        $('.slider-loading').hide()
        true
    true
  display_slide_btn = () ->
    if $('.slider li').length <= 6
      $('.slider_content .prev').attr('style', 'top:5px;display:block;')
      true
    else
      $('.slider_content .prev').attr('style', 'top:87px')
      true
    true

  get_params = (paramName) ->
    searchString = window.location.search.substring(1)
    i = undefined
    val = undefined
    params = searchString.split("&")
    i = 0
    while i < params.length
      val = params[i].split("=")
      return unescape(val[1])  if val[0] is paramName
      i++
    null
 


  