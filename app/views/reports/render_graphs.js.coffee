$("#charts_result").html "<%= escape_javascript(render 'reports/chart_result', station: @station, labels: @labels, result: @result, new_users: @new_users_values, active_users: @active_users_values, sessions: @sessions_values, minutes: @minutes_values, totals: @totals) %>"
$(".loading").hide()


#$(".change_reports").on "change", (e) ->
#  $(".loading").show()
#  $(this).parents("form").submit()


graphify = (elem, text, color, value1) ->
  labels = "<%= @js_labels %>".split(",")
  values = value1.split(",")

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

if $("#new_users_graph").length > 0
  graphify("#new_users_graph", "users", "#37b7f3", "<%= @js_new_users_values %>")

if $("#active_users_graph").length > 0
  graphify("#active_users_graph", "users", "#d12610", "<%= @js_active_users_values %>")

if $("#sessions_graph").length > 0
  graphify("#sessions_graph", "sessions", "#FF6600", "<%= @js_sessions_values %>")

if $("#report_minutes_graph").length > 0
  graphify("#report_minutes_graph", "minutes", "#52e136", "<%= @js_minutes_values %>")
