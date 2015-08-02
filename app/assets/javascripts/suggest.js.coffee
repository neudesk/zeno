$ ->
  $(document).ready customHooks
  $(document).on "page:load", customHooks

customHooks = ->

  $("#new_extension_button").on "click", (e) ->
    e.preventDefault()
    $("select#select_custom_message").show()
    $("#new_extension.modal").modal
      backdrop: 'static'
    ms = $("#stream_url_div").magicSuggest
      id: "data_content_media_url"
      name: "data_content[media_url]"
      data: "/data_contents/suggestion.json"
      allowFreeEntries: true
      expandOnFocus: false
      hideTrigger: false
      noSuggestionText: "System will create new stream."
      maxSelection: 1
      value: $(this).attr("data-id")
      emptyText: "Select the stream you want to add or create it..."
      inputCfg:
        autocomplete: "off"
    $(ms).on "selectionchange", (e, m) ->
      val = JSON.stringify(@getValue()).replace("[", "").replace("]", "")

      if $.isNumeric(val)
        $("#new_extension_fields").hide()
        $("#url_found").show()
      else
        $("#new_extension_fields").show()
        $("#url_found").hide()

