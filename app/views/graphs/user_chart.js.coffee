$(".loaded_user").show()
$(".loading_user").hide()
$("#user_graph_panel").html "<%= escape_javascript(render 'graphs/user_chart', station: @station, labels: @labels, values: @values) %>"

$(".change_user_chart").on "change", (e) ->
  $(".loaded_user").hide()
  $(".loading_user").show()
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

if $("#user_graph").length > 0
  labels = "<%= @labels %>".split(",")
  values = "<%= @values %>".split(",")
  obj = []
  $.each labels, (index, label) ->
    obj.push([label, values[index]])

  $.plot "#user_graph", [obj],
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
$("#user_graph").bind "plothover", (event, pos, item) ->
  $("#x").text pos.x.toFixed(2)
  $("#y").text pos.y.toFixed(2)
  if item
    unless previousPoint is item.dataIndex
      previousPoint = item.dataIndex
      $("#tooltip").remove()
      x = item.datapoint[0]
      y = item.datapoint[1]
      $.showTooltip item.pageX, item.pageY, "#{y} users"
  else
    $("#tooltip").remove()
    previousPoint = null
  return
