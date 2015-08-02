$("#edit_content_modal").html "<%= escape_javascript(render 'data_contents/form_modal', content: @content, content_query: @content_query) %>"
$("#edit_content_modal").modal "show"

$(".select2-search-choice-close").each ->
  if $(this).prev(".select2-chosen").html() == ""
    $(this).hide()

$("select.select").each ->
  if $(this).hasClass("without_search")
    $(this).select2
      allowClear: true
      minimumResultsForSearch: -1
  else if $(this).hasClass("without_css")
  else
    $(this).select2
      allowClear: true

$("#submit_edit_content_form").on "click", (e) ->
  e.preventDefault()
  has_error = false
  $("#edit_content_form").find("input.required").each ->
    if $(this).val() == ""
      has_error = true
  if has_error
    $.alert("Please fill-up all the required fields")
  else
    $("#edit_content_form").submit()

$("#data_content_media_type").select2("val", "<%= @content.media_type %>")

$(".select2-search-choice-close").on "click", (e) ->
  $(this).hide()

$("#data_content_media_type"). on "change", (e) ->
  $(".select2-search-choice-close").show()

$('#schedule_content_off').click () ->
      if $('.content_schedule').is(':visible')
        $(this).val('Show Schedule')
        $('.content_schedule').hide()
      else
        $(this).val('Hide Schedule')
        $('.content_schedule').show()
        
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

$.alert = (message, callback) ->
  return false unless message
  modal_html = "<div id='custom_alert' class='modal'><div class='modal-dialog'><div class='modal-content' id='modal_alert'><div class='modal-body'><p>#{message}</p></div><div class='modal-footer'><a data-dismiss='modal' class='button color'>OK</a></div></div></div></div>"
  $modal_html = $(modal_html)
  $modal_html.modal
    backdrop: 'static'