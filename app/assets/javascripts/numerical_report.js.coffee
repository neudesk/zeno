class window.NumericalReport
  constructor: ->
    @setup()

  setup: ->
    @numericalReport = $(".main .numerical_reports")
    @anisDayNotActionReport = @numericalReport.find(".anis_days_not_active")
    @changeOnCategoryNameOfAnisReport()

  changeOnCategoryNameOfAnisReport: ->
    @anisDayNotActionReport.find("select#category_type").change((e) =>
      @anisDayNotActionReport.find(".category-value").css("display", "none");
      @anisDayNotActionReport.find(".select-" + $(e.target).find("option:selected").html().toLowerCase()).toggle()
    )
