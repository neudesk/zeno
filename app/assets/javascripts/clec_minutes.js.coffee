class window.ClecMinutes
  t = null
  constructor: (options)->
    @setup(options)


  setup: (options)->
    submitOnChange()

  submitOnChange = () ->
    $('#searchForm input, #searchForm select').on 'change', (e) ->
      $(this).parents('form').submit()