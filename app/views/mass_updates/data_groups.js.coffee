$("#data_groups").html "<%= escape_javascript(render 'mass_updates/data_groups', groups: @groups, objects: @objects, country_id: @country.id)%>"
$("#data_groups").addClass("active")
$("#data_groups_button").addClass("active")
$("#data_tags").removeClass("active")
$("#data_tags_button").removeClass("active")

$("select.select").each ->
  if $(this).hasClass("without_search")
    $(this).select2
      allowClear: true
      minimumResultsForSearch: -1
  else if $(this).hasClass("without_css")
  else
    $(this).select2
      allowClear: true

$(".submit_via_onchange").on "change", (e) ->
  $(".loading").show()
  $(".loaded").hide()
  $(this).parents("form").submit()


$(".toggle_group_button").on "click", (e) ->
  if $(this).hasClass("collapses")
    $(this).parents(".panel").find(".panel-footer").hide()
  else
    $(this).parents(".panel").find(".panel-footer").show()
    $(this).parents("form").submit()

$(".panel-tools .panel-collapse").bind "click", (e) ->
  e.preventDefault()
  el = jQuery(this).parent().closest(".panel").children(".panel-body")
  if $(this).hasClass("collapses")
    $(this).addClass("expand").removeClass "collapses"
    el.slideUp 200
  else
    $(this).addClass("collapses").removeClass "expand"
    el.slideDown 200
  return
