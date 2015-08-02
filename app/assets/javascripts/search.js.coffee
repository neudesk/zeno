class window.Search
  constructor: (options)->
    isAjaxLoading = options["ajax"]
    if isAjaxLoading
      #page load
      @setupAjaxComponents()
    else
      #ajax load
      @setup(options)

  setupAjaxComponents: (options) ->
    @clickOnSwitchButton()
  
  setup: (options)->   
    @searchSection = $(".main .search")
    @editDataContentSection = $("#edit_data_content_container", @searchSection)
    @btnSubmit = $(".btn-submit", @editDataContentSection)
    @clickOnEditDataContentLink()
    
    
  validateText: (object, parent) =>
    currentErrorObject = $("." + object.data("error-class"), parent)
    currentErrorObject.html("")
    if $.trim(object.val()) is ""
      currentErrorObject.html(object.data("text-error") + " can't be blank")
      currentErrorObject.show()
      setTimeout("$('.error-in-add').fadeOut()", 1500)
      false
    else
      true
      
  clickOnEditDataContentLink: =>
    @btnSubmit.click (e) =>
      form = $("form.edit_data_content")
      title_valid = @validateText($("#data_content_title", @editDataContentSection), @editDataContentSection)
      url_valid = @validateText($("#data_content_media_url", @editDataContentSection), @editDataContentSection)
      if title_valid && url_valid
        form.submit()
      else
        false
        
        
  clickOnSwitchButton: =>
    switch_streams = $('#switch_streams')
    switch_streams.click (e) =>    
      stream_url = $("#data_content_media_url")
      backup_stream = $("#data_content_backup_media_url")
      stream_val = stream_url.val()
      stream_url.val(backup_stream.val())
      backup_stream.val(stream_val)
      false