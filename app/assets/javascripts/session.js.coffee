class window.Session
  constructor: (options)->
    $('#placeholder_daily').html('<div style="width:50px;height:200px;margin: 0 auto;"><img style="margin-top:30px;width:32px;height:32px;" alt="Loader" src="/assets/ajax/loader.gif"></div>')
    $.ajax({
      url: "/session/get_sessions?type=daily"
      type: 'GET'
      success: (res) ->
       $('#placeholder_daily').html('')
       runDailyChart(res)
      error: (res) ->
        return
      complete: (res) ->
      })
    $('#weekly_tab').bind "click", (e) ->
      if !($('#placeholder_weekly').text().length > 0)
        $('#placeholder_weekly').html('<div style="width:50px;height:200px;margin: 0 auto;"><img style="margin-top:30px;width:32px;height:32px;" alt="Loader" src="/assets/ajax/loader.gif"></div>')
        $.ajax({
          url: "/session/get_sessions?type=weekly"
          type: 'GET'
          success: (res) ->
           $('#placeholder_weekly').html('')
           runWeeklyChart(res)
          error: (res) ->
            return
          complete: (res) ->
          })
    $('#monthly_tab').bind "click", (e) ->
      if !($('#placeholder_monthly').text().length > 0)
        $('#placeholder_monthly').html('<div style="width:50px;height:200px;margin: 0 auto;"><img style="margin-top:30px;width:32px;height:32px;" alt="Loader" src="/assets/ajax/loader.gif"></div>')
        $.ajax({
          url: "/session/get_sessions?type=monthly"
          type: 'GET'
          success: (res) ->
           $('#placeholder_monthly').html('')
           runMonthlyChart(res)
          error: (res) ->
            return
          complete: (res) ->
          })
    # function to initiate Daily Chart
    runDailyChart= (sessions) ->
       showTooltip = (x, y, contents) ->
         $("<div id=\"tooltip\">" + contents + "</div>").css(
           position: "absolute"
           display: "none"
           top: y + 5
           left: x + 15
           border: "1px solid #333"
           padding: "4px"
           color: "#fff"
           "border-radius": "3px"
           "background-color": "#333"
           opacity: 0.80
         ).appendTo("body").fadeIn 200
         return
       plot = $.plot($("#placeholder_daily"), [{data: sessions, label: "Sessions"}],
           series: {bars: { show: true}},
           bars: {align: "center",barWidth: 0.6},
           colors: ["#37b7f3","#52e136"]
           grid: {hoverable: true,borderWidth: 2,backgroundColor: { colors: ["#ffffff", "#EDF5FF"] }}
           xaxis:
             mode: "categories",
             tickLength: 0

       )
       $("#placeholder_daily").bind "plothover", (event, pos, item) ->
         $("#x").text pos.x.toFixed(2)
         $("#y").text pos.y.toFixed(2)
         if item
           unless previousPoint is item.dataIndex
             previousPoint = item.dataIndex
             $("#tooltip").remove()
             x = item.datapoint[0].toFixed(0)
             y = item.datapoint[1].toFixed(0)
             showTooltip item.pageX, item.pageY, item.series.label + " : " + y
         else
           $("#tooltip").remove()
           previousPoint = null
         return
       return
    # function to initiate Daily Chart
    runWeeklyChart= (sessions) ->
       showTooltip = (x, y, contents) ->
         $("<div id=\"tooltip\">" + contents + "</div>").css(
           position: "absolute"
           display: "none"
           top: y + 5
           left: x + 15
           border: "1px solid #333"
           padding: "4px"
           color: "#fff"
           "border-radius": "3px"
           "background-color": "#333"
           opacity: 0.80
         ).appendTo("body").fadeIn 200
         return
       plot = $.plot($("#placeholder_weekly"), [{data: sessions, label: "Sessions"}],
           series: {bars: { show: true}},
           bars: {align: "center",barWidth: 0.6},
           colors: ["#37b7f3","#52e136"]
           grid: {hoverable: true,borderWidth: 2,backgroundColor: { colors: ["#ffffff", "#EDF5FF"] }}
           xaxis:
             mode: "categories",
             tickLength: 0

       )
       $("#placeholder_weekly").bind "plothover", (event, pos, item) ->
         $("#x").text pos.x.toFixed(2)
         $("#y").text pos.y.toFixed(2)
         if item
           unless previousPoint is item.dataIndex
             previousPoint = item.dataIndex
             $("#tooltip").remove()
             x = item.datapoint[0].toFixed(0)
             y = item.datapoint[1].toFixed(0)
             showTooltip item.pageX, item.pageY, item.series.label + " : " + y
         else
           $("#tooltip").remove()
           previousPoint = null
         return
       return
    # function to initiate Daily Chart
    runMonthlyChart= (sessions) ->
       showTooltip = (x, y, contents) ->
         $("<div id=\"tooltip\">" + contents + "</div>").css(
           position: "absolute"
           display: "none"
           top: y + 5
           left: x + 15
           border: "1px solid #333"
           padding: "4px"
           color: "#fff"
           "border-radius": "3px"
           "background-color": "#333"
           opacity: 0.80
         ).appendTo("body").fadeIn 200
         return
       plot = $.plot($("#placeholder_monthly"), [{data: sessions, label: "Sessions"}],
           series: {bars: { show: true}},
           bars: {align: "center",barWidth: 0.6},
           colors: ["#37b7f3","#52e136"]
           grid: {hoverable: true,borderWidth: 2,backgroundColor: { colors: ["#ffffff", "#EDF5FF"] }}
           xaxis:
             mode: "categories",
             tickLength: 0

       )
       $("#placeholder_monthly").bind "plothover", (event, pos, item) ->
         $("#x").text pos.x.toFixed(2)
         $("#y").text pos.y.toFixed(2)
         if item
           unless previousPoint is item.dataIndex
             previousPoint = item.dataIndex
             $("#tooltip").remove()
             x = item.datapoint[0].toFixed(0)
             y = item.datapoint[1].toFixed(0)
             showTooltip item.pageX, item.pageY, item.series.label + " : " + y
         else
           $("#tooltip").remove()
           previousPoint = null
         return
       return
