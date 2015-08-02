$("#view_campaign_modal").html "<%= escape_javascript(render 'campaign_results/view_campaign', campaign_status: @campaign_status) %>"
$("#view_campaign_modal").modal "show"
