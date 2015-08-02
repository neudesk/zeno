class window.Station
  t = null
  constructor: (options)->
    @setup(options)


  setup: (options)->
    main()
    mobileWidget()
    getPlayer()
    verify_rca_fields()
    widget_code_snippet()
    request_widget_notification()
    set_content_brd_id()
    copyText()
    showSchedForm()
    saveSchedForm()
    cancelSchedForm()

  cancelSchedForm = () ->
    $(document).on 'click', '.cancelForm', (event) ->
      form = $($(this).attr('data-target'))
      form.slideUp()
      $(this).parent().find('.submitSchedForm').removeClass('submitSchedForm').addClass('showForm').text('Show Schedule')
      $(this).hide()


  saveSchedForm = () ->
    $(document).on 'click', '.submitSchedForm', (event) ->
      event.preventDefault()
      btn = $(this)
      form = $($(this).attr('data-target'))
      form.slideUp()
      btn.text('Saving...')
      setTimeout(() ->
        $.ajax
          url: form.attr('action')
          type: form.attr('method')
          data: form.serialize()
          async: false
          success: (data) ->
            raiseSystemAlert(data.message)
            console.log data.data
            if data.error == 0
              btn.addClass('showForm').removeClass('submitSchedForm').text('Show Schedule')
              btn.parent().find('.cancelForm').hide()
            else
              form.slideDown()
              btn.text('Save')
          error: (data) ->
            raiseSystemAlert('Unexpected error, Please try again.')
            form.slideDown()
            btn.text('Save')
      , 1000)

  showSchedForm = () ->
    $(document).on 'click', '.showForm', (event) ->
      event.preventDefault()
      form = $($(this).attr('data-target'))
      form.slideDown()
      $(this).addClass('submitSchedForm').removeClass('showForm').text('Save')
      $(this).parent().find('.cancelForm').show()

  request_widget_notification = () ->
    $(document).on 'click', 'a.requestWidgetDidBtn', (event) ->
      event.preventDefault()
      btn = $(this)
      parent = btn.parent()
      parent.slideUp(300)
      preloader = parent.parent().find('p.preloader')
      preloader.slideDown(300)
      $.ajax
        url: '/data_gateways/'+btn.attr('data-gateway-id')+'/request_widget_did'
        type: 'post'
        success: (data) ->
          if data.error == 0
            raiseSystemAlert(data.message)
          else
            raiseSystemAlert(data.message)
        error: (data) ->
          raiseSystemAlert('Unexpected error has occured')
        complete: (data) ->
          preloader.slideUp(300)
          parent.slideDown(300)


  widget_code_snippet = () ->
    $(document).on 'click', 'input.configCheckbox', (event) ->
      form = $('#snippetForm')
      name =  $(this).attr('name')
      console.log name
      input = form.find('input[name="'+name+'"]')
      value = null
      if $(this).is(':checked')
        if name == 'player_zeno_logo'
          value = 0
        else
          value = 1
      else
        if name == 'player_zeno_logo'
          value = 1
        else
          value = 0
      console.log value
      input.val(value)

    $(document).on 'submit', '#snippetForm', (event) ->
      event.preventDefault()
      form = $(this)
      btn = form.find('button').text('Please wait...')
      setTimeout(()->
        $.ajax
          url: '/data_gateways/update_gateway_prop'
          data: form.serialize(),
          type: 'post'
          async: false
          success: (data) ->
            console.log(data.message)
            if data.error == 0
              btn.text('Update')
              btn.removeClass('btn-blue').addClass('btn-success')
              $(document).find('#snippetContainer').slideDown()
            else
              raiseSystemAlert(data.message)
          error: (data) ->
            raiseSystemAlert("Unexpected error has occured!")
      , 1000)

  copyText = () ->
    $('a.copy').hover () ->
      $(this).zclip
        path: '/ZeroClipboard.swf'
        copy: () ->
          return $($(this).attr('data-target')).val()
        afterCopy: () ->
          raiseSystemAlert('Snippet code has been copied.')

  set_content_brd_id = () ->
    $(document).on 'ifChecked', 'input[name="set_zeno_brd_id"]', () ->
      checkbox = $(this)
      if checkbox.is(':checked')
        $.ajax
          url: '/data_contents/set_content_brd_id'
          type: 'post'
          async: false
          data:
            brd_id: checkbox.attr('data-brdid')
            content_id: checkbox.attr('data-contentid')
          success: (data) ->
            raiseSystemAlert(data.message)
            checkbox.parents('div.icheckbox_square-blue').remove()
          error: (data) ->
            raiseSystemAlert('Unexpected error occured, Please try again')

  raiseSystemAlert = (message) ->
    modal = $('#systemAlertModal')
    modal.find('.modal-body').html(message)
    modal.modal('show')

  verify_rca_fields = () ->
    $(document).on 'change', 'select.verify_value', () ->
      rca = $('select.verify_value').eq(0).val()
      aca = $('select.verify_value').eq(1).val()
      if aca != '' || rca != ''
        if rca == aca
          alert 'RCA and ACA should not have the same value, Please check.'
          $('.confirmSubmit').prop('disabled': true)
        else
          $('.confirmSubmit').prop('disabled': false)


  getPlayer = () ->
    $(document).on 'click', '.jp-stop', (e) ->
      $('.extensionPlayer').jPlayer('destroy')
      $('#jplayerHtml').html()
      $('.jPlayerHolder').hide().html('')
    $(document).on 'click', '.testExtension', (e) ->
      e.preventDefault()
      $('.extensionPlayer').jPlayer('destroy')
      playerHtml = $('#jplayerHtml').html()
      $('.jPlayerHolder').hide().html('')
      $(this).next().append('<div class="extensionPlayer jp-jplayer"></div>')
      $(this).next().append(playerHtml)
      $(this).next().show()
      streamUrl = $(this).attr('dataurl')
      $(".extensionPlayer").jPlayer
        ready: ->
          $(this).jPlayer "setMedia",
            title: ""
            wav: streamUrl + "/;"
        swfPath: "../../assets/Jplayer.swf"
        cssSelectorAncestor: "#jp_container_2"
        solution: 'flash, html'
        supplied: "wav"
        errorAlerts: true,
        warningAlerts: false

  #          $(this).jPlayer "setMedia",
  #            title: ""
  #            mp3: streamUrl
  #            wav: streamUrl
  #            ogg: streamUrl
  #        swfPath: "/Jplayer.swf"
  #        cssSelectorAncestor: "#jp_container_2"
  #        solution: 'flash, html'
  #        supplied: "mp3, wav, ogg"
  #        errorAlerts: true
  #        warningAlerts: false

  checkChannelNumber = (channel) ->
    $.ajax
      url: "data_gateways/check_channel_number"
      data:
        id: $('#station_id').val()
        channel: channel

      success: (data) ->
        if parseInt(data) > 0
          $("#channel_error").removeClass "hide"
          $("#submit_extension").addClass "disabled"
        else
          $("#channel_error").addClass "hide"
          if $("#media_url_error").hasClass("hide") == false && $("#formtype").val() == "add"
            $("#submit_extension").addClass "disabled"
          else
            $("#submit_extension").removeClass "disabled"
        return
    return

  modalHeight = ->
    $("body").css "overflow-y", "auto"
    $(".fix-modal .modal-body").css "max-height", ($(window).height() - 180) + "px"
    $(".fix-modal .modal-dialog").css "margin-left", "-" + ($(".modal-dialog").width() / 2) + "px"
    return

  checkMediaURL = (url) ->
    $.ajax
      url: "/api/check_media_url"
      data:
        media_url: url

      success: (data) ->
        console.log(data)
        if parseInt(data) > 0
          $("#media_url_error").removeClass "hide"
          $("#submit_extension").addClass "disabled"
        else
          $("#media_url_error").addClass "hide"
          if $("#formtype").val() == "add" && $('#channel_error').hasClass("hide") == true
            $("#submit_extension").removeClass "disabled"
        return
    return

  main = () ->
    $("#data_content_media_url").keyup ->
      checkMediaURL $(this).val()
      return

    modalHeight()
    $(window).resize ->
      modalHeight()
      return

    $(".select-action").change ->
      if $(this).val() is "add"
        $("#formtype").val "add"
        $(".add-new-media-url").removeClass "hide"
        $(".select-from-existing-media-url").addClass "hide"
        $(".new-media-url-form").attr "required", "required"
        $(".select-media-url-form").removeAttr "required"
      else
        $("#formtype").val "select"
        $(".select-from-existing-media-url").removeClass "hide"
        $(".add-new-media-url").addClass "hide"
        $(".new-media-url-form").removeAttr "required"
        $(".select-media-url-form").attr "required", "required"
      return

    $("#media_url2").select2(
      placeholder: "Select media URL"
      allowClear: true
      ajax:
        url: "/api/select_media_url"
        dataType: "json"
        type: "GET"
        quietMillis: 50
        data: (term, page) ->
          q: term
          page_limit: 10
          page: page

        results: (data) ->
          results: data.results
          more: data.more
    ).on "change", (e) ->

    $("#media_url2").attr "style", "top: 120px !important;left: 30px !important;"
    $("select.select").select2({allowClear: true})
    slide = $(".slider_content")
    slide.hide()
    $("#pullStationBtn").click ->
      if slide.is(":visible")
        slide.slideUp 300
      else
        slide.slideDown 300
      return

    $(".detachPhone").click (event) ->
      event.preventDefault()
      confirmed = confirm("Are you sure?")
      if confirmed
        url = $(this).attr("href")
        target = $(this).attr("data-target")
        $.ajax(
          type: "GET"
          url: url
          async: false
        ).done (data) ->
          $("." + target).remove()
          return
      return

    $("#new_extension_form").on "submit", ->
      $("a[data-target=\"new_extension_form\"]").addClass "disabled"
      return

    $("a[href=\"#new_phone\"]").on "click", ->
      $.get "/get_phone_list", (data) ->
        data.unshift [
          "Please Select DID"
          ""
        ]
        if data.length > 0
          $("#data_gateway_custom_entryways").html ""
          $.each data, (idx, val) ->
            $("#data_gateway_custom_entryways").append "<option value=\"" + val[1] + "\">" + val[0] + "</option>"
            return

          $("#data_gateway_custom_entryways").select2 "destroy"
          $("#data_gateway_custom_entryways").select2()
        return

      return

    $(document).on "click", "#submit_extension", ( (event) ->
      event.preventDefault()
      if $('span[class="help-block form-error"]').length == 0
        $(this).attr("disabled", "true")
        $('#new_data_content').submit()
    )

    $("#data_content_extension").keyup ->
      if $(this).val() is ""
        $("#submit_extension").addClass "disabled"
      else
        checkChannelNumber $(this).val()
      console.log $(this).val()
      return

    $(document).on "click", ".ajax-action", (e) ->
      $this = $(this)
      c = confirm($(this).data("confirm"))
      if c is true
        $.ajax
          type: "POST"
          url: $(this).attr("href")
          dataType: "json"
          success: (data) ->
            if data.response is "Success"
              $.gritter.add
                title: data.response + "!"
                text: data.message
            console.log data
            return
      false

    $(document).on 'click', '#schedule_content_off', (() ->
      if $('.content_schedule').is(':visible')
        $(this).val('Show Schedule')
        $('.content_schedule').hide()
      else
        $(this).val('Hide Schedule')
        $('.content_schedule').show()
    )

  mobileWidget = () ->
    $('#mobileWidgetModal, #mediaPlayerModal').on 'show.bs.modal', () ->
      $('.modal-content iframe').css('height', $(window).height() * 0.75)
      return

    $(document).on 'change', 'input[name="station_tool[is_customized]"], input[name="station_tool[channeling_type]"]', () ->
      targetElem = $(this).attr('data-target')
      if $(this).is(':checked')
        if $(this).val() == $(this).attr('data-val')
          $(targetElem).removeClass('hide')
          if  $("li.customFields").is(':visible')
            nextBtn = $('.next-step').eq(1).removeClass('hide')
            $('.next-step').eq(1).next().addClass('hide')
        else
          $(targetElem).addClass('hide')
          if (!$("li.customFields").is(':visible'))
            nextBtn = $('.next-step').eq(1).addClass('hide')
            $('.next-step').eq(1).next().removeClass('hide')
      return

    $(document).on 'change', '.otherChannel', () ->
      val = $(this).val()
      $('#' + $(this).attr('data-radiotarget')).val(val)
      return

    $('.bfh-slider-handle').css('left', '172px')