class window.ReachoutTab
  constructor: (options)->
    loop_ = ""
    @setup(options)
    @get_campaigns("param", "id", "gateway_id")

  raiseSystemAlert = (message) ->
    modal = $('#systemAlertModal')
    modal.find('.modal-body').html(message)
    modal.modal('show')

  get_campaigns: (param, id, gateway_id) ->
    if param == true && id != "" && gateway_id != ""
      $('#loading').show()
      loop_ = setInterval ( ->
        $.ajax({
          url: "/reachout_tab/get_created_campaign_status?main_id=" + id
          type: 'GET'
          success: (res) ->
            if res == true
              clearTimeout(loop_)
              get_all_campaigns(id, gateway_id)
              return
          error: (res) ->
            return
          complete: (res) ->
        })
        ),1500

  get_all_campaigns = (id, gateway_id) ->
    $.ajax({
        url: "/campaign_results/get_campaigns_by_main_id?id=" + id + "&gateway_id=" + gateway_id
        type: 'GET'
        success: (res) ->
          $('#campaign_settings').html(res)
          $('#save_campaign').hide()
          $('#loading').hide()
          $('.back-step').hide()
          $('#step-4 .btn-success').removeClass('disabled')
          $('.campaign_table select').each ->
            $(this).select2()
        error: (res) ->
          return
        complete: (res) ->
        }) 
  truncate = (n, len) ->
    ext = n.substring(n.lastIndexOf(".") + 1, n.length).toLowerCase()
    filename = n.replace("." + ext, "")
    return n  if filename.length <= len
    filename = filename.substr(0, len) + ((if n.length > len then "[...]" else ""))
    filename + "." + ext

  $(document).on "click","#finish_campaign", (event) ->
    if $('#submit_type').val() != "save"
      $('#submit_type').val('finish')
      $('#save_campaigns_form').submit()
    else
      window.location = "/reachout_tab"

  setup: (options)->

    $(document).on 'change', 'input[name="schedule_hour"], input[name="schedule_date"]', () ->
      start = $('input[name="start"]').val()
      stop = $('input[name="stop"]').val()
      console.log "start: #{start}, stop: #{stop}"
      now = $('input[value="send_now"]')
      later = $('input[value="send_later"]')
      hours = null
      if now.is(':checked')
        hours = $('input[name="schedule_hour"]').val().replace(':', '')
      if later.is(':checked')
        hours = $('input[name="schedule_date"]').val().split(' ')[1].replace(':', '')
      if parseInt(hours) < parseInt(start) || parseInt(hours) > parseInt(stop)
        $('button.btnFinish').prop('disabled', true)
        alert "Call time should be in range between #{start} to #{stop} hours."
      else
        $('button.btnFinish').prop('disabled', false)

    start_call_time = (parseInt($('#start_call_time').val())/100).toString() + ':00'
    stop_call_time = (parseInt($('#stop_call_time').val())/100).toString() + ':00'
    d = new Date()
    month = d.getMonth() + 1
    day = d.getDate() + 1
    year = d.getFullYear()
    d.setMinutes(d.getMinutes() + 5)
    if parseInt(d.getHours()) < 9
      min_time = '9:00';
    else
      if parseInt(d.getMinutes()) < 10
        min_time = d.getHours() + ":" + "0" + d.getMinutes()
      else
        min_time = d.getHours() + ":" + d.getMinutes()
    timeout = null
    $search = ""
    $country_id = ""
    $rca_id = ""
    timeout = null
    slide = $('.slider_content')

    ajaxAnim = (x) ->
      $('#inside_slider').removeClass().addClass(x + ' animated').one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', ->
        $(this).removeClass()
        return
      return

    ajaxSlide = (page) ->
      $.ajax(
          url: "/application/slider_content/" + page
          data:
            search: $search
            country_id: $country_id
            rca_id: $rca_id
            controller_name: "reachout_tab"
          success: (data) ->
            $('#next-slide').show()
            $('#prev-slide').show()
      ).done (data) ->
        $("#inside_slider").html(data);
        $("#total_page").text($("#pages").val())
        if parseInt($('#total_page').text()) == 1
          $('#next-slide').hide()
          $('#prev-slide').hide()
        return
      if parseInt($('#page').val()) >= parseInt($('#total_page').text())
        $('#next-slide').hide()
      if parseInt($('#page').val()) == 0 or parseInt($('#page').val()) < 0
        $('#prev-slide').hide()
        $('#page').val(1)
      return

    $('#pullStationBtn').click ->
      if slide.is(':visible')
        slide.slideUp(300)
      else
        slide.slideDown(300)
      return

    $("#prompt").fileinput({showUpload: false})

    $('form[action="/reachout_tab/save"]').on 'submit', (event) ->
      num = $('span[class="label label-info phone_number"]')
      if num.length > 0
        data = []
        $.each num, (idx, value) ->
          data.push($(value).find('a').attr('data-val'))
        $('input[name="uploaded_phone_list"]').val(data.join())

    $('#upload_phone_form').unbind().on 'submit', (event) ->
      if $('#upload_datafile').val() != ''
        width = 0;
        runCode = () ->
          width += 0.7
          $('#bar').css('width', width+'%')
        setInterval(runCode, 100)

    $("#next-slide").click ->
      if parseInt($('#page').val()) >= parseInt($('#total_page').text())
        $(this).hide()
      else
        ajaxAnim('bounceInRight')
        $page = parseInt($('#page').val())
        $('#page').val($page+1)
        ajaxSlide($page+1, $country_id)
        $("#prev-slide").show()

    $("#prev-slide").click ->
      if parseInt($('#page').val()) == 0
        $(this).hide()
        $('#page').val(1)
      else
        ajaxAnim('bounceInLeft')
        $page = parseInt($('#page').val())
        $('#page').val($page-1)
        ajaxSlide($page-1)
        $("#next-slide").show()

    $('#page').keyup ->
      $page = parseInt($('#page').val())
      if $.isNumeric($page)
        if $page > parseInt($('#total_page').text())
          $('#page').val(parseInt($('#total_page').text()))
      return

    $('#page').keypress (e) ->
      $page = parseInt($('#page').val())
      if e.which == 13
        if $.isNumeric($page)
          ajaxSlide($page)
        else
          alert 'Please enter a valid page.'
      return

    $('.query-search-country-id').change ->
      ajaxAnim('fadeIn')
      $country_id = $(this).val()
      $('.slider_content').removeClass('hide');
      slide.slideDown(300)
      ajaxSlide(1)
      return

    $('.query-search-rca-id').change ->
      ajaxAnim('fadeIn')
      $rca_id = $(this).val()
      ajaxSlide(1)
      $('.slider_content').removeClass('hide');
      slide.slideDown(300)
      return

    $('#searchStation').click ->
      ajaxAnim('fadeIn')
      $search = $('#query').val()
      $('#page').val(1)
      $('.slider_content').removeClass('hide');
      slide.slideDown(300)
      ajaxSlide(1)
      return

    runCode2 = () ->
      ajaxAnim('fadeIn')
      $('#page').val(1)
      ajaxSlide(1)
      return
    timeout = setTimeout(runCode2, 1000)

    
    $("#query").keyup (e) ->
      slide.slideDown(300)
      $(".slider_content").removeClass "hide"
      $(".slider-loading").show()
      $search = $("#query").val()
      clearTimeout timeout  if timeout
      timeout = setTimeout(->
        ajaxAnim "fadeIn"
        $("#page").val 1
        ajaxSlide 1
        $(".slider_content").removeClass "hide"
        return
      , 1000)
      return

    $("#hourpicker").datetimepicker
      format:'H:i',
      datepicker:false,
      value: min_time
      step: 10
      minTime: d.getHours() + ":" + d.getMinutes()
      maxTime: stop_call_time

    $("#datepicker").datetimepicker
      format:'Y-m-d H:i',
      minDate: year + "/" + month + "/" + day 
      value: year + "-" + month + "-" + day + " " + start_call_time
      step: 10
      minTime: start_call_time,
      maxTime: stop_call_time

    $("#country_id, #rca_id").select2()
    $("#prompt").fileinput showUpload: false
    
    $('#start_time').val(year + "-" + month + "-" + (day - 1) + " " + min_time)
    $('#end_time').val(year + "-" + month + "-" + (day - 1) + " " + stop_call_time)

    $('#datepicker').change ->
      $('#start_time').val($('#datepicker').val())
      $('#end_time').val($('#datepicker').val().split(' ')[0] + " " + stop_call_time)

    $('#hourpicker').change ->
      $('#start_time').val(year + "-" + month + "-" + (day - 1) + " " + $('#hourpicker').val())
      $('#end_time').val(year + "-" + month + "-" + (day - 1) + " " + stop_call_time)

    #$('#step-3 .radio').click ->
    # if $(this).children().val() == "send_now"
    #    $('#start_time').val(year + "-" + month + "-" + (day - 1) + " " + $('#hourpicker').val())
    #    $('#end_time').val(year + "-" + month + "-" + (day - 1) + " " + stop_call_time)
    #  else
    #    $('#start_time').val($('#datepicker').val())
    #    $('#end_time').val($('#datepicker').val().split(' ')[0] +" "+ stop_call_time)

    $('#save_campaign').click ->
      $('#submit_type').val('save')

    $('.fileinput-remove').on "click", (event) ->
      $('.file_name .file-caption-name').text('')

    $(document).on "change","#prompt", (event) -> 
      console.log truncate($(this).val().split('\\').pop(),40)
      $('#step-4 .file-caption-name').text(truncate($(this).val().split('\\').pop(),40))

    $('#save_campaigns_form').find('input[type="checkbox"].square-red').iCheck(
      checkboxClass: "icheckbox_square-red"
      radioClass: "iradio_square-red"
      increaseArea: "10%"
    ).on "ifClicked", (event) ->
      $(this).iCheck "toggle"
      if $('#step-1 .icheckbox_square-red').hasClass("checked")
        $('#setopt-active-listeners_sum').show()
      else
        $('#setopt-active-listeners_sum').hide()
      return

    $('#save_campaigns_form').find('input[type="checkbox"].square-green').iCheck(
      checkboxClass: "icheckbox_square-green"
      radioClass: "iradio_square-green"
      increaseArea: "10%"
    ).on "ifClicked", (event) ->
      $(this).iCheck "toggle"
      if $('#step-1 .icheckbox_square-green').hasClass("checked")
        $('#setopt-uploaded-list-phone-numbers_sum').show()
      else
        $('#setopt-uploaded-list-phone-numbers_sum').hide()
      return

    $("#stationListToggle").on "click", (event) ->
      event.preventDefault()
      if $(this).find("span").text() is "Hide Station List"
        $(this).find("span").text "Show Station List"
      else
        $(this).find("span").text "Hide Station List"
      $("#stationList").toggle 300
      return

    $("form[action=\"/reachout_tab/save\"]").on "submit", (event) ->
      num = $("span[class=\"label label-info phone_number\"]")
      if num.length > 0
        data = []
        $.each num, (idx, value) ->
          data.push $(value).find("a").attr("data-val")
          return

        $("input[name=\"uploaded_phone_list\"]").val data.join()
      return

    $("#upload_phone_form").unbind().on "submit", (event) ->
      unless $("#upload_datafile").val() is ""
        width = 0
        setInterval (->
          width += 0.7
          $("#bar").css "width", width + "%"
          return
        ), 100
    


    $(document).ajaxStart ( event,request, settings ) ->
      $('.slider-loading').show()
      return
    $(document).ajaxComplete ( event,request, settings ) ->
      $('.slider-loading').hide()
      return

    ajaxSlide(1)

    $('#country_id, #rca_id').select2()
    $("#prompt").fileinput({showUpload: false})
    $('#stationListToggle').on 'click', (event) ->
      event.preventDefault()
      if $(this).find('span').text() == 'Hide Station List'
        $(this).find('span').text('Show Station List')
      else
        $(this).find('span').text('Hide Station List')
      $('#stationList').toggle(300)
      return

    $('.campaign_list').click ->
      if $('.campaign_box').is(':visible')
        $(this).children('i').removeClass('fa-angle-down')
        $(this).children('i').addClass('fa-angle-up')
      else
        $(this).children('i').removeClass('fa-angle-up')
        $(this).children('i').addClass('fa-angle-down')
      $('.campaign_box').toggle()
    true

    $('input[name="schedule"]').click ->
      if $('input[name="schedule"]:checked').val() == "send_later"
        $("#datepicker").show()
        $("#hourpicker").hide()
      else
        $("#datepicker").hide()
        $("#hourpicker").show()

    $('.phone_no_list').click () ->
      if $('.phones').is(':visible')
        $(this).children('i').removeClass('fa-angle-down')
        $(this).children('i').addClass('fa-angle-up')
      else
        $(this).children('i').removeClass('fa-angle-up')
        $(this).children('i').addClass('fa-angle-down')
      $('.phones').toggle()

    $('.send').click (e) ->
      phones = []
      $('.reachout_tab_phone_list li').each () ->
        phones.push($(this).attr('id'))
      $('#uploaded_phone_list').val(phones)
      $('.error').text("")
      if $('#prompt').val() == ""
        $('.error').text('Please select a wav file.')
        return false
      if $('#date').val() == "" && $(".schedule").val() == "send_later"
        $('.error').text('Please select a schedule date.')
        return false
      $('#schedule_type').val($('input[name="schedule"]:checked').val())

