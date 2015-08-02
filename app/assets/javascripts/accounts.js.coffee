# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class window.Account
  constructor: ->
    @initAccountForm('#frm-new-account')
    @initAccountForm('#frm-edit-account')
    @initModel()
    @initSearchForm()
    $('.nav-tabs a[href="#edit"]').click => @resetForm('#frm-new-account')

  initSearchForm: ->
    $('#frm-filter-accounts').delegate '#search_role', 'change', ->
      $('#frm-filter-accounts').submit()

  initModel: =>
    $('#tb-users').delegate 'a.icon-edit', 'click', (e)->
      node = $(e.target)
      node.addClass 'in'

    $('#ml-edit-account').on 'shown', (e)=>
      modal = $(e.target)
      modal.find('#users_delete_user').attr('href', '')
      if modal.attr('id')=='ml-edit-account'
        id = $('#tb-users a.icon-edit.in').attr('data-id')
        $.ajax
          url: "/admin/users/#{id}/info"
          dataType: 'json'
          error: ->
          success: (response)=>
            modal.find('#user_title').val(response['title'])
            modal.find('#user_email').val(response['email'])
            modal.find('#user_role').val(response['role'])
            modal.find('#user_enabled').prop('checked', response['enabled'])
            modal.find('#users_delete_user').attr('href', response['link'])
            if response['group']
              gr = modal.find('#user_group')
              gr.prop('disabled', false)
              modal.find('#country').prop('disabled', false)
              @loadGroups modal.find('form'), ->
                gr.val(response['group'])
                modal.find('form').resetClientSideValidations()
            else
              modal.find('form').resetClientSideValidations()

    $('#ml-edit-account').delegate '#btn-update', 'click', (e)->
      id = $('#tb-users a.icon-edit.in').attr('data-id')
      modal = $('#ml-edit-account')
      form = modal.find('form')
      url = form.attr('action') + "?id=#{id}"
      $.ajax
        url: url
        type: 'put'
        dataType: 'json'
        data: form.serialize()
        error: ->
        success: (response)=>
          if response.errors
            $.each response.errors, (k,v) ->
              elm = form.find("[name='user[#{k}]']")
              elm.closest('.control-group').addClass('error')
              if elm.next('.help-inline').length > 0
                elm.next('.help-inline').html(v[0])
              else
                error = $('<span>', {class:'help-inline', html:v[0]})
                elm.parent().append(error)
          else
            modal.modal('hide')
            window.location.reload()

    $('#ml-edit-account').on 'hide', (e)=>
      modal = $(e.target)
      if modal.attr('id')=='ml-edit-account'
        $('#tb-users a.icon-edit').removeClass 'in'
        @resetForm modal.find('#frm-edit-account')

  initAccountForm: (name)=>
    form = $(name)
    @resetForm(name) if form.length>0 and RESET

    form.delegate '#country', 'change', (e)=>
      if e.target.value.trim() == ''
        form.find('.partial_checklist').filter(":not(.sample)").remove()
      else
        @loadChecklist(name)

    user_role_val = parseInt $('#user_role').find('option:selected').prop('value')
    if isNaN(user_role_val) or user_role_val==R_VALUES.marketer
      form.find('#btn-add-group').addClass 'disabled'
      form.find('#new-group').find('input').prop 'disabled', true
      form.find('#new-group').collapse('hide') if $('#new-group.collapse').hasClass('in')
      form.find('#user_group').prop('disabled', true)
      form.find('#country').val('')
      form.find("#country").prop('disabled', true)
      form.find('#user_group option:not([value=""])').remove()
      form.find('.partial_checklist .ck_option').remove()
    else
      @loadGroups(name)
      form.find('#user_group').prop('disabled', false)
      if form.find('#user_group').val().trim() == ''
        form.find('#btn-add-group').removeClass('disabled')
        form.find('#btn-add-group').click() if $('#new-group.collapse.in').find('input:not(:disabled)').length>0

    form.delegate '#user_role', 'change', (e)=>
      val = parseInt e.target.value.trim()
      if isNaN(val) or val==R_VALUES.marketer
        form.find('#btn-add-group').addClass 'disabled'
        form.find('#new-group').find('input').prop 'disabled', true
        form.find('#new-group').collapse('hide') if $('#new-group.collapse').hasClass('in')
        form.find('#user_group').prop('disabled', true)
        form.find('#country').val('')
        form.find("#country").prop('disabled', true)
        form.find('#user_group option:not([value=""])').remove()
        #form.find('.partial_checklist .ck_option').remove()
        form.find('.partial_checklist').filter(":not(.sample)").remove()
      else
        @loadGroups(name)
        form.find('#user_group').prop('disabled', false)
        if form.find('#user_group').val().trim() == ''
          form.find('#btn-add-group').removeClass('disabled')
          form.find('#btn-add-group').click() if $('#new-group.collapse.in').find('input:not(:disabled)').length>0
      form.resetClientSideValidations()


    form.delegate '#user_group', 'change', (e)=>
      if e.target.value.trim() == ''
        form.find('#btn-add-group').removeClass 'disabled'
        $(form).find('.partial_checklist').hide();
        form.find('#country').val('')
        form.find("#country").prop('disabled', true)
      else
        form.find("#country").prop('disabled', false)
        form.find('#btn-add-group').addClass 'disabled'
        @loadChecklist(name)
        if form.find('#new-group.collapse').hasClass('in')
          form.find('#new-group').collapse('hide')
          form.find('#new-group').find('input').prop('disabled', true).val('')

    form.delegate '#btn-add-group:not(.disabled)', 'click', =>
      form.find("#country").prop('disabled', false)
      @loadChecklist(name) if form.find('#country').val().trim()==''
      inputs = form.find('#new-group').find('input')
      controls = inputs.closest('.control-group')
      controls.removeClass('error')
      controls.find('span.help-inline').remove()
      inputs.prop('disabled', true).val('')
      val = parseInt form.find('#user_role').val().trim()
      if val == R_VALUES.rca
        form.find('#txt-new-rca').prop('disabled', false)
      else if val == R_VALUES.broadcaster
        form.find('#txt-new-broadcast').prop('disabled', false)
      else if val == R_VALUES["3rd_party"]
        form.find('#txt-new-3rd-party').prop('disabled', false)

      form.find('#new-group').collapse('show')
      form.resetClientSideValidations()

  resetForm: (name) ->
    form = $(name)
    form.resetClientSideValidations() if form.length>0 and form[0].ClientSideValidations
    form.find('input[type!=submit]').not('[type=hidden]').val('')
    form.find('#btn-add-group').addClass 'disabled'
    form.find('#new-group').find('input').prop 'disabled', true
    form.find('#user_role').val('')
    form.find('#user_group').prop('disabled', true)
    form.find('#country').val('')
    form.find("#country").prop('disabled', true)
    form.find('#user_group option:not([value=""])').remove()
    #form.find('.partial_checklist .ck_option').remove()
    form.find('.partial_checklist').filter(":not(.sample)").remove()
    form.find('#user_enabled').prop('checked')
    form.find('#user_enabled').val(1)

  loadGroups: (form, callback=null)=>
    $.ajax
      url: '/admin/users/groups_options'
      data: {
        role: $(form).find('#user_role').val()
      }
      dataType: 'html'
      error: ->
      success: (response)=>
        $(form).find('#user_group option:not([value=""])').remove()
        $(form).find('#user_group').append response
        @loadChecklist(form) if $(form).find('.country_field:visible').val().trim()!=''
        callback() if callback

  loadChecklist: (form) ->
    $.ajax
      url: '/admin/users/gateways_checklist'
      data: {
        role: $(form).find('#user_role').val(),
        group: $(form).find('#user_group').val(),
        country: $(form).find('#country').val()
      }
      dataType: 'html'
      error: ->
      success: (response)->


        country_id = $(form).find('.country_field:visible').val();

        if $(form).find('.partial_checklist[class*="'+country_id+'"]').size() == 0

          $(form).find('.partial_checklist').hide();

          new_checklist = $(form).find('.checklist').find('.partial_checklist.sample').clone()

          $(form).find('.checklist').append(new_checklist);

          $(form).find('.checklist').find('.partial_checklist:last').removeClass('sample').removeClass('hide').addClass('country-'+country_id);

          $(form).find('.partial_checklist:last').data('country-id', country_id);

          $(form).find('.partial_checklist:last').append response;
          $(form).find('.partial_checklist:last').show();
        else
          $(form).find('.partial_checklist').hide();
          $(form).find('.partial_checklist[class*="'+country_id+'"]').show();


