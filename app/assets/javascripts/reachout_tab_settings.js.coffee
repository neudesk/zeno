class window.ReachoutTabSettings
  constructor: (options)->
    @setup(options)

  setup: (options)->
    $(".send_campaign_brd").bootstrapSwitch();
    $(".upload_list_brd").bootstrapSwitch();
    $(".send_campaign_rca").bootstrapSwitch();
    $(".upload_list_rca").bootstrapSwitch();

    $(".send_campaign_brd").on "switchChange.bootstrapSwitch", (event, state) ->
      status = state
      data = $(this).data('val')
      if status == false
        $("#upload_list_brd_" + data).attr('disabled','disabled')
        $(".bootstrap-switch-id-upload_list_brd_" + data).addClass('bootstrap-switch-disabled')
        $(".bootstrap-switch-id-upload_list_brd_" + data).addClass('bootstrap-switch-off')
      else
        $(".bootstrap-switch-id-upload_list_brd_" + data).removeClass('bootstrap-switch-disabled')
        $("#upload_list_brd_" + data).removeAttr('disabled')
      url = "/reachout_tab_settings/activate_broadcaster"
      $.ajax({
        url: url
        data: {'id' : data, 'status': status}
        type: 'PUT'
        success: (res) ->

        error: (res) ->
          return
        complete: (res) ->
      })
  
    $(document).on 'click', 'a.changeSched', (event) ->
      event.preventDefault()
      $(this).next().removeClass('hide').select2()

    $(document).on 'change', '.did_config', () ->
      data = {}
      $('select.did_config').each (idx, conf) ->
        data[$(conf).attr('name')] = $(conf).val()  
      $.ajax
        url: '/reachout_tab_settings/update_default_did'
        type: 'POST'
        data: data
        success: (data) ->
          if data.status == 'ok'
            $.each(data.result, (k, v) ->
              $(".#{v.name}").text(v.value)
              if v.value != $(".#{v.name}").closest('a')
                $(".#{v.name}").parent().removeClass('hide')
            )
            alert("Changes will take effect on #{data.result[2].value}")
          return
          else:
            alert('Unable to save, please contact admin.')
        error: (data) ->
          alert('An error has occured.')

    $(".upload_list_brd").on "switchChange.bootstrapSwitch", (event, state) ->
      status = state
      data = $(this).data('val')
      if !($(this).attr('disabled'))
        url = "/reachout_tab_settings/activate_broadcaster"
        $.ajax({
          url: url
          data: {'id' : data, 'status': status, 'type': 'upload_list' }
          type: 'PUT'
          success: (res) ->

          error: (res) ->
            return
          complete: (res) ->
        })
    $(".send_campaign_rca").on "switchChange.bootstrapSwitch", (event, state) ->
      status = state
      data = $(this).data('val')
      if status == false
        $("#upload_list_rca_" + data).attr('disabled','disabled')
        $(".bootstrap-switch-id-upload_list_rca_" + data).addClass('bootstrap-switch-disabled')
        $(".bootstrap-switch-id-upload_list_rca_" + data).addClass('bootstrap-switch-off')
      else
        $(".bootstrap-switch-id-upload_list_rca_" + data).removeClass('bootstrap-switch-disabled')
        $("#upload_list_rca_" + data).removeAttr('disabled')
      url = "/reachout_tab_settings/activate_rca"
      $.ajax({
        url: url
        data: {'id' : data, 'status': status}
        type: 'PUT'
        success: (res) ->
        error: (res) ->
          return
        complete: (res) ->
      })
    $(".upload_list_rca").on "switchChange.bootstrapSwitch", (event, state) ->
      status = state
      data = $(this).data('val')
      if !($(this).attr('disabled'))
        url = "/reachout_tab_settings/activate_rca"
        $.ajax({
          url: url
          data: {'id' : data, 'status': status, 'type': 'upload_list'}
          type: 'PUT'
          success: (res) ->
          error: (res) ->
            return
          complete: (res) ->
        })

    $(".num_value").change (e)=>
      if $(e.target).parent().attr('class') == "call_time_setting"
        data = {'val1':$('#val1').val(), 'val2': $('#val2').val()}
      else
        data = {'value':$(e.target).val() }
      url = "/reachout_tab_settings/update_setting/" + $(e.target).data('val')
      $.ajax({
        url: url
        data: data
        type: 'PUT'
        success: (res) ->
        error: (res) ->
          return
        complete: (res) ->
      })

    $(".text_value").change (e)=>
      data = $(e.target).val()
      url = "/reachout_tab_settings/update_setting/" + $(e.target).data('val')
      $.ajax({
        url: url
        data: {'value':data}
        type: 'PUT'
        success: (res) ->
        error: (res) ->
          return
        complete: (res) ->
      })

    $("#btn_search").click =>
      data = $('#txt_search').val()
      url = "/reachout_tab_settings/search_phone"
      $.ajax({
        url: url
        data: {'phone_number':data}
        type: 'GET'
        success: (res) ->
          html = ''
          for result in res.dnc_list
            html += '<li id="'+result.id+'"><span class="label label-info phone_number">'+result.phone_number+'<a style="color: #fff" data-val="'+result.id+'" class="reachout_tab_settings_phone_delete btn btn-xs"><i class="fa fa-trash-o"></i></a></span></li>'
          $('.dnc_list').html(html)
        error: (res) ->
          return
        complete: (res) ->
      })
    $("#save_call_time").click =>
      if $('#id').val() == ''
        $('.error').text('ID field is empty.')
        return
      if $('#call_time_name').val() == ''
        $('.error').text('Name field is empty.')
        return
      if $('#ct_default_stop').val() == ''
        $('.error').text('Start Time field is empty.')
        return
      if $('#ct_default_start').val() == ''
        $('.error').text('End Time field is empty.')
        return
      url = "/reachout_tab_settings/add_call_time"
      $.ajax({
        url: url,
        data: $('#call_time_form').serialize(),
        type: 'POST'
        success: (res) ->
          if res == "1"
            $('.error').text('Call time has no saved.')
          else
            window.location.href = '/reachout_tab_settings/index'
        error: (res) ->
          return
        complete: (res) ->
      })
    $("#settings_new").click =>
      $('.settings_form').toggle()

    $(".add_call").click =>
      $('.call_time_form').toggle()

    $("#add_phone").click =>
      data = $('#txt_phone').val()
      url = "/reachout_tab_settings/add_phone_dnc"
      $.ajax({
        url: url
        data: {'phone_number':data}
        type: 'POST'
        success: (result) ->
          html = ''
          if result.message =="Succes"
            html += '<li id="'+result.id+'"><span class="label label-info phone_number">'+data+'<a style="color: #fff" data-val="'+result.id+'" class="reachout_tab_settings_phone_delete btn btn-xs"><i class="fa fa-trash-o"></i></a></span></li>'
            $('.dnc_list').append html
            $('#phoneFormModal').modal "hide"
            $('#txt_phone').val('')
          else
           $('.info').html('<div class="col-md-12"><div class="alert alert-danger"><button class="close" data-dismiss="alert">×</button>'+result.message+'</div></div>')
        error: (res) ->
          return
        complete: (result) ->
      })

    $("#save_settings").click =>
      url = "/reachout_tab_settings/add_setting"
      if $('#name').val() == ""
        $('.info').append('<div class="alert fade in alert-error"><button class="close" data-dismiss="alert">×</button>Please add Setting name.</div>')
      else
        $.ajax({
          url: url
          data: $('#settings_form').serialize()
          type: 'POST'
          success: (res) ->
            window.location.href = "/reachout_tab_settings/index"
          error: (res) ->
            return
          complete: (res) ->
        })


    $(document).on('click', '.change_status_rca', ( (e) ->
      data = $(e.target).data('id')
      status = $(e.target).data('status')
      index = $(e.target).data('index')
      url = "/reachout_tab_settings/activate_rca"
      $.ajax({
        url: url
        data: {'id' : data, 'status': status}
        type: 'PUT'
        success: (res) ->
          if res.rca.reachout_tab_is_active == true
            status = "Active"
            action = "Disable"
            next_status = false
          else
            status = "Inactive"
            action = "Enable"
            next_status = true
          html = '<td>'+index+'</td><td>'+res.rca.title+'</td><td>'+status+'</td><td><a class="change_status_rca"'
          html += 'data-index="'+index+'" data-name="'+res.rca.title+'" data-id="'+data+'" data-status="'+next_status+'">'+action+'</a></td>'
          $(e.target).parent().parent().html(html)
        error: (res) ->
          return
        complete: (res) ->
      })
    ))


    $('#search_rca').click ->
      $('#txt_rca_search').val
      window.location.href = "/reachout_tab_settings/index?type=rca&search=" + $('#txt_rca_search').val()
    $('#txt_rca_search').bind('keypress', (e) ->
      if(e.keyCode==13)
        $('#txt_rca_search').val
        window.location.href = "/reachout_tab_settings/index?type=rca&search=" + $(e.target).val()
    )

    $('#search_broadcast').click ->
      $('#txt_broadcast_search').val
      window.location.href = "/reachout_tab_settings/index?type=brd&search=" + $('#txt_broadcast_search').val()
    $('#txt_broadcast_search').bind('keypress', (e) ->
      if(e.keyCode==13)
        $('#txt_broadcast_search').val
        window.location.href = "/reachout_tab_settings/index?type=brd&search=" + $(e.target).val()
    )

    $(document).on('click', '.reachout_tab_settings_phone_delete', ( (e) ->
      if confirm "Do you want to delete selected phone number from DNC list?"
        id = $(this).attr('data-val')
        url = "/reachout_tab_settings/delete_phone_dnc/" + id
        $.ajax({
          url: url
          data: {'id':id}
          type: 'DELETE'
          success: (res) ->
            $('#'+id).remove();
          error: (res) ->
            return
          complete: (res) ->
        })
    )  )
    show_alert = () ->
      $('.info').html('')

    true
