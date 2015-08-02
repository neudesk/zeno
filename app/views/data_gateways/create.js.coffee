if <%= @next.present? %>
  $(location).attr('href',"<%= @next %>")
else
  $("#new_station_fields").html "<%= escape_javascript(render 'data_gateways/form', station: @new_station) %>"
  $('select.select').select2();
  $('.form-submitter').removeClass('disabled');
  $(".icheck-me").each ->
    skin =  "_" + $(this).attr('data-skin')
    color = "-" + $(this).attr('data-color')
    $(this).iCheck(checkboxClass: 'icheckbox' + skin + color, radioClass: 'iradio' + skin + color)

