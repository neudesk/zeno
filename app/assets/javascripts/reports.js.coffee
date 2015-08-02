class window.Report
  constructor: ->
    @setup()

  setup: ->
    pullStationLists()
    setUploadedPhoneLists()
#    fakePreload()
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

  fakePreload = () ->
    $(document).unbind().on 'submit', '#upload_phone_form', (event) ->
      if $('#upload_datafile').val() != ''
        width = 0;
        setLoad = () ->
          width += 0.7;
          $('#bar').css('width', width + '%')
        setInterval(setLoad, 100)
    return


  setUploadedPhoneLists = () ->
    $(document).on 'submit', 'form[action="/reachout_tab/save"]', () ->
      num = $('span[class="label label-info phone_number"]')
      if num.length > 0
        data = []
        $.each(num, () ->
          data.push($(value).find('a').attr('data-val'))
        )
        $('input[name="uploaded_phone_list"]').val(data.join())
      return

  graphify = (elem, text, color) ->
    labels = $(elem).data("labels")
    values = $(elem).data("values")
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
        controller_name: "reports"
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

  main = () ->
#    $('#graphsForm').on 'submit', () ->
#      return false
    $(".change_reports, .change_did").on "change", (e) ->
      $(".loading").show()
      $(this).parents("form").submit()

    if $("#new_users_graph").length > 0
      graphify("#new_users_graph", "users", "#37b7f3")

    if $("#active_users_graph").length > 0
      graphify("#active_users_graph", "users", "#d12610")

    if $("#sessions_graph").length > 0
      graphify("#sessions_graph", "sessions", "#FF6600")

    if $("#report_minutes_graph").length > 0
      graphify("#report_minutes_graph", "minutes", "#52e136")

    if $("#weekly_minutes_graph").length > 0
      graphify("#weekly_minutes_graph", "minutes", "#52e136")

    if $("#compare_prev_weeks_graph").length > 0
      labels = $("#compare_prev_weeks_graph").data("labels")
      current_values = $("#compare_prev_weeks_graph").data("current-values")
      prev_values = $("#compare_prev_weeks_graph").data("prev-values")

      current = []
      $.each labels, (index, label) ->
        current.push([label, current_values[index]])

      prev = []
      $.each labels, (index, label) ->
        prev.push([label, prev_values[index]])

      $.plot "#compare_prev_weeks_graph", [
          {label: "Current Week", data: current},
          {label: "Previous Week", data: prev}
        ],
        series:
          lines:
            show: true
            lineWidth: 3
            fill: true

        color: ["#d12610", "#37b7f3"]
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
      $("#compare_prev_weeks_graph").bind "plothover", (event, pos, item) ->
        $("#x").text pos.x.toFixed(2)
        $("#y").text pos.y.toFixed(2)
        if item
          unless previousPoint is item.dataIndex
            previousPoint = item.dataIndex
            $("#tooltip").remove()
            x = item.datapoint[0].toFixed(2)
            y = item.datapoint[1].toFixed(2)
            $.showTooltip item.pageX, item.pageY, item.series.label + ": " + y
        else
          $("#tooltip").remove()
          previousPoint = null
        return
