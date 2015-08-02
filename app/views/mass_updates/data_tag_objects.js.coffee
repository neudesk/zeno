$("<%= @selector %>").html "<%= escape_javascript(render 'mass_updates/data_tag_objects', objects: @objects, object: @object, selected: @selected ) %>"

$(".icheck-me").each ->
  skin =  "_" + $(this).attr('data-skin')
  color = "-" + $(this).attr('data-color')
  $(this).iCheck(checkboxClass: 'icheckbox' + skin + color, radioClass: 'iradio' + skin + color)


$(".submit_form_in_panel_body").on "click", (e) ->
  $("<%= @selector %>").find("form").submit()