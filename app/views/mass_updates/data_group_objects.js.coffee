$("<%= @selector %>").html "<%= escape_javascript(render 'mass_updates/data_group_objects', objects: @objects, selected: @selected, group: @group, group_class: @group_class) %>"

$(".icheck-me").each ->
  skin =  "_" + $(this).attr('data-skin')
  color = "-" + $(this).attr('data-color')
  $(this).iCheck(checkboxClass: 'icheckbox' + skin + color, radioClass: 'iradio' + skin + color)


$(".submit_form_in_panel_body").on "click", (e) ->
  $("<%= @selector %>").find("form").submit()