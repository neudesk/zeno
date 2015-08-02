id = "<%= @campaign.id %>"
$("#campaign-loaded-#{id}").html "<%= escape_javascript(render 'campaign_results/show_table', campaigns: @campaign_results ) %>"
$("#campaign-loaded-#{id}").show()
$(".loading").hide()
$("#campaign-#{id}").find(".panel-footer").find("a").html("Hide Details")