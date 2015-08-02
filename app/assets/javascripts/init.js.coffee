$ ->
  $(".customized-alert").hide();
  $(".customized-alert").removeClass('hide');

  layout.setup()
  window.charts = new Charts
  window.data_and_taggings = new DataAndTaggings
  account = new Account
  $('form').inputHintOverlay()

  $("body").bind("ajax:beforeSend", (evt, xhr, settings) =>
    $(".main-loading").show()
  )

  $("body").bind("ajax:success", () =>
    $(".main-loading").hide()
  )



