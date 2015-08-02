# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class window.WebMail
  constructor: ->
    @setup()
  setup: ->
    sendMail()
    initUploader()

  initUploader = () ->
    $("input#attachment").fileinput
      uploadUrl: "/webmail/attachment"
      uploadAsync: true
      maxFileCount: 5
      dropZoneEnabled: false
      maxFileSize: 2000
      uploadAsync: false
    $("input#attachment").on 'filebatchuploadsuccess', (event, data, previewId, index) ->
      console.log data
      result = $.parseJSON(data.response.data)
      $(document).find('input[name="mail[attachments]"]').val(result)
      attach = ''
      $.each(data.files, (idx, file) ->
        attach += '<li><a><i class="fa fa-paperclip"></i> '+file.name+'</a></li>'
      )
      if attach != ''
        $('#attachmentHolder ul').append(attach)
        $('#attachmentHolder').slideDown(300)
      $('.modal').modal('hide')
      $('input#attachment').fileinput('reset');

  sendMail = () ->
    $(document).on 'click', 'a.sendMessage', (event) ->
      btn = $(this)
      btn.attr('disabled', true)
      form = btn.parents('form')
      preloader = $('a.preloader')
      btn.hide()
      preloader.fadeIn()
      $.ajax
        url: '/webmail'
        type: 'post'
        data:
          template: CKEDITOR.instances['mail_content'].getData()
          recipient: form.find('input[name="mail[recipient]"]').val()
          subject: form.find('input[name="mail[subject]"]').val()
          attachments: form.find('input[name="mail[attachments]"]').val()
          bcc: form.find('input[name="mail[bcc]"]').val()
        success: (data) ->
          raiseSystemAlert(data.message)
        error: (data) ->
          raiseSystemAlert('Unexpected error has occured!')
      $('.modal').on 'hidden.bs.modal', () ->
        btn.attr('disabled', false)
        btn.fadeIn()
        preloader.hide()
        location.reload()

  raiseSystemAlert = (message) ->
    modal = $('#systemAlertModal')
    modal.find('.modal-body').html(message)
    modal.modal('show')