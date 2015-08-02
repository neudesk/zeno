class window.Extension
  constructor: (options)->
    isAjaxLoading = options["ajax"]
    if isAjaxLoading
      #page load
      @setupAjaxComponents()
    else
      #ajax load
      @setup(options)

  setupAjaxComponents: (options) ->
    @extensionSection = $(".main .extensions")
    @addExtensionSectionToOtherRoles = $(".add_existing_content_section", @extensionSection)
  
    @clickOnSwitchButton()
    
    #Add extensions
    @changeCountry($(".select-content", @addExtensionSectionToOtherRoles), @addExtensionSectionToOtherRoles)
#    @btnSubmitExistingContent = $(".btn-submit", @addExtensionSection)
    @btnSubmitExistingContent = $(".btn-submit", $('#addExistingContentModal'))
    @enterOnSearchStreamName()
    @clickOnRemoveSearchStream()    
    @clickOnSubmitExistingContent()

  setup: (options)->
    @extensionSection = $(".main .extensions")
    @extensionModalPopup = $("#exetension-modal-popup", @extensionSection)
    @suggestionModalPopup = $("#suggestion-modal-popup", @extensionSection)
    @addExtensionSection = $("#add_extension", @extensionSection)
    @addExtensionSectionToOtherRoles = $(".add_existing_content_section", @extensionSection)
    @editExtensionSection = $("#edit_extension", @extensionSection)
    @btnSubmit = $(".btn-submit", @addExtensionSection)
    @mediaUrl = $("#media_url", @addExtensionSection)
    @backupMediaUrl = $("#backup_media_url", @addExtensionSection)
    @linkSubmit = $(".link-submit", @addExtensionSection)
    @existedExtension = $(".existed-extension", @addExtensionSection)
    @searchButton = $(".btn-search", @addExtensionSection)
    @btnCancel = $(".btn-cancel", @addExtensionSection)
    @btnCancelOnEditExtension = $(".btn-cancel", @editExtensionSection)
    @btnCancelOnAddExtensionToOtherRoles = $(".btn-cancel", @addExtensionSectionToOtherRoles)
    @newExtension = $(".new-extension", @addExtensionSection)
    @loadingSection = $(".loading", @addExtensionSection)
    @extensions = options["extensions"]
    @us_contents = options["us_contents"]
    @default_country_id = options["default_country_id"]
    @currentState = null
    @regUrlFormat = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;:&=\+\$,\w]+@)?[A-Za-z0-9.-]+|(?:www.|[-;:&=\+\$,\w]+@)[A-Za-z0-9.-]+)((?:\/[\+~%\/.\w-_]*)?\??(?:[-\+=&;%@.\w_]*)#?(?:[\w]*))?)/
    
    @editExtensionLink = $(".link-edit-extension", @extensionSection)
    @btnSubmitOnEditExtension = $(".btn-submit", @editExtensionSection)
    @btnSubmitOnSuggestionForm = $(".btn-submit", @suggestionModalPopup)
    @linkSubmitOnEditExtension = $(".link-submit", @editExtensionSection)
    @btnSubmitOnAddExtensionToOtherRoles = $(".btn-submit", @addExtensionSectionToOtherRoles)
    @initAutoComplete()
    @clickOnAddExtension()
    @clickOnSearchButton()
    @clickOnCancelButton()
    @changeOnTextField()
    @clickOnSubmit()
    @validateTextLength()
    @clickOnSubmitToAddExtenstionToOtherRoles()
    @linkSuggestionContent = $(".suggest-a-new-content", @extensionSection)
    @clickOnSuggestContent()
    @clickOnSubmitOnSuggestionForm()
    @clickOnCancelButtonOnSuggestionForm()
    @clickOnCancelButtonOnAddExtensionToOtherRoles()
    @selectCountry = $(".select-country", @extensionSection)
    @changeCountry($("#data_gateway_data_gateway_conferences_attributes_2_content_id", @editExtensionSection), @editExtensionSection)
    @changeCountry($(".select-content", @addExtensionSectionToOtherRoles), @addExtensionSectionToOtherRoles)
    @resetObjects()
    @rejectUnvalidValueToSelect()
    

  rejectUnvalidValueToSelect: =>
    $("#data_gateway_data_gateway_conferences_attributes_2_content_id", @editExtensionSection).change (e) =>
      if $(e.target).val() is "-1"
        $(e.target).val(@currentContentToEditExtension["content_id"])

  resetObjects: =>
    # For edit
    $("#data_gateway_data_gateway_conferences_attributes_2_content_id", @editExtensionSection).val("")
    $("#data_gateway_data_gateway_conferences_attributes_2_id", @editExtensionSection).val("")
    $("#data_gateway_data_gateway_conferences_attributes_2_extension", @editExtensionSection).val("")

  changeCountry: (selectObject, parent)=>
    $(".select-country", parent).change (e) =>
      console.log("vao chane")
      $(".loading", parent).show()
      $.get "extensions/get_contents",
        query: $(e.target).val(),
        station_id: $(e.target).parents('#edit_extension').find('#station_id').prop('value')
      , (data) =>
        options = []
        for d, v of data
          options.push("<option value = '#{v[1]}'>#{v[0]}</option>")
        selectObject.html(options.join(" "))

        if parent.attr("id") is "edit_extension"
          list = $("#data_gateway_data_gateway_conferences_attributes_2_content_id option", parent)
          list.first().before("<option value='#{@currentContentToEditExtension['content_id']}'>#{@currentContentToEditExtension['title']}</option><option value='-1'>--------------------</option>")
          $("#data_gateway_data_gateway_conferences_attributes_2_content_id", @editExtensionSection).val(@currentContentToEditExtension["content_id"])
        $(".loading", parent).hide()

  clickOnSuggestContent: => 
    @linkSuggestionContent.click (e) =>
      @resetSuggestionForm()
      @suggestionModalPopup.modal "show"
  
  clickOnCancelButtonOnSuggestionForm: =>
    $(".btn-cancel", @suggestionModalPopup).click (e) =>
      @resetSuggestionForm()
  
  clickOnCancelButtonOnAddExtensionToOtherRoles: =>
    $(".btn-cancel", @addExtensionSectionToOtherRoles).click (e) =>
      @resetAddExtensionFormToOtherRoles()

  resetAddExtensionFormToOtherRoles: =>
    $(".select-country").val(@default_country_id)
    options = []
    for d, v of @us_contents
      options.push("<option value = '#{v[1]}'>#{v[0]}</option>")
    $(".select-content", @addExtensionSectionToOtherRoles).html(options.join(" "))
    $(".extension", @addExtensionSectionToOtherRoles).val("")

  resetSuggestionForm: =>
    $("#suggestion_stream_name", @suggestionModalPopup).val("")
    $("#suggestion_stream_url", @suggestionModalPopup).val("")
    $("#suggestion_comment", @suggestionModalPopup).val("")

  clickOnSubmitOnSuggestionForm: =>
    @btnSubmitOnSuggestionForm.click (e) =>
      console.log("submit")
      form = $("form.suggestion-form", @suggestionModalPopup)
      if @validateSuggestionForm()
        form.submit()
      else
        false
  validateUrlFormat: (url) =>
    if $.trim(url.val()) != ""
      if @regUrlFormat.test(url.val())
        true
      else
        currentErrorObject = $("." + url.data("error-class"), @suggestionModalPopup)
        currentErrorObject.html("")
        currentErrorObject.html("URL is invalid!")
        currentErrorObject.show()
        setTimeout("$('.error-in-add').fadeOut()", 1500)
        false
    else
      false

  validateSuggestionForm: =>
    stream_name = @validateText($("#suggestion_stream_name", @suggestionModalPopup), @suggestionModalPopup)
    stream_url = @validateText($("#suggestion_stream_url", @suggestionModalPopup), @suggestionModalPopup)
    url_format = @validateUrlFormat($("#suggestion_stream_url", @suggestionModalPopup))
    stream_name && stream_url && url_format
  
  
  clickOnSubmitToAddExtenstionToOtherRoles: =>
    @btnSubmitOnAddExtensionToOtherRoles.click (e) =>
      form = $("form.edit_data_gateway", @extensionSection)
      if @validateText($(".extension", @addExtensionSectionToOtherRoles), @addExtensionSectionToOtherRoles)
        form.submit()
      else
        false

  validateEditExtensionForm: =>
    @validateTexts()
  
  validateTexts: =>
    @validateText($("#data_gateway_data_gateway_conferences_attributes_2_extension", @editExtensionSection), @editExtensionSection)

  clickOnSubmit: =>
    @btnSubmit.click (e) =>
      form = $("form.edit_data_gateway", @extensionSection)
      if @currentState == "edit"
        form.submit()
      else if @currentState == "new"
        stream_valid = @validateText($("#data_gateway_data_gateway_conferences_attributes_1_data_content_attributes_title", @newExtension), @addExtensionSection)
        channel_valid = @validateText($("#data_gateway_data_gateway_conferences_attributes_1_extension", @newExtension), @addExtensionSection)
        backup_stream = $("#data_gateway_data_gateway_conferences_attributes_1_data_content_attributes_backup_media_url").val()
        backup_stream_valid = true
        if backup_stream.length > 0 && !@regUrlFormat.test(backup_stream)
          backup_stream_valid = false
          $(".backup-stream-error", @addExtensionSection).html("URL is invalid!")
          $(".backup-stream-error", @addExtensionSection).show()
          setTimeout("$('.backup-stream-error').fadeOut()", 1500)
        if stream_valid && channel_valid && backup_stream_valid
          form.submit()
      else
        false
  
  validateTextLength: (length = 30) =>
    $("input.text-length").keypress((evt) =>
      theEvent = evt or window.event
      if $(evt.target).val().length > length
        theEvent.returnValue = false
        theEvent.preventDefault()  if theEvent.preventDefault
    )
  
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


  changeOnTextField: =>
    $(".text-change", @addExtensionSection).keyup (e) =>
      target = $(e.target)
      if target.data("old-value") is $.trim(target.val()) || $.trim(target.val()) is ""
        @btnSubmit.hide()
        @linkSubmit.show()
      else
        @linkSubmit.hide()
        @btnSubmit.show()
  
  changeOnTextFieldOnEditExtension: =>
    $(".text-change", @editExtensionSection).keyup (e) =>
      target = $(e.target)
      console.log(target.data("old-value"))
      if target.data("old-value") is $.trim(target.val()) || $.trim(target.val()) is ""
        @btnSubmitOnEditExtension.hide()
        @linkSubmitOnEditExtension.show()
      else
        @linkSubmitOnEditExtension.hide()
        @btnSubmitOnEditExtension.show()

  clickOnAddExtension: =>
    $(".btn-add-extension", @extensionSection).click (e) =>
      @mediaUrl.val ""
      @addExtensionSection.show()
      @addExtensionSectionToOtherRoles.hide()
      @editExtensionSection.hide()
      @extensionModalPopup.modal "show"
  
  initAutoComplete: () =>
    $(".typeahead", @addExtensionSection).typeahead source: (query, process) ->      
      $.get "extensions/search_stream",
        query: query
      , (data) ->
        process data
  
  clickOnCancelButton: =>
    @btnCancel.click (e) =>
      @mediaUrl.val("")
      $("#data_gateway_data_gateway_conferences_attributes_0_extension", @existedExtension).val($("#data_gateway_data_gateway_conferences_attributes_0_extension", @existedExtension).data("old-value"))
      $("#data_gateway_data_gateway_conferences_attributes_1_data_content_attributes_media_url", @newExtension).val("")
      $("#data_gateway_data_gateway_conferences_attributes_1_data_content_attributes_title", @newExtension).val("")
      $("#data_gateway_data_gateway_conferences_attributes_1_extension", @newExtension).val("")
      @existedExtension.hide()
      @newExtension.hide()
      @searchButton.show()
  
  clickOnSearchButton: =>
    @searchButton.click (e) =>     
      target = $(e.target)
#      target.hide()
      @loadingSection.show()
      $('.stream-error').html("")
      $('.stream-error').show()
      if $.trim(@mediaUrl.val()) is ""
        $(".stream-error", @addExtensionSection).html("URL can't be blank!")
        $(".stream-error", @addExtensionSection).show()
        target.show()
        setTimeout("$('.stream-error').fadeOut()", 1500)
      else
        $(".stream-error", @addExtensionSection).html("")
        streamSearch = @mediaUrl.val()
        $.getJSON "extensions/search_stream?getid=1&query=" + streamSearch, (data) =>
          if data.length > 0
            result = $.grep(@extensions, (e) =>
              e["stream"] is @mediaUrl.val()
            )
            if !result.length > 0
              result[0] = new Array()
              result[0]['extension'] = ''
              result[0]['content_id'] = data[0].id
              result[0]['extension_id'] = ''
            if result[0]              
              $("#data_gateway_data_gateway_conferences_attributes_0_extension", @existedExtension).val(result[0]["extension"])
              $("#data_gateway_data_gateway_conferences_attributes_0_content_id", @existedExtension).val(result[0]["content_id"])
              $("#data_gateway_data_gateway_conferences_attributes_0_extension", @existedExtension).attr("data-old-value", result[0]["extension"])
              $("#data_gateway_data_gateway_conferences_attributes_0_id", @existedExtension).val(result[0]["extension_id"])
              @existedExtension.show()
              @newExtension.hide()
              @currentState = "edit"
          else if @regUrlFormat.test(streamSearch)                    
            $("#data_gateway_data_gateway_conferences_attributes_1_data_content_attributes_media_url", @newExtension).val(@mediaUrl.val())
            $("#data_gateway_data_gateway_conferences_attributes_1_data_content_attributes_title", @newExtension).val("")
            $("#data_gateway_data_gateway_conferences_attributes_1_extension", @newExtension).val("")
            @existedExtension.hide()
            @newExtension.show()
            @currentState = "new" 
          else
            $(".stream-error", @addExtensionSection).html("URL is invalid!")
            $(".stream-error", @addExtensionSection).show()
            setTimeout("$('.stream-error').fadeOut()", 1500)
            target.show()
      @loadingSection.hide()

  enterOnSearchStreamName: () =>    
    $(".search_stream_field", @addExtensionSection).typeeahead 
      name: 'search_stream', 
      remote: url: "/extensions/gateway_contents/new.json?station_id=" + $('#data_gateway_conference_gateway_id').prop('value') + '&search_stream=%QUERY'
      limit: 8
    .on 'typeeahead:selected', (object, datum) ->
      $('#existing_content_country_id').prop('disabled', true)
      $('#data_gateway_conference_content_id').prop('disabled', true)
      $('#new_data_gateway_conference div.country-title').hide()
      $('#new_data_gateway_conference div.stream-title').hide()
      $('#existing_content_content_id').prop('disabled', false)
      $('#existing_content_content_id').val(datum.id)
      $('#existing_content_remove_search').show()
      
  clickOnRemoveSearchStream: () =>
    $('#existing_content_remove_search').click ->
      $('#existing_content_remove_search').hide()
      $('#existing_content_content_id').val('')
      $('#search_stream').val('')
      $('#existing_content_content_id').attr('disabled', 'disabled')
      $('#existing_content_country_id').prop('disabled', false) 
      $('#data_gateway_conference_content_id').prop('disabled', false)
      $('#new_data_gateway_conference div.country-title').show()
      $('#new_data_gateway_conference div.stream-title').show()
   
  clickOnSubmitExistingContent: () =>  
    @btnSubmitExistingContent.click (e) =>
      form = $("form.simple_form new_data_gateway_conference", @addExtensionSection)
      if @validateAddExistingContentForm()
        form.submit()
      else
        false

  validateAddExistingContentForm: =>
    n1 = $("#data_gateway_conference_content_id").val()
    n2 = $("#existing_content_content_id").val()   
    channel_number = @validateText($("#data_gateway_conference_extension", @addExtensionSection), @addExtensionSection)
    content_id_valid = @validateContentId(n1, n2)
    channel_number && content_id_valid

    
  isPositiveNumber: (n) => 
    !isNaN(parseFloat(n)) && isFinite(n) && n > 0
 
  validateContentId: (n1, n2) =>
    n1_valid = @isPositiveNumber(n1)
    n2_valid = @isPositiveNumber(n2)
    if !n1_valid && !n2_valid
      currentErrorObject = $("." + $("#data_gateway_conference_extension", @addExtensionSection).data("error-class"), @addExtensionSection)
      currentErrorObject.html($("#data_gateway_conference_content_id", @addExtensionSection).data("text-error") + " can't be blank")
      currentErrorObject.show()
      setTimeout("$('.error-in-add').fadeOut()", 1500)
      return false
    true
    
  clickOnSwitchButton: =>
    switch_streams = $('#switch_streams')
    switch_streams.click (e) =>    
      console.log('clicked')
      stream_url = $("#data_gateway_conference_data_content_attributes_media_url")
      backup_stream = $("#data_gateway_conference_data_content_attributes_backup_media_url")
      stream_val = stream_url.val()
      stream_url.val(backup_stream.val())
      backup_stream.val(stream_val)
      false