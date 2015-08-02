$ ->
  $(document).ready customHooks
  $(document).on "page:load", customHooks
  $("body").on "show", customHooks

customHooks = ->
  $(".toggle-campaign").on "click", (e) ->
    if $(this).html() == "Show Details"
      if $(this).parents(".panel-footer").prev(".panel-body").find(".loaded").find("table").length > 0
        e.preventDefault();
        $('.campaign_list').html("Show Details")
        $('.campaigns_box').hide()
        $(this).html("Hide Details")
        $(this).parents(".panel-footer").prev(".panel-body").show()
        $(this).parents(".panel-footer").prev(".panel-body").find(".loaded").show()
        return false
      else
        $('.campaign_list').html("Show Details")
        $(".panel-campaign .panel-body").hide()
        $(this).parents(".panel-footer").prev(".panel-body").show()
        $(this).parents(".panel-footer").prev(".panel-body").find(".loading").show()
        $(this).parents(".panel-footer").prev(".panel-body").find(".loaded").show()
    else
      e.preventDefault();
      $(this).parents(".panel-footer").prev(".panel-body").hide()
      $(this).html("Show Details")
      return false


class window.CampaignResults
  t = null
  constructor: (options)->
    @setup(options)
    runRealtimeChart()

  getUrlParameter = (sParam) ->
    sPageURL = window.location.search.substring(1)
    sURLVariables = sPageURL.split("&")
    i = 0

    while i < sURLVariables.length
      sParameterName = sURLVariables[i].split("=")
      return sParameterName[1]  if sParameterName[0] is sParam
      i++
    return

  setup: (options)->
    viewCampaign()
    d = new Date()
    month = d.getMonth() + 1
    day = d.getDate()
    year = d.getFullYear()

    $(".c_" + year + "-" + month + "-" + day).click()
    $(".campaigns_box_" + year + "-" + month + "-" + day).css("display", "block")
    $(".campaigns_box_" + year + "-" + month + "-" + day + " .loading").css("display", "block")

    param = getUrlParameter('campaign_date')
    if typeof param != 'undefined'
      current_elem = $('*[data-id="' + param + '"]').click()
      date = $(current_elem).data('id')
      if $('.campaigns_box_' + date).is(':visible')
        $(current_elem).children('i').removeClass('fa-angle-down')
        $(current_elem).children('i').addClass('fa-angle-up')
        $('.campaigns_box_' + date).hide()
        update_campaign("stop", date)
      else
        $('.cmp_table').hide()
        $('.campaigns_box_' + date).show()
        $('.campaigns_box_' + date).html('<div style="width:100px;height:200px;margin: 0 auto;"><img style="margin-top:30px;width:32px;height:32px;" alt="Loader" src="/assets/ajax/loader.gif"></div>')
        $('.fa').removeClass('fa-angle-down').addClass('fa-angle-up')
        $(current_elem).children('i').removeClass('fa-angle-up').addClass('fa-angle-down')
        url = "/campaign_results/get_campaigns_by_date?date=" + date
        $.ajax({
          url: url
          type: 'GET'
          success: (res) ->
            $('.campaigns_box_' + date).html(res)
            update_campaign("start", date)
          error: (res) ->
            return
          complete: (res) ->
        })
    $("#daily_tab").click ->
      if !$('#placeholder-daily').children('canvas').length > 0
        runDailyChart()
    $("#weekly_tab").click ->
      if !$('#placeholder-weekly').children('canvas').length > 0
        runWeeklyChart()

  viewCampaign = () ->
    $(document).on 'click', '.campaignActionView', (e) ->
      e.preventDefault()
      href = $(this).attr('href')
      $.ajax({
        url: href
        type: 'get'
        async: true
        success: (data) ->
          $("#modalHandler").html data
      }).done(() ->
        setTimeout($("#view_campaign_modal").modal "show", 1000)
      ).error(() ->
        alert("Can't view this campaign at this time, Please try again later.")
      )

  $(document).on "click", ".resend_camapign", () ->
    clearTimeout(t)
  $(document).on('click', '.campaign_list', ( (e) ->
    date = $(this).data('id')
    if $('.campaigns_box_' + date).find('table').is(':visible')
      update_campaign("stop", date)
    else
      update_campaign("start", date)
  ))
  $(document).on('click', '.show_campaign_status', ( (e) ->
    $("#showContentModal").modal("show");
    $("#showContentModal").html('<div class="campaign_loader" style="width:100%;height:240px;"><img style="margin:102px 0 0 262px;width:32px;height:32px;" alt="Loader" src="/assets/ajax/loader.gif"></div>')
    campaign_id = $(this).attr('id')
    url = "/campaign_results/get_campaign_status?campaign_id=" + campaign_id
    $.ajax({
      url: url
      type: 'GET'
      success: (res) ->
        $('#showContentModal').css('height', '700px')
        $('#showContentModal').css('overflow', 'auto')
        $("#showContentModal").html(res)
        $('.campaign_loader').remove()
      error: (res) ->
        return
      complete: (res) ->
        }
    )))

  $(document).on('click', '.time_zones', ( (e) ->
    id = $(this).data('id')
    if $('#' + id).is(':visible')
      $('#' + id).hide()
      $(this).text("Show Time Zone")
    else
      $('#' + id).show()
      $(this).text("Hide Time Zone")
  ))

  $(document).on('click', '.settings_modal', ( (e) ->
    $("#showSettingsModal").modal("show");
    id = $(this).data('id')
    gateway_id = $(this).data('value')
    $.ajax({
      url: "/campaign_results/get_campaigns_by_main_id?id=" + id + "&gateway_id=" + gateway_id
      type: 'GET'
      success: (res) ->
        $('#showSettingsModal').html(res)
      error: (res) ->
        return
      complete: (res) ->
    })

  ))
  $(document).on('click', '.custom_pagination', ( (e) ->
    gateway_id = $(this).data('value')
    page = $(this).data('id')
    url = "/campaign_results/get_campaigns_by_gateway_id?gateway_id=" + gateway_id + "&page=" + page
    $.ajax({
      url: url
      type: 'GET'
      success: (res) ->
        $('.campaigns_box_' + gateway_id).html(res)
      error: (res) ->
        return
      complete: (res) ->
    })
  ))
  $(document).on('change', '.did_provider', ( (e) ->
    id = $(this).data('did')
    did_provider = $(this).val()
    gateway_id = $('#camapign_gateway_id').val()
    url = "/campaign_results/get_dids_by_provider?did_provider=" + did_provider + "&gateway_id=" + gateway_id
    $.ajax({
      url: url
      type: 'GET'
      success: (res) ->
        html = ""
        i = 0;
        while i < res.length
          html += "<option value='" + res[i] + "'>" + res[i] + "</option>"
          i++
        $("#did_" + id).html(html)
        return
      error: (res) ->
        return
      complete: (res) ->
    })
  ))
  $(document).on('change', '.did', ( (e) ->
    id = $(this).data('id')
    did_provider = $("#did_provider_" + id).val()
    did = $(this).val()
    url = "/campaign_results/update_campaign_did?id=" + id + "&did=" + did + "&did_provider=" + did_provider
    $.ajax({
      url: url
      type: 'PUT'
      success: (res) ->
      error: (res) ->
        return
      complete: (res) ->
    })
  ))

  update_campaign = (status, parent_id) ->
    if status == "start"
      campaigns = []
      $('.campaigns_box_' + parent_id + ' .campaing_table_row').each(() ->
        if $(this).data('status') == "Inactive"
          campaigns.push($(this).data('id'))
          id = $(this).data('id')
          html = ""
          $.ajax({
            url: "/campaign_results/get_campaigns_statuses?campaign_id=" + id
            type: 'GET'
            success: (res) ->
              $('.progress_' + res["campaign_id"] + ' .progress-bar-danger').attr('width', res['na_percent'])
              $('.progress_' + res["campaign_id"] + ' .progress-bar-warning').attr('width', res['pu_percent'])
              $('.progress_' + res["campaign_id"] + ' .progress-bar-success').attr('width', res['pm_percent'])
              $('.progress_' + res["campaign_id"] + ' .progress-bar-danger').attr('tip',
                  "Total Leads: " + res["total_all"] + "  \n No Answer: " + res["na"] + " ")
              $('.progress_' + res["campaign_id"] + ' .progress-bar-warning').attr('tip',
                  "Total Leads: " + res["total_all"] + "  \n  Dial but Call Diconnected : " + res["pu"])
              $('.progress_' + res["campaign_id"] + ' .progress-bar-success').attr('tip',
                  "Total Leads: " + res["total_all"] + "  \n Played Message: " + res["pm"])
            error: (res) ->
              return
            complete: (res) ->
          })
      )
      #        $('#displayed_campaigns').val(campaigns)
      t = setInterval(->
        i = 0
        campaigns = []
        $('.campaigns_box_' + parent_id + ' .campaing_table_row').each () ->
          if $('.campaigns_box_' + parent_id).is(':visible')
            if !$(this).children('.acenter').children('span').hasClass('completed')
              campaigns.push($(this).attr('data-id'))
        while i < campaigns.length
          $.ajax({
            url: "/campaign_results/get_campaigns_statuses?campaign_id=" + campaigns[i]
            type: 'GET'
            success: (res) ->
              $('.progress_' + res["campaign_id"] + ' .progress-bar-danger').attr('width', res['na_percent'])
              $('.progress_' + res["campaign_id"] + ' .progress-bar-warning').attr('width', res['pu_percent'])
              $('.progress_' + res["campaign_id"] + ' .progress-bar-success').attr('width', res['pm_percent'])
              $('.progress_' + res["campaign_id"] + ' .progress-bar-danger').attr('tip',
                  "Total Leads: " + res["total_all"] + "  \n No Answer: " + res["na"] + " ")
              $('.progress_' + res["campaign_id"] + ' .progress-bar-warning').attr('tip',
                  "Total Leads: " + res["total_all"] + "  \n  Dial but Call Diconnected : " + res["pu"])
              $('.progress_' + res["campaign_id"] + ' .progress-bar-success').attr('tip',
                  "Total Leads: " + res["total_all"] + "  \n Played Message: " + res["pm"])
            error: (res) ->
              return
            complete: (res) ->
          })
          i++
      , 10000);
    else
      clearTimeout(t)
      campaigns = []


  update_campaign_status = (id, percent) ->
    if percent > 0 && percent < 100
      status = "Started"
    else if percent == 100
      status = "Completed"
    $.ajax({
      url: "/campaign_results/update_campaign_status?campaign_id=" + id + "&status=" + status
      type: 'PUT'
      success: (res) ->
        if res["status"] == "Updated"
          $('.status_' + res["campaign_id"]).find('span').text(status)
      error: (res) ->
        return
      complete: (res) ->
        })
  # function to initiate Daily Chart
  runDailyChart = ->
    choiceContainer = $("#daily_choices")
    datasets = {"Call Picked Up": {label: "Call Picked Up"}, "Played Message": {label: "Played Message"}, "Not Answer": {label: "Not Answer"}}
    $.each datasets, (key, val) ->
      color = {"Call Picked Up": "#FABB3D", "Played Message": "#2FABE9", "Not Answer": "#FA5833"}
      choiceContainer.append "<div style='clear:both;'><input type='checkbox' name='" + key + "' checked='checked' id='id" + key + "'></input><div style='width:4px;float:left;margin-top:5px;height:0;border:5px solid " + color[key] + ";overflow:hidden'></div>" + "<label for='id" + key + "'>" + val.label + "</label></div>"
      return
    choiceContainer.find("input").iCheck(
      checkboxClass: "icheckbox_square-grey"
      radioClass: "iradio_square-grey"
      increaseArea: "10%"
    ).on "ifClicked", (event) ->
      $(this).iCheck "toggle"
      create_graph()
      return
    $.ajax({
      url: "/campaign_results/get_daily_calls"
      type: 'GET'
      success: (res) ->
        datasets = res
        create_graph(res)
      error: (res) ->
        return
      complete: (res) ->
    })

    create_graph = (res) ->
      data = []
      choiceContainer.find("input:checked").each ->
        key = $(this).attr("name")
        data.push datasets[key]  if key and datasets[key]
      plot = $.plot("#placeholder-daily", data,
        series:
        # points:
        #   show: true
        #   fillColor: "red"

          lines:
            show: true
            lineWidth: 3
          colors: ["#37b7f3", "#d12610", "#52e136"]
        legend:
          show: false
        xaxis:
          mode: "categories"
          tickLength: 0
          font:
            size: 12
            color: "#424242"
          width: "15px"
        grid:
          backgroundColor: "#FFFFFF"
          hoverable: true
      )
    previousPoint = null
    $("#placeholder-daily").bind "plothover", (event, pos, item) ->
      $("#x").text pos.x.toFixed(2)
      $("#y").text pos.y.toFixed(2)
      if item
        unless previousPoint is item.dataIndex
          previousPoint = item.dataIndex
          $("#tooltip").remove()
          x = item.datapoint[0]
          y = item.datapoint[1]
          $.showTooltip item.pageX, item.pageY, "#{y} calls"
      else
        $("#tooltip").remove()
        previousPoint = null

  # function to initiate Realtime Chart
  runRealtimeChart = ->
    totalPoints = 300
    updateInterval = 60000
    index = 0
    plot = null
    choiceContainer = $("#realtime_choices")
    datasets = {"Call Picked Up": {label: "Call Picked Up"}, "Played Message": {label: "Played Message"}, "Not Answer": {label: "Not Answer"}}
    $.each datasets, (key, val) ->
      color = {"Call Picked Up": "#FABB3D", "Played Message": "#2FABE9", "Not Answer": "#FA5833"}
      choiceContainer.append "<div style='clear:both;'><input type='checkbox' name='" + key + "' checked='checked' id='id" + key + "'></input><div style='width:4px;float:left;margin-top:5px;height:0;border:5px solid " + color[key] + ";overflow:hidden'></div>" + "<label for='id" + key + "'>" + val.label + "</label></div>"
      return
    choiceContainer.find("input").iCheck(
      checkboxClass: "icheckbox_square-grey"
      radioClass: "iradio_square-grey"
      increaseArea: "10%"
    ).on "ifClicked", (event) ->
      $(this).iCheck "toggle"
      update()
      return
    update = ->
      $.ajax({
        url: "/campaign_results/get_realtime_calls"
        type: 'GET'
        success: (res) ->
          console.log(res)
          datasets = res
          create_graph(res)
        error: (res) ->
          return
        complete: (res) ->
      })
      setTimeout update, updateInterval

      return

    $("#updateInterval").val(updateInterval).change ->
      v = $(this).val()
      if v and not isNaN(+v)
        updateInterval = +v
        if updateInterval < 1
          updateInterval = 1
        else updateInterval = 2000  if updateInterval > 2000
        $(this).val "" + updateInterval
      return
    create_graph = (res) ->
      data = []
      colorChoices = {"Call Picked Up": "#FABB3D", "Played Message": "#2FABE9", "Not Answer": "#FA5833"}
      colorArr = []
      choiceContainer.find("input:checked").each ->
        key = $(this).attr("name")
        data.push res[key]  if key and res[key]
        colorArr.push colorChoices[key]
      plot = $.plot("#placeholder-realtime", data,
        series:
        # points:
        #   show: true
        #   fillColor: "red"
          lines:
            show: true
            lineWidth: 3
        colors: colorArr
        legend: {show: false}
        xaxis:
          mode: "categories"
          tickLength: 0
          font:
            size: 14
            color: "#424242"
        grid:
          backgroundColor: "#FFFFFF"
          hoverable: true
      )
    update()
    previousPoint = null
    $("#placeholder-realtime").bind "plothover", (event, pos, item) ->
      $("#x").text pos.x.toFixed(2)
      $("#y").text pos.y.toFixed(2)
      if item
        unless previousPoint is item.dataIndex
          previousPoint = item.dataIndex
          $("#tooltip").remove()
          x = item.datapoint[0]
          y = item.datapoint[1]
          $.showTooltip item.pageX, item.pageY, "#{y} calls"
      else
        $("#tooltip").remove()
        previousPoint = null

  # function to initiate Weekly Chart
  runWeeklyChart = () ->
    week_data = null

    datasets = {"Dialers Calls": {label: "Dialers Calls"}, "Dashboard Users": {label: "Dashboard Users"}}
    choiceContainer = $("#weekly_choices")
    $.each datasets, (key, val) ->
      color = {"Dialers Calls": "#474747", "Dashboard Users": "#2F9CD7"}
      choiceContainer.append "<div style='clear:both;'><input type='checkbox' name='" + key + "' checked='checked' id='id" + key + "'></input><div style='width:4px;float:left;margin-top:5px;height:0;border:5px solid " + color[key] + ";overflow:hidden'></div>" + "<label for='id" + key + "'>" + val.label + "</label></div>"
      return
    choiceContainer.find("input").iCheck(
      checkboxClass: "icheckbox_square-grey"
      radioClass: "iradio_square-grey"
      increaseArea: "10%"
    ).on "ifClicked", (event) ->
      $(this).iCheck "toggle"
      create_graph(datasets, week_data)
      return
    $.ajax({
      url: "/campaign_results/get_weekly_users"
      type: 'GET'
      success: (res) ->
        datasets = {"Dialers Calls": {data: res[0], label: "Dialers Calls", color: "#474747"}, "Dashboard Users": {data: res[1], label: "Dashboard Users", color: "#2F9CD7"}}
        week_data = res[2]
        create_graph(datasets, week_data)
      error: (res) ->
        return
      complete: (res) ->
    })

    create_graph = (res, week_data) ->
      data = []
      choiceContainer.find("input:checked").each ->
        key = $(this).attr("name")
        data.push datasets[key]  if key and datasets[key]
      if data.length > 0
        $.plot "#placeholder-weekly", data,
          legend:
            show: false
          series:
            bars:
              show: true
              lineWidth: 13
              fill: true
              fillColor:
                colors: [
                  {opacity: 1},
                  {opacity: 1}
                ]
            points:
              show: true
            shadowSize: 2
          bars:
            align: "center"
            barWidth: 0.1
            order: 1
            show: 1
          grid:
            hoverable: true
            clickable: true
            tickColor: "#eee"
            borderWidth: 0
          colors: ["#474747", "#2F9CD7"]
          yaxis:
            min: 0
          xaxis:
            autoscaleMargin: 0.1
            tickLength: 0
            ticks: week_data
            mode: "weekday"

    previousPoint = null
    $("#placeholder-weekly").bind "plothover", (event, pos, item) ->
      $("#x").text pos.x.toFixed(2)
      $("#y").text pos.y.toFixed(2)
      if item
        unless previousPoint is item.dataIndex
          previousPoint = item.dataIndex
          $("#tooltip").remove()
          x = item.datapoint[0]
          y = item.datapoint[1]
          $.showTooltip item.pageX, item.pageY, "#{y} calls"
      else
        $("#tooltip").remove()
        previousPoint = null


      
