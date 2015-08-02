$(".loaded_minutes").show()
$(".loading_minutes").hide()
$("#minutes_graph_panel").html "<%= escape_javascript(render 'graphs/minutes_chart', station: @station, labels: @labels, values: @values) %>"

$(".change_minutes_chart").on "change", (e) ->
  $(".loaded_minutes").hide()
  $(".loading_minutes").show()
  $(this).parents("form").submit()

$("select.select").each ->
  if $(this).hasClass("without_search")
    $(this).select2
      allowClear: true
      minimumResultsForSearch: -1    
  else if $(this).hasClass("without_css")
  else
    $(this).select2
      allowClear: true

if $("#minutes_graph").length > 0

  labels = "<%= @labels %>".split(",")
  values = "<%= @values %>".split(",")
  obj = []
  $.each labels, (index, label) ->
    obj.push([label, values[index]])

  $.plot "#minutes_graph", [obj],
    series:
      lines:
        show: true
        lineWidth: 3
      color: "#37b7f3"
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
$("#minutes_graph").bind "plothover", (event, pos, item) ->
  $("#x").text pos.x.toFixed(2)
  $("#y").text pos.y.toFixed(2)
  if item
    unless previousPoint is item.dataIndex
      previousPoint = item.dataIndex
      $("#tooltip").remove()
      x = item.datapoint[0]
      y = item.datapoint[1]
      $.showTooltip item.pageX, item.pageY, "#{y} minutes"
  else
    $("#tooltip").remove()
    previousPoint = null
  return
