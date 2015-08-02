class window.NewCampaignResults
  constructor: ->
    @setup()

  setup: ->
    initiatedatepicker()
    runRealtimeChart()
    setTimeout(getCampaignStatistics(), 3000)
    setInterval(getCampaignStatistics(), 60000)
    setCampaignId()
    getModalContent()
    $("#daily_tab").click ->
    if !$('#placeholder-daily').children('canvas').length > 0
      runDailyChart()
    $("#weekly_tab").click ->
      if !$('#placeholder-weekly').children('canvas').length > 0
        runWeeklyChart()
    toggelZone()

  toggelZone = () ->
    $(document).on 'change', '.toggleZones', () ->
      if $(this).is(':checked')
        $(document).find('.zoneTable').removeClass('hide')
      else
        $(document).find('.zoneTable').addClass('hide')

  setZoneStats = (stats) ->
    table = "<table class='zoneTable hide table table-bordered'>"
    table += "<thead>"
    table +=   "<tr>"
    table +=    "<th class='acenter'>Zone</th>"
    table +=    "<th class='hide'>Local Time</th>"
    table +=    "<th class='acenter'>Sent</th>"
    table +=    "<th class='acenter'>Not sent</th>"
    table +=   "</tr>"
    table += "</thead>"
    table += "<tbody>"
    $.each(stats.zones.total_zones, (k, zone) ->
      table += "<tr>"
      table +=  "<td class='acenter'>#{zone.zone}</td>"
      table +=  "<td class='acenter hide'>#{zone.local_date}</td>"
      table +=  "<td class='acenter'>#{zone.zone_yes}</td>"
      table +=  "<td class='acenter'>#{zone.zone_no}</td>"
      table += "</tr>"
    )
    table += "</tbody>"
    table += "<tfoot>"
    table +=  "<tr>"
    table +=   "<td colspan='1'>"
    table +=    "<b>Total: #{stats.zones.totalAll}</b>"
    table +=   "</td>"
    table +=   "<td class='acenter'>"
    table +=    "<b>#{stats.zones.totalY}</b>"
    table +=   "</td>"
    table +=   "<td class='acenter'>"
    table +=    "<b>#{stats.zones.totalN}</b>"
    table +=   "</td>"
    table +=  "</tr>"
    table += "</tfoot>"
    table += "</table>"
    return table

  setStatusTable = (stats) ->
    table = "<table class='table table-bordered'>"
    table += "<thead>"
    table +=   "<tr>"
    table +=    "<th class='acenter'>Status</th>"
    table +=    "<th>Status Name</th>"
    table +=    "<th class='acenter'>Sent</th>"
    table +=    "<th class='acenter hide'>Not sent</th>"
    table +=   "</tr>"
    table += "</thead>"
    table += "<tbody>"
    $.each(stats.statuses.total_stats, (k, total_stats) ->
      table += "<tr>"
      table +=  "<td class='acenter'>#{total_stats.status}</td>"
      table +=  "<td class='acenter'>#{total_stats.status_name}</td>"
      table +=  "<td class='acenter'>#{total_stats.status_yes}</td>"
      table +=  "<td class='acenter hide'>#{total_stats.status_yes}</td>"
      table += "</tr>"
    )
    table += "</tbody>"
    table += "<tfoot>"
    table +=  "<tr>"
    table +=   "<td colspan='2'>"
    table +=    "<b>Total: #{stats.statuses.totalAll}</b>"
    table +=   "</td>"
    table +=   "<td class='acenter'>"
    table +=    "<b>#{stats.statuses.totalY}</b>"
    table +=   "</td>"
    table +=   "<td class='acenter hide'>"
    table +=    "<b>#{stats.statuses.totalN}</b>"
    table +=   "</td>"
    table +=  "</tr>"
    table += "</tfoot>"
    table += "</table>"
    return table

  getModalContent = () ->
    $('#viewCampaignModal').on 'shown.bs.modal', () ->
      campaign_id = $(this).attr('data-campaign')
      url = "/campaign_results/#{campaign_id}/view"
      $.ajax({
        url: url
        type: 'GET'
        async: true
        success: (response) ->
          console.log response
          if response.length > 0
            $('#viewCampaignModal').find('.loader').hide();
            $.each(response, (idx, value) ->
              $('#viewCampaignModal').find('.modal-body')
                                     .append("<h4>Campaign ID: #{value[1]}</h4>")
              $('#viewCampaignModal').find('.modal-body')
                                     .append(setStatusTable(value[0].stats))
              $('#viewCampaignModal').find('.modal-body')
                                     .append(setZoneStats(value[0].stats))
            )
          else
            $('#viewCampaignModal').find('.loader').hide();
            $('#viewCampaignModal').find('.modal-body').html('Campaign details for this campaign is not available.')
      })

    $('#editCampaignModal').on 'shown.bs.modal', () ->
      campaign_id = $(this).attr('data-campaign')
      gateway_id = $(this).attr('data-gateway')
      url = "/campaign_results/#{campaign_id}/edit?gateway_id=#{gateway_id}"
      $.ajax({
        url: url
        type: 'GET'
        async: true
        success: (response) ->
          console.log response
          if response.length > 0
            $('#editCampaignModal').find('.loader').hide();
            $('#editCampaignModal').find('.modal-body')
                                   .html($(response).find('.modal-body'))
          else
            $('#editCampaignModal').find('.loader').hide();
            $('#editCampaignModal').find('.modal-body').html('Edit for this campaign is not available.')
      })

  setCampaignId = () ->
    $(document).on 'click', '.viewCampaign, .editCampaign', () ->
      campaign_id = $(this).attr('data-campaign')
      gateway_id = $(this).attr('data-gateway')
      $('#viewCampaignModal, #editCampaignModal').attr('data-campaign', campaign_id)
                                                 .attr('data-gateway', gateway_id)
                                                 .find('.modal-body')
                                                 .html('<img class="loader" alt="Loader" src="/assets/loader.gif" style="width: 30px; margin: 0 auto; display: block;">')

  initiatedatepicker = () ->
    $('#data_filter').datepicker
      clearBtn: true
      format: "yyyy-mm-dd"

  getCampaignStatistics = () ->
    $('.progress').each (campaign) ->
      campaign_id = $(this).attr('data-progress')
      setTimeout(getStats(campaign_id), 200)

  getStats = (campaign_id) ->
    $.ajax({
      url: "/campaign_results/statistics?campaign_id=#{campaign_id}"
      type: 'GET'
      async: true
      success: (response) ->

        na = "FAILED: #{response.na} \n Total Leads: #{response.total_all}"
        pu = "HANG UP: #{response.pu} \n Total Leads: #{response.total_all}"
        pm = "SUCCESSFUL: #{response.pm} \n Total Leads: #{response.total_all}"

        progress_sel = ".progress_" + campaign_id + " .progress-bar"
        progress = $(progress_sel)

        setTimeout(progress.eq(0).attr('style', "width:#{response.na_percent}%").attr('title', "#{na}").tooltip(), 1000)
        setTimeout(progress.eq(1).attr('style', "width:#{response.pu_percent}%").attr('title', "#{pu}").tooltip(), 2000)
        setTimeout(progress.eq(2).attr('style', "width:#{response.pm_percent}%").attr('title', "#{pm}").tooltip(), 3000)
    })


#    chart functions
  runRealtimeChart = ->
    totalPoints = 300
    updateInterval = 60000
    index = 0
    plot = null
    choiceContainer = $("#realtime_choices")
    datasets = {"Call Picked Up": {label: "Hang Up"}, "Played Message": {label: "Success"}, "Not Answer": {label: "Failed"}}
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

  runDailyChart = ->
    choiceContainer = $("#daily_choices")
    datasets = {"Call Picked Up": {label: "Hang Up"}, "Played Message": {label: "Success"}, "Not Answer": {label: "Failed"}}
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