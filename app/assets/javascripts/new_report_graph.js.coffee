class window.NewReportGraph
  constructor: ->
    @setup()

  setup: ->
    pullStationLists()
    slider()
    main()

  $search = ""
  $country_id = ""
  $rca_id = ""

  pullStationLists = () ->
    slide = $('.slider_content');
    if !$('#inside_slider .alert').text().trim(' ') == "No stations Found"
      slide.hide()

    $('#pullStationBtn').click () ->
      if slide.is(':visible')
        slide.slideUp(300)
      else
        slide.slideDown(300);
    return

    $(document).on 'click', '#pullStationBtn', () ->
      if slide.is(':visible')
        slide.slideUp(300)
      else
        slide.slideDown(300)
    return

  ajaxAnim = (x) ->
    $('#inside_slider').removeClass().addClass(x + ' animated').one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', () ->
      $(this).removeClass()
    return

  ajaxSlide = (page) ->
    $.ajax({
      url: "/application/slider_content/" + page,
      data:
        search: $search
        country_id: $country_id
        rca_id: $rca_id
        controller_name: "new_report/graph"
      success: (data) ->
        if $("#page").val() == 1
          $('#prev-slide').hide()
        else if $("#page").val() == data.total_page
          $('#next-slide').hide()

        if data.total_page == 1
          $('#next-slide').hide()
          $('#prev-slide').hide()
    }).done (data) ->
      $("#inside_slider").html(data);
      $("#total_page").text($("#pages").val())
      return
    return

  nextSlide = () ->
    $("#next-slide").click () ->
      ajaxAnim('bounceInRight')
      $page = parseInt($('#page').val())
      $('#page').val($page+1)
      ajaxSlide($page+1, $country_id)
      $("#prev-slide").show()
    return

  prevSlide = () ->
    $("#prev-slide").click () ->
      ajaxAnim('bounceInLeft')
      $page = parseInt($('#page').val())
      $('#page').val($page-1)
      ajaxSlide($page-1)
      $("#next-slide").show()
    return

  setPage = () ->
    $('#page').keyup () ->
      $page = parseInt($('#page').val())
      if $.isNumeric($page)
        if $page > parseInt($('#total_page').text())
          $('#page').val(parseInt($('#total_page').text()))
      return

    $('#page').keypress (e) ->
      $page = parseInt($('#page').val())
      if e.which == 13
        if $.isNumeric($page)
          ajaxSlide($page)
          $('.slider_content').removeClass('hide')
        else
          alert 'Please enter a valid page.'
      return
    return

  search = () ->
    $('.query-search-country-id').change () ->
      ajaxAnim('fadeIn')
      $country_id = $(this).val()
      ajaxSlide(1)
      $('.slider_content').slideDown(300)
      return

    $('.query-search-rca-id').change () ->
      ajaxAnim('fadeIn')
      $rca_id = $(this).val()
      ajaxSlide(1)
      $('.slider_content').slideDown(300)
      return

    $('#searchStation').click () ->
      ajaxAnim('fadeIn')
      $search = $('#query').val()
      $('#page').val(1)
      ajaxSlide(1)
      $('.slider_content').slideDown(300)
      return

  setPreload = () ->
    $(document).ajaxStart ( event,request, settings ) ->
      $('.slider-loading').show()
      return
    $(document).ajaxComplete ( event,request, settings ) ->
      $('.slider-loading').hide()
      return

  slider = () ->
    ajaxSlide(1)
    nextSlide()
    prevSlide()
    setPage()
    search()
    setPreload()
    return

  graphify = (elem, text, color) ->
    labels = $(elem).data("labels")
    $(elem).removeData("labels")
    values = $(elem).data("values")
    $(elem).removeData("values")
    obj = []
    $.each labels, (index, label) ->
      obj.push([label, values[index]])

    $.plot elem, [obj],
      series:
        lines:
          show: true
          lineWidth: 3
          fill: true
        color: color
      xaxis:
        mode: "categories"
        tickLength: 0
        font:
          size: 14
          color: "#000000"
      grid:
        backgroundColor: "#FFFFFF"
        hoverable: true

    previousPoint = null
    $(elem).bind "plothover", (event, pos, item) ->
      $("#x").text pos.x.toFixed(2)
      $("#y").text pos.y.toFixed(2)
      if item
        unless previousPoint is item.dataIndex
          previousPoint = item.dataIndex
          $("#tooltip").remove()
          x = item.datapoint[0]
          y = item.datapoint[1]
          $.showTooltip item.pageX, item.pageY, "#{y} #{text}"
      else
        $("#tooltip").remove()
        previousPoint = null

  get_request = (url='', elem='', data={}) ->
    response = false
    $.ajax(
      url: url
      type: 'GET'
      data: data
      async: false,
      success: (data) ->
        labels = []
        values = []
        $.map data, ( val, i ) ->
          labels.push("\"#{val[0]}\"")
          values.push(val[1])
        $(elem).attr('data-labels', "[#{labels}]").attr('data-values', "[#{values}]")
      complete: () ->
        response = true
    )
    return response

  get_users_by_time = (data={}) ->
    url='/new_report/get_users_by_time'
    response = get_request(url=url, elem='#user_by_time', data=data)
    if response
      graphify("#user_by_time", "User by Time", "#37b7f3")
    else
      alert 'Unexpected error!'

  get_minutes_report = (data={}) ->
    url='/new_report/get_minutes_report'
    response = get_request(url=url, elem='#minutes_report', data=data)
    if response
      graphify("#minutes_report", "Minutes", "#37b8f5")
    else
      alert 'Unexpected error!'

  main = () ->
    get_users_by_time(data={'station_id': $('.users_by_time_select').attr('data-gateway')})
    get_minutes_report(data={'station_id': $('.minutes_report_select').attr('data-gateway')})
    $('.graphSwitch').removeClass('active')
    $(document).on 'change', '.minutes_report_select', () ->
      get_minutes_report(data={'minutes_report':$(this).val(), 'station_id': $(this).attr('data-gateway')})
    $(document).on 'change', '.users_by_time_select', () ->
      get_users_by_time(data={'users_by_time':$(this).val(), 'station_id': $(this).attr('data-gateway')})