#    $("#btn_upload").click () ->
#      $('#bar').attr('style','width:0%');
#      if $('#upload_datafile').val() != ""
#        $('div.uploadPreloader').show()
#        width = 0
#        setInterval( ->
#          width += 0.7
#          $('#bar').css('width', width+'%');
#        , 100);
#      else
#        return false

    $(document).on('click','.reachout_tab_phone_delete',( (e) ->
      url = "/reachout_tab/destroy_phone?ani_e164=" + $(this).data('val') + "&gateway_id=" + $('#gateway_id').val()
      $('.phone_list_loader').show()
      $.ajax({
        url: url
        type: 'DELETE'
        success: (res) ->
          if res["status"] == "200"
            $('#'+res["phone"]).remove()
            $('.no_of_listeners').text("Uploaded List of Phone Numbers " + res["phone_list_length"])
          $('.phone_list_loader').hide()
        error: (res) ->
          return
        complete: (res) ->
          }
      )
    ))

    $('#reachout_tab_phone_txt_phone').bind('keypress', (e) ->
      if(e.keyCode==13)
        $('.error_msg').text('')
        phone = $(this).val()

        if phone != "" && phone.length == 11
          if !($('#'+phone).length)
            $('.phone_list_loader').show()
            url = "/reachout_tab/add_phone?ani_e164=" + phone + "&gateway_id=" + $('#gateway_id').val()
            $.ajax({
              url: url
              type: 'POST'
              success: (res) ->
                if data.error == 0
                  html = ""
                  html += "<li id='"+res["phone"]+"'>"
                  html += "<p class='phone_number'>" + res["phone"] + "</p>"
                  html += "<a class='reachout_tab_phone_delete' data-val='"+res["phone"]+"'>x</a></li>"
                  $('#reachout_tab_phone_txt_phone').val('')
                  $('.reachout_tab_phone_list').append(html)
                  $('.no_of_listeners').text("Uploaded List of Phone Numbers " + res["phone_list_length"])
                  num = $('span[class="label label-info phone_number"]');
                  $('#listenerCount').text(num.length)
                  $('#add_phone').modal('hide');
                  $('.phone_list_loader').hide()
                else
                  raiseSystemAlert(res.message)
              error: (res) ->
                raiseSystemAlert('Unexpected error, Please try again.')
              complete: (res) ->
                }
            )
          else
            $('.error_msg').text('Phone number exists.')
        else
          $('.error_msg').text('Please enter a valid 11 digit phone number.')
        return
    )

    $('#add_phone_no').click () ->
      $('.error_msg').text('')
      phone = $('#reachout_tab_phone_txt_phone').val()

      if phone != "" && phone.length == 11
        if !($('#'+phone).length)
          $('.phone_list_loader').show()
          url = "/reachout_tab/add_phone?ani_e164=" + phone + "&gateway_id=" + $('#gateway_id').val()
          $.ajax({
            url: url
            type: 'POST'
            success: (res) ->
              console.log res
              if res.error == 0
                html = ""
                html += "<li id='"+res["phone"]+"'>"
                html += "<span class='label label-info phone_number'>" + res["phone"]
                html += "<a class='reachout_tab_phone_delete btn btn-xs' data-val='"+res["phone"]+"' style='color: #fff'>"
                html += "<i class='fa fa-trash-o'></i></a></li>"
                html +=  "</span>"
                $('#reachout_tab_phone_txt_phone').val('')
                $('.reachout_tab_phone_list').append(html)
                $('.no_of_listeners').text("Uploaded List of Phone Numbers " + res["phone_list_length"])
                num = $('span[class="label label-info phone_number"]')
                $('#listenerCount').text(num.length)
                $('#add_phone').modal('hide')
                $('.phone_list_loader').hide()
                raiseSystemAlert(res.message)
              else
                raiseSystemAlert(res.message)
            error: (res) ->
              raiseSystemAlert('Unexpected error, Please try again')
            complete: (res) ->
              }
          )
        else
          $('.error_msg').text('Phone number exists.')
      else
        $('.error_msg').text('Please enter a valid 11 digit phone number.')
      return

    $('#reachout_tab_phone_txt_search').bind('keyup', (e) ->
      phone = $('#reachout_tab_phone_txt_search').val()
      url = "/reachout_tab/search_phone?ani_e164=" + phone + "&gateway_id=" + $('#gateway_id').val()
      $('.phone_list_loader').show()
      $.ajax({
        url: url
        type: 'GET'
        success: (res) ->
          if res["status"] == "200"
            html = ""
            i = 0
            console.log res["phones"][1]
            while i < res["phones"].length
              html += "<li id='"+res["phones"][i]+"'>"
              html += "<span class='label label-info phone_number'>" + res["phones"][i]
              html += "<a class='reachout_tab_phone_delete btn btn-xs' data-val='"+res["phones"][i]+"' style='color: #fff'>"
              html += "<i class='fa fa-trash-o'></i></a></li>"
              html +=  "</span>"
              i++
            $('#reachout_tab_phone_txt_phone').val('')
            $('.reachout_tab_phone_list').html(html)
          $('.phone_list_loader').hide()
        error: (res) ->
          return
        complete: (res) ->
          }
      )
    )
    $('#btn_search_no').click () ->
      phone = $('#reachout_tab_phone_txt_search').val()
      $('.phone_list_loader').show()
      url = "/reachout_tab/search_phone?ani_e164=" + phone + "&gateway_id=" + $('#gateway_id').val()
      $.ajax({
        url: url
        type: 'GET'
        success: (res) ->
          if res["status"] == "200"
            html = ""
            i = 0
            while i < res["phones"].length
              html += "<li id='"+res["phones"][i]+"'>"
              html += "<span class='label label-info phone_number'>" + res["phones"][i]
              html += "<a class='reachout_tab_phone_delete btn btn-xs' data-val='"+res["phones"][i]+"' style='color: #fff'>"
              html += "<i class='fa fa-trash-o'></i></a></li>"
              html +=  "</span>"
              i++
            $('#reachout_tab_phone_txt_phone').val('')
            $('.reachout_tab_phone_list').html(html)
          $('.phone_list_loader').hide()
        error: (res) ->
          return
        complete: (res) ->
          }
      )

    has_no_default = parseInt($('#step-1').attr('data-hasnodefault'))
    listener_length = parseInt($('#step-1').attr('data-activelisteners'))
    $('input.opt').on 'ifChanged', (event) ->
      if $('#active_listeners').is(':checked') && $('#uploaded_listeners').is(':checked')
        if has_no_default == 1
          $('.canDisable').attr('disabled': true)
          $('.no_default').removeClass('hide')
        else
          $('.canDisable').attr('disabled': false)
          $('.no_default').addClass('hide')
      if $('#active_listeners').is(':checked') && $('#uploaded_listeners').is(':unchecked')
        if listener_length > 0
          $('.canDisable').attr('disabled': false)
          $('.no_default').addClass('hide')
        else if has_no_default == 1
          $('.canDisable').attr('disabled': true)
          $('.no_default').removeClass('hide')
      if $('#active_listeners').is(':unchecked') && $('#uploaded_listeners').is(':checked')
        if has_no_default == 1
          $('.canDisable').attr('disabled': true)
          $('.no_default').removeClass('hide')
        else
          $('.canDisable').attr('disabled': false)
          $('.no_default').addClass('hide')


    
