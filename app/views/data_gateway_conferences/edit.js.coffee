$("#edit_extension_modal").html "<%= escape_javascript(render 'data_gateway_conferences/form_modal', conference: @conference) %>"
$("#edit_extension_modal").modal "show"

$("#media_url_player").jPlayer
    ready: ->
      $(this).jPlayer "setMedia",
        title: ""
        wav: $('#media_url').val() + "/;"
    swfPath: "../../assets/Jplayer.swf"
    cssSelectorAncestor: "#jp_container_1"
    solution: 'flash, html'
    supplied: "wav"
    errorAlerts: true,
    warningAlerts: false

$("#backup_media_url_player").jPlayer
    ready: ->
      $(this).jPlayer "setMedia",
        title: ""
        wav: $('#backup_media_url').val() + "/;"
    swfPath: "../../assets/Jplayer.swf"
    cssSelectorAncestor: "#jp_container_2"
    solution: 'flash, html'
    supplied: "wav"
    errorAlerts: true,
    warningAlerts: false

$("select.select").each ->
  if $(this).hasClass("without_search")
    $(this).select2
      allowClear: true
      minimumResultsForSearch: -1
  else if $(this).hasClass("without_css")
  else
    $(this).select2
      allowClear: true

$("#submit_edit_extension_form").on "click", (e) ->
  e.preventDefault()
  has_error = false
  $("#edit_extension_form").find("input.required").each ->
    if $(this).val() == ""
      has_error = true
  if has_error
    $.alert("Please fill-up all the required fields")
    $('.error_label').text(Please fill-up all the required fields)
  else
    $("#edit_extension_form").submit()

$("#data_gateway_conference_content_media_type").select2("val", "<%= @conference.content.media_type %>")

$(".upload").click (event) ->
  event.stopPropagation();
  event.preventDefault()
  $(".file_upload_" + $(this).attr('id')).click()

$(".file_upload").change () ->
    filename = $(this).val()
    lastIndex = filename.lastIndexOf("\\");
    if lastIndex >= 0 
        filename = filename.substring(lastIndex + 1);
    $('.stream_box_'+$(this).attr('data-id')).val(filename)

$("#edit_extension_modal").on "hidden.bs.modal", ->
  $("#backup_media_url_player").jPlayer "stop"
  $("#media_url_player").jPlayer "stop"

$('#test_backup_media_stream_url').click ->
  console.log "backup_media_url_player"
  $(".backup_media_url_player").toggle()

$('#test_media_stream_url').click ->
  console.log "test_media_stream_url"
  $(".media_url_player").toggle()


$.alert = (message, callback) ->
  return false unless message
  modal_html = "<div id='custom_alert' class='modal'><div class='modal-dialog'><div class='modal-content' id='modal_alert'><div class='modal-body'><p>#{message}</p></div><div class='modal-footer'><a data-dismiss='modal' class='button color'>OK</a></div></div></div></div>"
  $modal_html = $(modal_html)
  $modal_html.modal
    backdrop: 'static'