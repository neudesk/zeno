class window.Graphs
  constructor: ->
    @setup()

  setup: ->
    @chart_a = $("#chart_a")
    @changeDayChartA()
    @changeDayChartC()
    @changeContentChartC()
    @changeDayChartD()
    @changeContentChartD()
    @changeDayChartE()
    @changeContentChartE()
    @setTitleSelectTag()
    slider()

  $search = "";
  $country_id = "";
  $rca_id = "";

  ajaxAnim = (x) ->
    $('#inside_slider').removeClass().addClass(x + ' animated').one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', () ->
      $(this).removeClass()
    return

  ajaxSlide = (page) ->
    $.ajax({
      url: "application/slider_content/" + page,
      data:
        search: $search
        country_id: $country_id
        rca_id: $rca_id
        controller_name: "graphs"
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

  changeDayChartA: ->
    $("#pie_chart").change((e) =>
      url = "/graphs/chart_a?day=" + $("#pie_chart").val()
      param = window.location.search.substring(1)
      if param != ""
        url = url + "&gateway_id=" +param.split("=")[1]
      $("#loading").removeClass("hide")
      $("#chart_a").addClass("hide")
      $.ajax({
      url: url
      type: 'GET'
      success: (res) ->
        $("#chart_a").html(res)
      error: (res) ->
        return
      complete: (res) ->
        $("#loading").addClass("hide")
        $("#chart_a").removeClass("hide")
      })
    )

  changeDayChartC: ->
    $("#line_chart").change((e) =>
      @processChangeChartC()
    )

  changeContentChartC: ->
    $("#line_chart_ext").change((e) =>
      @processChangeChartC()
    )

  processChangeChartC: ->
    url = "/graphs/change_chart_c?day=" + $("#line_chart").val()
    url += "&object_id=" + $("#line_chart_ext").val()
    $("#chart_content_c #lloading").removeClass("hide")
    $("#chart_c").addClass("hide")
    $.ajax({
    url: url
    type: 'GET'
    success: (res) ->
      $("#chart_c").html(res)
    error: (res) ->
      return
    complete: (res) ->
      $("#chart_content_c #lloading").addClass("hide")
      $("#chart_c").removeClass("hide")
    })

  changeDayChartD: ->
    $("#column_chart").change((e) =>
      @processChangeChartD()
    )

  changeContentChartD: ->
    $("#column_chart_ext").change((e) =>
      @processChangeChartD()
    )

  processChangeChartD: ->
    url = "/graphs/change_chart_d?day=" + $("#column_chart").val()
    url += "&object_id=" + $("#column_chart_ext").val()
    $("#chart_content_d #lloading").removeClass("hide")
    $("#chart_d").addClass("hide")
    $.ajax({
    url: url
    type: 'GET'
    success: (res) ->
      $("#chart_d").html(res)
    error: (res) ->
      return
    complete: (res) ->
      $("#chart_content_d #lloading").addClass("hide")
      $("#chart_d").removeClass("hide")
    })

  changeDayChartE: ->
    $("#total_chart_day").change((e) =>
      @processChangeChartE()
    )

  changeContentChartE: ->
    $("#total_chart_ext").change((e) =>
      @processChangeChartE()
    )

  processChangeChartE: ->
    gateway_id = window.location.search.substring(1).split("=")[1]
    url = "/graphs/change_total_chart?gateway_id="+gateway_id+"&day=" + $("#total_chart_day").val()
    url += "&channel_id=" + $("#total_chart_ext").val()
    $("#total_chart_content #lloading").removeClass("hide")
    $("#total_chart").addClass("hide")
    $.ajax({
            url: url
            type: 'GET'
            success: (res) ->
              $("#total_chart").html(res)
            error: (res) ->
              return
            complete: (res) ->
              $("#total_chart_content #lloading").addClass("hide")
              $("#total_chart").removeClass("hide")
    })

  setTitleSelectTag: ->
    $("#column_chart_ext").hover ->
      $(this).attr("title", $(this).children(":selected").text())
    $("#line_chart_ext").hover ->
      $(this).attr("title", $(this).children(":selected").text())
    $("#total_chart_ext").hover ->
      $(this).attr("title", $(this).children(":selected").text())
