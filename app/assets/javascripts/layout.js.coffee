window.layout =
  setup: ->
    @activeMenu()
    @activeTabMarketer()
    @activeTabExtentions()
    @activeTabSettingsPage()
    $('a[data-toggle="tooltip"]').tooltip()
    $(".main-loading").hide()
    $(".main").removeClass("hide")
    setTimeout('$(".main .fade").fadeOut()', 2000)
    @loadStationsByCountry()
    @loadDidsByStation()
    @filterByDid()
    @filterByDay()
    $('.navbar-form a').tooltip()
    @validateNumberKeypress()
    return

  validateNumberKeypress: ->
    $("input[type=number]").keypress((evt)=>
      theEvent = evt or window.event
      key = theEvent.keyCode or theEvent.which
      key = String.fromCharCode(key)
      regex = /[0-9]|\./
      unless regex.test(key)
        theEvent.returnValue = false
        theEvent.preventDefault()  if theEvent.preventDefault
    )
  activeMenu: ->
    $(".menu ul li a").click ->
      # close all tab
      $(".active").removeClass "active"

      # active current tab
      $(this).addClass "active"
      return


  activeTabMarketer: ->
    $(".marketer .nav.nav-tabs li").on "click", () ->

      #close current active tab
      $(".active").removeClass "active"

      #active current tab
      $(this).addClass "active"

      # Call ajax to load data for content tab
      if $(this).hasClass("aggregate")
        loadContentTab("charts/aggregate?day_id=7", "#content-charts", {})
      else if $(this).hasClass("default")
        loadContentTab("charts/countries?day_id=7", "#content-charts",{kind: 2})
      else if $(this).hasClass("custom")
        loadContentTab("/load_custom?day_id=7", "#content-charts", {kind: 3})
      return

  activeTabSettingsPage: ->
    $(".settings_page").find(".setting-nav-tabs").find('li').off "click"
    $(".settings_page").find(".setting-nav-tabs").find('li').on "click", (e) ->
      e.preventDefault();
      $(this).parents(".nav:first").find('li').filter(".active-tab").removeClass "active-tab"
      $(this).addClass "active-tab"

  activeTabExtentions: ->
    $(".data-tagging .collapsible-content-menu").off "click"
    $(".data-tagging .collapsible-content-menu").on "click", (e) ->

      e.preventDefault();

      #close current active tab
      $(".collapsible-content-menu").filter(".active-tab").removeClass "active-tab"

      #active current tab
      $(this).addClass "active-tab"


      #unhide current tab
      $(".collapsible-content-menu").filter(".active-tab").parents(".collapsible-content").find('.tabs-content').show()


      #set icon for current tab
      $(".collapsible-content-menu").filter(".active-tab").find('a').removeClass "icon-chevron-right"
      $(".collapsible-content-menu").filter(".active-tab").find('a').addClass "icon-chevron-down"



      #hide others tab
      $(".collapsible-content-menu").filter(":not(.active-tab)").parents(".collapsible-content").find('.tabs-content').hide()

      #set icon for others tab
      $(".collapsible-content-menu").filter(":not(.active-tab)").find('a').removeClass "icon-chevron-down"
      $(".collapsible-content-menu").filter(":not(.active-tab)").find('a').addClass "icon-chevron-right"


      # Call ajax to load data for content tab
      if $(this).hasClass("tagging")
        loadContentTab("/users_and_tags/tagging", ".data-tags-tabs", {})
      else if $(this).hasClass("content")
        loadContentTab("/extensions/content", ".content-tabs", {"station_id" : $(e.target).data("station-id"), "country_id" : $(e.target).data("country-id"), "query" : $(e.target).data("query"), "rca_id" : $(e.target).data("rca-id"), "slider_search_enabled" : $(e.target).data("slider-search-enabled")})
      else
        loadContentTab("/users_and_tags/data_group", ".data-groups-tabs", {})
      return


  loadStationsByCountry: ->
    $(".marketer").delegate ".chart-filter #country", "change", ->
      day_id = $(".marketer .chart-filter #day").val()
      data = {
              country_id: $(this).val(),
              day_id: day_id, kind: 3
            }
      loadContentTab("/load_data_for_select", "#filter-select", data)
      $(".apply.add").removeClass("hide")
      $(".apply.remove").addClass("hide")
  loadDidsByStation: ->
    $(".marketer").delegate ".chart-filter #station", "change", ->
      country_id = $(".marketer .chart-filter #country").val()
      station_id = $(this).val()
      day_id = $(".marketer .chart-filter #day").val()
      data = {
              country_id: country_id,
              station_id: station_id,
              day_id: day_id ,
              kind: 3
            }
      loadContentTab("/load_data_for_select", "#filter-select", data)
  filterByDid: ->
    $(".marketer").delegate ".chart-filter #did", "change", ->
      country_id = $(".marketer .chart-filter #country").val()
      station_id = $(".marketer .chart-filter #station").val()
      did_id = $(this).val()
      day_id = $(".marketer .chart-filter #day").val()
      data = {
              country_id: country_id,
              station_id: station_id,
              did_id: did_id,
              day_id: day_id,
              kind: 3
            }
      #loadContentTab("charts/countries", "#content-charts", data)
  filterByDay: ->
    $(".marketer").delegate ".chart-filter #day", "change", ->
      country_id = $(".marketer .chart-filter #country").val()
      station_id = $(".marketer .chart-filter #station").val()
      did_id = $(".marketer .chart-filter #did").val()
      day_id = $(this).val()

      
      $tab = $(".marketer .nav.nav-tabs .active")
      if  $tab.hasClass("aggregate")
        kind = null
        url = "charts/aggregate"
      else if $tab.hasClass("default")
        url = "charts/countries"
        kind = 2
      else if $tab.hasClass("custom")
        url = "/load_custom"
        kind = 3

      data = {
              country_id: country_id,
              station_id: station_id,
              did_id: did_id,
              day_id: day_id,
              kind: kind,
              page: $(this).data("current-page")
            }

      loadContentTab(url, "#content-charts", data)

window.loadContentTab= (url, render_to_here, data) ->
  $('#loading-image').removeClass("hide")
  $.ajax
    url: url
    type: "GET"
    data: data
    beforeSend: ->
      $(".main-loading").show();
    success: (res) ->
      $(".main-loading").hide();
      $(render_to_here).html(res)
      $('#loading-image').addClass("hide")
      if data["kind"] == 3
        $(".btn-custom").removeClass("btn-primary").addClass("btn-info")
      else if data["kind"] == 2
        $(".btn-default").removeClass("btn-primary").addClass("btn-info")
      return
    error: (xhr, textStatusx, error) ->
      return

window.loadChildrenChart= (url, render_to_here, data, click_on) ->
  $('#loading-image').removeClass("hide")
  $.ajax
    url: url
    type: "GET"
    data: data
    success: (res) ->
      $(render_to_here).append(res)
      $('#loading-image').addClass("hide")
      checks =$("input:checkbox:checked")
      level_id_on_click = $(click_on).data("level-id")
      checks.each ->
        if $(this).val() == level_id_on_click
          cks = $("."+level_id_on_click).find("input[type=checkbox]")
          cks.each ->
            $(this).attr("checked", true)
      return
    error: (xhr, textStatusx, error) ->
      return
