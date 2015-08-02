id = "<%= @days %>"
$("#campaign-loaded-#{id}").html "<%= escape_javascript(render partial: 'daily_list', locals: {campaigns: @campaigns} ) %>"
$("#campaign-loaded-#{id}").show()
$(".loading").hide()
$("#campaign-#{id}").find(".panel-footer").find("a").html("Hide Details")
$('.pagination').children('ul').addClass('pagination');
