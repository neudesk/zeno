$ ->
  $(document).ready customHooks
  $(document).on "page:load", customHooks

customHooks = ->
  $("form").on "submit", () ->
    $("input:submit").prop "disabled", true

  $('body').on 'change', 'input[name="has_stream"]', (e) ->
    if $('input[name="has_stream"]:checked').val() == 'yes'
      $('.streamUrl').removeClass('hide')
      $('input[value="free_streaming"]').iCheck('uncheck');
    else
      $('.streamUrl').addClass('hide')
      $('input[value="free_streaming"]').iCheck('check');
  if $("#pending_user_permission_id").length > 0
    reload_pending(false)
    chosen = $("#pending_user_permission_id").data("value")
    if chosen != undefined || chosen != ""
      $("#role_div").find(".select2-chosen").html("<div>#{chosen}</div>")

  $("#pending_user_permission_id").on "change", (e) ->
    reload_pending(true)

  $(".duplicate_button").on "click", (e) ->
    e.preventDefault()
    $("#duplicate_modal.modal").modal
      backdrop: 'static'
    id = $(this).data("id")
    form_action = "/pending_users/#{id}/duplicate"
    $("#duplicate_form").attr("action", form_action)

  $(".ignore_button").on "click", (e) ->
    e.preventDefault()
    $("#ignore_modal.modal").modal
      backdrop: 'static'
    id = $(this).data("id")
    form_action = "/pending_users/#{id}/ignore"
    $("#ignore_form").attr("action", form_action)
  $('#has_stream_yes').click ->
    $('#streaming_url').removeClass('hide')
  $('#has_stream_no').click ->
    $('#streaming_url').addClass('hide')

reload_pending = (exist) ->
  if $("#pending_user_permission_id").val() == "1" || $("#pending_user_permission_id").val() == undefined || $("#pending_user_permission_id").val() == ""
    $("#group_tr").hide()
    $("#new_group_tr").hide()
  else
    if $("#pending_user_new_group").val() != "" && !exist
      showPendingNewGroup("not_click")
    else
      $("#new_group_tr").hide()
      $("#pending_user_group").find("option").remove()
      $.ajax(
        url: "/admin/users/groups_options"
        data: {
          role: $("#pending_user_permission_id").val()
        }
      ).done (option_list) ->
        $("#group_tr").show()
        $('#pending_user_group').append("<option></option>").select2('destroy')
        $('#pending_user_group').append(option_list.list).select2()
        if option_list.name != undefined
          $(".user_group").find(".select2-chosen").html("<div>#{option_list.name}</div>")
        else
          $(".user_group").find(".select2-chosen").html("")

showPendingNewGroup = (event) ->
  if event == "click"
    $("#pending_user_new_group").val("")
  $("#group_tr").hide()
  $("#new_group_tr").show()

