$ ->
  class window.Home
    constructor: ->
      @setup()
      show_map()
    setup: ->
      $('#select_type').on "change", (e) ->
        e.preventDefault()
        $('#type').val($(e.target).val())
        get_summary_list()
        get_station_percentage()

      $('#reloadMap').on "click", (e) ->
        $('#preloadOverlay').removeClass('hide')
        show_map()
        get_station_percentage()
      setInterval( ->
        show_map()
        get_station_percentage()
      , 720000)
      setInterval( ->
        get_summary_list()
        true
      , 120000)

      openNewTab()

    openNewTab = () ->
      $('body').on 'click', '.stationRow',() ->
        dataHref = $(this).attr('data-href')
        window.open(dataHref, '_newtab')

    get_station_percentage = () ->
      $.ajax
        url: '/station_percentage'
        type: 'GET'
        success: (data) ->
          $('#usagePercentage').text(data.total_users)
          $('.chart').eq(0).find('label').text(data.num_phone_users)
          $('.chart').eq(0).data('easyPieChart').update(data.phone_percent)
          $('.chart').eq(1).find('label').text(data.num_widget_users)
          $('.chart').eq(1).data('easyPieChart').update(data.app_percent)
          $('.chart').eq(2).find('label').text(data.num_app_users)
          $('.chart').eq(2).data('easyPieChart').update(data.widget_percent)
          return

    get_summary_list = () ->
      $(".summary_list .icon-refresh").addClass("icon-refresh-animate");
      params = {'type':$('#select_type').val(),'page':GetURLParameter('page') }
      $.ajax 
          url: '/home/get_stations'
          type: 'GET'
          data: params
          success: (data) ->      
            $('.summary_list_body').html(data)
            $(".summary_list .icon-refresh").addClass("icon-refresh-animate");
          true
      true
    show_map = () ->
      $.ajax({
       url: '/maps/render_map'
       type: 'GET'
       dataType: 'json'
       success: (res) ->
         if res != null
            $('.all_listeners').text(res['all_listeners'])
            $('.phone_listeners').text(res['phone_listeners'])
            $('.widget_listeners').text(res['widget_listeners'])
            if res["results"].length > 0
             markers = []
             for r in res["results"]
                markers.push({lat:r["lat"], lng:r["long"]})
             handler = Gmaps.build("Google")
             handler.buildMap
               internal:
                 id: "map"
             , ->
               markers = handler.addMarkers(markers)
               handler.bounds.extendWith markers
               handler.getMap().setZoom 2
               
            if $("#map").length > 0
              val = $("#map").parent().css("width").replace("px", '')
              val = parseInt(val) - 30
              val = val.toString() + "px"
              $("#map").css("width", val)
            $('#preloadOverlay').addClass('hide')
       error: (res) ->
         show_map()
         return
       complete: (res) ->
       })
    GetURLParameter = (sParam) ->
      sPageURL = window.location.search.substring(1)
      sURLVariables = sPageURL.split("&")
      i = 0

      while i < sURLVariables.length
        sParameterName = sURLVariables[i].split("=")
        return sParameterName[1]  if sParameterName[0] is sParam
        i++
      return

     


        
        
