class window.DataGatewayNotes

  constructor: ->
    @setup()

  setup: ->
    createNote()
    editNote()
    cancelEditNote()
    updateNote()
    destroyNote()

  raiseSystemAlert = (message) ->
    modal = $('#systemAlertModal')
    modal.find('.modal-body').html(message)
    modal.modal('show')

  createNote = () ->
    $(document).on 'click', 'button.submitNote', (event) ->
      event.preventDefault()
      form = $(this).parent()
      $.ajax
        type: 'post'
        url: '/data_gateway_notes'
        data: form.serialize()
        success: (data) ->
#          raiseSystemAlert(data.message)
          form.find('textarea').val('')
          $('#note').prepend(buildNoteBox(data))
        error: (data) ->
          raiseSystemAlert('Unexpected error, Please try again.')

  buildNoteBox = (data) ->
    html = '<div class="row" id="noteContainer_'+data.data.id+'">'
    html += '<div class="col-sm-1" style="padding: 5px; margin: 0">'
    html += '<div class="thumbnail">'
    html += '<img class="img-responsive user-photo" src="https://ssl.gstatic.com/accounts/ui/avatar_2x.png">'
    html += '</div>'
    html += '</div>'
    html += '<div class="col-sm-11">'
    html += '<div class="panel panel-default">'
    html += '<div class="panel-heading" style="background: #fff">'
    html += '<strong>'+data.user+'</strong>'
    html += '<span class="text-muted pull-right">'+data.data.created_at+'</span>'
    html += '</div>'
    html += '<div class="panel-body">'
    html += '<div class="noteContent" id="noteContent_'+data.data.id+'">'
    html += data.data.note
    html += '</div>'
    html += '<form action="/data_gateway_notes" id="note_'+data.data.id+'" method="put" style="display: none" class="has-validation-callback">'
    html += '<input id="note_id" name="note_id" type="hidden" value="'+data.data.id+'">'
    html += '<textarea id="note" name="note" rows="10" style="width: 100%; display: block">'+data.data.note+'</textarea>'
    html += '</form>'
    html += '<div class="btn-group pull-right" style="margin-top: 10px;">'
    html += '<button class="btn btn-primary btn-xs" data-method="edit" data-note="#noteContent_'+data.data.id+'" data-target="#note_'+data.data.id+'" type="button">'
    html += '<i class="fa fa-pencil"></i> Edit</button>'
    html += '<button class="btn btn-danger btn-xs" data-method="delete" data-note="#noteContent_'+data.data.id+'" data-target="#note_'+data.data.id+'" type="button" data-note="#noteContent_'+data.data.id+'" data-id="'+data.data.id+'">'
    html += '<i class="fa fa-trash-o"></i> Delete</button>'
    html += '<button class="btn btn-default btn-xs" data-method="save" data-note="#noteContent_'+data.data.id+'" data-target="#note_'+data.data.id+'" style="display: none" type="button">'
    html += '<i class="fa fa-save"></i> Save</button>'
    html += '<button class="btn btn-default btn-xs" data-method="cancel" data-note="#noteContent_'+data.data.id+'" data-target="#note_'+data.data.id+'" style="display: none" type="button">'
    html += '<i class="fa fa-close"></i> Cancel</button>'
    html += '</div>'
    html += '</div>'
    html += '</div>'
    html += '</div>'
    return html

  updateNote = () ->
    $(document).on 'click', 'button[data-method="save"]', () ->
      form = $($(this).attr('data-target'))
      note = $($(this).attr('data-note'))
      $.ajax
        url: form.attr('action')
        data: form.serialize()
        type: 'put'
        async: false
        success: (data) ->
          note.html(data.data.note)
          raiseSystemAlert(data.message)
        error: (data) ->
          raiseSystemAlert('Unexpected error, Please try again.')
      note.show()
      form.hide()
      $(this).parent().find('button[data-method="edit"], button[data-method="delete"]').show()
      $(this).parent().find('button[data-method="cancel"], button[data-method="save"]').hide()

  cancelEditNote = () ->
    $(document).on 'click', 'button[data-method="cancel"]', () ->
      form = $($(this).attr('data-target'))
      note = $($(this).attr('data-note'))
      note.show()
      form.hide()
      $(this).parent().find('button[data-method="edit"], button[data-method="delete"]').show()
      $(this).parent().find('button[data-method="cancel"], button[data-method="save"]').hide()

  editNote = () ->
    $(document).on 'click', 'button[data-method="edit"]', () ->
      form = $($(this).attr('data-target'))
      note = $($(this).attr('data-note'))
      note.hide()
      form.show()
      $(this).parent().find('button[data-method="edit"], button[data-method="delete"]').hide()
      $(this).parent().find('button[data-method="cancel"], button[data-method="save"]').show()

  destroyNote = () ->
    $(document).on 'click', 'button[data-method="delete"]', () ->
      note_id = $(this).attr('data-id')
      if confirm('Are you sure?')
        $.ajax
          url: '/data_gateway_notes'
          data: {note_id: note_id}
          type: 'DELETE'
          async: false
          success: (data) ->
            raiseSystemAlert(data.message)
            $('#noteContainer_'+note_id).remove()
          error: (data) ->
            raiseSystemAlert('Unexpected error, please try again.')
