$ ->
  $(document).ready customHooks
  $(document).on "page:load", customHooks

customHooks = ->
  $('.group_action').on 'click', (e) ->
    e.preventDefault()
    type = $(this).attr('data-type')
    target = $(this).attr('data-target')
    if type == 'new'
      $('.groupinput').addClass('hide')
      $('#'+target).removeClass('hide')
    if type == 'choose'
      $('.groupinput').addClass('hide')
      $('#'+target).removeClass('hide').find('select').attr('disabled', false)
    if type == 'edit'
      $('.groupinput').addClass('hide')
      $('#'+target).removeClass('hide')

  if $("#user_permission_id").length > 0
    reload(false)

  $("#user_permission_id").on "change", (e) ->
    reload(true)

  $("#user_filter").on "change", (e) ->
    $(this).parents("form").submit()

  $("#user_country_holder").each ->
    records = $(this).data("data")
    if records == null
      $(this).select2()
    else if records != undefined
      obj = []
      $.each records, (index, value) ->
        if value != ""
          obj.push({"id":value, "text": value})
      $("#user_country_holder").select2(
      ).select2 "data", obj

  $("#add_new_group").on "click", (e) ->
    e.preventDefault()
    showNewGroup("click")
  $(document).on "click", "#message_type", () ->
    if $(this).val() == "inapp"
      $('#subject').hide()
    else
      $('#subject').show()

  $(".sort_role").on "click", (e) ->
    permission = $(this).data("permission")
    $("#user_filter").val(permission)
    $("#new_user").submit()

  $(document).on "click",'.messages-item', () ->
    id = $(this).attr('data-id')
    window.location.href = "/conversations?message=" + id

  $(document).on "ajax:complete", '#reply_form' , () ->
      id = $("#message_id").val()
      $.ajax({
         url: "/users/get_conversations?message=" + id 
         type: 'GET'
         success: (res) ->
          $('.conv').html(res)
          $('.conversation .loading').hide()
          $('.btn-message-reply').removeClass('disabled')
          $('#message_type').val("inapp")
         error: (res) ->
           return
         complete: (res) ->
         })

  $(document).on "click", '.btn-message-reply', () ->
    $('.conversation .loading').show()
    $('#reply_form').submit()
    $('#message').val('')
    $(this).addClass('disabled')

  $(document).on "click", '#create_message', () ->
    user_email = $(this).attr('data-email')
    name = $(this).attr('data-name')
    $('#user_email').val(user_email)
    $('#show_bubble_create_message .modal_title p').text("Message to : " + name)
    $('#show_bubble_create_message .message_box').val('');
    $('#show_bubble_create_message .message_box').val('Hi ' + name + ", " )
    $('#show_bubble_create_message').modal("show");

  $(document).on "click", '#bubble', () ->
    user_email = $(this).attr('data-email')
    name = $(this).attr('data-name')
    $('#user_email').val(user_email)
    $('#show_bubble_create_message .modal_title p').text("Message to : " + name)
    $('#show_bubble_create_message .message_box').val('');
    $('#show_bubble_create_message .message_box').val('Hi ' + name + ", " )
    $('#show_bubble_create_message').modal("show");

  $(document).on "click", "#send_message", () ->
    $("#show_bubble_create_message .loading").show()
    $(this).addClass('disabled')


reload = (exist) ->
  if $("#user_permission_id").val() == "1" or $("#user_permission_id").val() == undefined or $("#user_permission_id").val() == ""
    $("#group_tr").hide()
  else
    if $("#user_new_group").val() != "" && !exist
      showNewGroup("not_click")
    else
      $("#group_tr").show()
      $.ajax(
        url: "/admin/users/groups_options"
        data: {
          role: $("#user_permission_id").val()
          user_id: $("#permission_id_for_js").data("user")
        }
      ).done (option_list) ->
        $("#choose select").find("option").remove()
        $('#choose select').append "<option></option>"
        $('#choose select').append option_list.list
        if option_list.name != undefined
          $("#choose").find(".select2-chosen").html("<div>#{option_list.name}</div>")
        else
          $("#choose").find(".select2-chosen").html("")

showNewGroup = (event) ->
  if event == "click"
    $("#user_new_group").val("")
  $("#group_tr").hide()
  $("#new_group_tr").show()


class window.UserGroup
  constructor: ->
    @setup()
  setup: ->
    getGroupOptions()
    getResponse($('select[name="user[permission_id]"]').val())

  setFields = () ->
    $(document).on 'change', $('select[name="method"]'), () ->
      method = $('select[name="method"]').val()
      if method
        $('.optional-field').addClass('hide')
        $(method).removeClass('hide')
        $('.controlled-field').attr('disabled', false)

  getResponse = (permission_id) ->
    if parseInt(permission_id) != 1
      user_id = $("#permission_id_for_js").data("user")
      $.ajax({
        url: "/admin/users/groups_options"
        type: 'GET'
        data: {
          role: permission_id
          user_id: user_id
          async: true
        }
        success: (response) ->
          setGroup(response)
          setFields()
          return true
      })
    else if parseInt(permission_id) == 1
      $('.controlled-field').attr('disabled', true)

  getGroupOptions = () ->
    $(document).on 'change', 'select[name="user[permission_id]"]', (event) ->
      permission_id = $(this).val()
      getResponse(permission_id)

  setGroup = (response) ->
    options = response.list
    current_group_name = response.current_group_name
    $('select[name="user[group]"]').html(options)
    $('input[name="user[edit_group]"]').val(current_group_name)



