class window.MappingRules
  constructor: (options)->
    @setup()
  setup: ->
    $(document).on('click','.create_rule',( (e) ->
       $("#showContentModal").modal("show");))
    $(document).on('click','.cancel_modal',( (e) ->
       $("#showContentModal").modal("hide");))