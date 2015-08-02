# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class window.DataCarrierRule
  constructor: ->
    @setup()
  setup: ->
    modalFormSubmition()
    updateRules()
    updatePromptLists()
    updatePromptHandler()
    setPlay()

  setPlay = () ->
    $('.playWavBtn').click (e) ->
      e.preventDefault()
      $('#promptPlayer').modal 'show'
      wavurl = $(this).attr('href')
      console.log wavurl
      $("#backup_media_url_player").jPlayer("destroy")
      promptPlayer(wavurl)      

  promptPlayer = (wavurl) ->
    $("#backup_media_url_player").jPlayer
        ready: -> 
          $(this).jPlayer "setMedia",
            title: ""
            mp3: wavurl
        swfPath: "Jplayer.swf"
        cssSelectorAncestor: "#jp_container_2"
        solution: 'flash, html'
        supplied: "mp3"
        errorAlerts: true
        warningAlerts: false

  updatePromptHandler = () ->
    btn = $('.promptHandlerBtn')
    btn.on 'click', (e) ->
      e.preventDefault()
      handlers = $('select[name="gateway_prompt_handler_id"]')
      data = handlers.serialize
      handlers.removeClass('hide').select2().on 'change', () ->
        $.ajax({
          url: 'data_carrier_rule/gateway/prompt_handler'
          type: 'get'
          data: {gateway_prompt_handler_id: handlers.val()}
          success: (res) ->
            $('#data_gateway_prompt_gateway_id').val(res.gateway_id)
            handlers.addClass('hide')
        })

  updatePromptLists = () ->
    gateway_select = $('select[name="data_carrier_rule[gateway_id]"]')
    prompt_select = $('select[name="data_carrier_rule[gateway_prompt_id]"]')
    gateway_select.on 'change', () ->
      gateway_select_val = $(this).val()
      # $('input[name="data_gateway_prompt[gateway_id]"]').val(gateway_select_val)
      if $(this).val() != ''
        # console.log(gateway_select_val)
        prompt_select.prop('disabled', false)
        $('button[data-target="#newCarrierPromptModal"]').prop('disabled', false)
        # $.ajax({
        #   url: "/data_gateway_prompt/#{gateway_select_val}/prompts/"
        #   type: 'get'
        #   success: (res) ->
        #     options = ""
        #     $.each(res, (k, v) ->
        #       options += "<option value='#{v.id}'>#{v.title}</option>"
        #     )
        #     prompt_select.select2('destroy').html(options).select2()
        # })
      else
        prompt_select.prop('disabled', true)
        $('button[data-target="#newCarrierPromptModal"]').prop('disabled', true)

  updateRules = () ->
    $('.editRule').on 'click', (e) ->
      e.preventDefault()
      data = JSON.parse($(this).attr('data-object'))
      rule = JSON.parse(data.rule)
      prompts = JSON.parse(data.prompts)
      # newOptions = ""
      # $.each(prompts, (k, v) ->
      #   newOptions += "<option value='#{v.id}'>#{v.title}</option>"
      # )
      # console.log(newOptions)
      form = $('#editRuleForm')
      form.find('input[name="id"]').val(rule.id)
      form.find('select[name="data_carrier_rule[gateway_id]"]').select2('val', rule.gateway_id)
      form.find('select[name="data_carrier_rule[entryway_provider_id]"]').select2('val', rule.entryway_provider_id)
      form.find('select[name="data_carrier_rule[parent_carrier_id]"]').select2('val', rule.parent_carrier_id)
      # form.find('select[name="data_carrier_rule[gateway_prompt_id]"]').select2('destroy').html(newOptions).select2()
      form.find('select[name="data_carrier_rule[gateway_prompt_id]"]').select2('val', rule.gateway_prompt_id)
      check = if rule.hangup_after_play then 'check' else 'uncheck'
      form.find('input[name="data_carrier_rule[hangup_after_play]"]').iCheck(check)
      check = if rule.is_enabled then 'check' else 'uncheck'
      console.log(rule.is_enabled)
      console.log(check)
      form.find('input[name="data_carrier_rule[is_enabled]"]').iCheck(check)
      $('.submitRuleUpdate').click ->
        $(this).attr('disabled', true).text('Please wait...')
        form = $(this).attr('data-target')
        $(form).submit()

  modalFormSubmition = () ->
    formTarget = null
    btn = $('.modalBtn')
    btn.on 'click', (e) ->
      e.preventDefault()
      $(this).attr('disabled', true).text('Please wait...')
      formTarget = $(this).attr('data-target')
      formdata = $(formTarget).serialize()
      formurl = $(formTarget).attr('action')
      formmodal = $(this).attr('data-modal')
      formtype = $(this).attr('data-type')
      if formtype == 'carrier'
        $.ajax({
          data: formdata
          url: formurl
          type: 'post'
          success: (res) ->
            console.log(res)
            carrier = JSON.parse(res.carrier)
            console.log(carrier)
            if res.status == 'ok'
              newOptions = "<option value='#{carrier.id}'>#{carrier.title}</option>"
              $("#data_carrier_rule_parent_carrier_id").select2('destroy').append(newOptions).select2().select2('val', carrier.id);
              $(formmodal).modal('hide')
            if res.status == 'error'
              error = JSON.parse(res.error)
              errormsg = ''
              $.each(error, (k, v) ->
                errormsg += k + ": " + v + "\n"
              )
              alert(errormsg)
        })
      else if formtype == 'prompt'
        options = {success:  uploadResponse}
        $("#data_gateway_prompt_gateway_id").attr('disabled', false)
        $(formTarget).ajaxSubmit(options)

  uploadResponse = (responseText, statusText, xhr, $form) ->
    console.log(responseText)
    prompt = JSON.parse(responseText.prompt)
    if responseText.status == 'ok'
      newOptions = "<option value='"+prompt.id+"'>"+prompt.title+"</option>"
      $("#data_carrier_rule_gateway_prompt_id").select2('destroy').append(newOptions).select2().select2('val', prompt.id)
      console.log(prompt.id)
      $('#newCarrierPromptModal').modal('hide')
      $("#data_gateway_prompt_gateway_id").attr('disabled', true)
    if responseText.status == 'error'
      error = JSON.parse(responseText.error)
      errormsg = ''
      $.each(error, (k, v) ->
        errormsg += k + ": " + v + "\n"
      )
      alert(errormsg)