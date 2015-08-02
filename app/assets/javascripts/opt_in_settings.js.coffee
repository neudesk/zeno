class window.OptInSettings
  constructor: ()->
    
    $(".opt_in_brd").bootstrapSwitch();
    $(".opt_in_rca").bootstrapSwitch();

    $(".opt_in_brd").on "switchChange.bootstrapSwitch", (event, state) ->
        status = state 
        data = $(this).data('val')
        url = "/opt_in_settings/activate_brd?id=" + data 
        $.ajax({
	         url: url
	         data: {'id' : data, 'status': status}
	         type: 'PUT'
	         success: (res) ->
	         
	         error: (res) ->
	           return
	         complete: (res) ->
         	})


    $(".opt_in_rca").on "switchChange.bootstrapSwitch", (event, state) ->
        status = state 
        data = $(this).data('val')
        url = "/opt_in_settings/activate_rca?id=" + data 
        $.ajax({
	         url: url
	         data: {'id' : data, 'status': status}
	         type: 'PUT'
	         success: (res) ->
	         error: (res) ->
	           return
	         complete: (res) ->
         	})

    $("#txt_search_opt_in").bind('keyup', (e) ->
        data = $(this).val()
        url = "/opt_in_settings/search_phone" 
        $.ajax({
         url: url
         data: {'phone_number':data}
         type: 'GET'
         success: (res) ->
          html = ''
          for result in res.opt_in_list
           html +='<li id="'+result.id+'"><p class="phone_number">'+result.ani_e164+'</p><button class="phone_delete_opt_in" data-val="'+result.id+'">x</button></li>'
          $('.opt_in_list').html(html)
         error: (res) ->
           return
         complete: (res) ->
         }))
    $("#btn_search_opt_in").click =>
        data = $('#txt_search_opt_in').val()
        url = "/opt_in_settings/search_phone" 
        $.ajax({
         url: url
         data: {'phone_number':data}
         type: 'GET'
         success: (res) ->
          html = ''
          for result in res.opt_in_list
           html +='<li id="'+result.id+'"><p class="phone_number">'+result.ani_e164+'</p><button class="phone_delete_opt_in" data-val="'+result.id+'">x</button></li>'
          $('.opt_in_list').html(html)
         error: (res) ->
           return
         complete: (res) ->
         })
      
    $("#add_phone_opt_in").click =>
      data = $('#txt_phone_opt_in').val()
      url = "/opt_in_settings/add_phone_opt_in" 
      $.ajax({
       url: url
       data: {'phone_number':data}
       type: 'POST'
       success: (res) ->
        if res.message =="Succes"
          html ='<li id="'+res.id+'" style="display: inline-block; margin: 2px" >'
          html +='<span class="label label-info phone_number">'+ data
          html +='<a href="#" class="phone_delete_opt_in btn btn-xs" style="color: #ffffff" data-val="'+res.id+'">'
          html +='<i class="fa fa-trash-o"></i>'
          html +='</a>'
          html +='</span>'
          html +='</li>'
          $('.opt_in_list').append(html)
          $('#txt_phone_opt_in').val('')
          $('.opt_in_list_length').text("Opt-In List Length : " +res.opt_in_list_length)
          $('.info').append('<div class="alert fade in alert-succes"><button class="close" data-dismiss="alert">×</button>Phone number saved successfully.</div>')
        else
          $('.info').append('<div class="alert fade in alert-error"><button class="close" data-dismiss="alert">×</button>' + res.message + '</div>')
        setTimeout(show_alert,5000)
       error: (res) ->
         return
       complete: (res) ->
       })

    $('#search_rca_opt_in').click ->
       $('#txt_rca_search_opt_in').val
       window.location.href = "/opt_in_settings?type=rca&search=" + $('#txt_rca_search_opt_in').val()
    $('#txt_rca_search_opt_in').bind('keypress', (e) ->
       if(e.keyCode==13)
         $('#txt_rca_search_opt_in').val
         window.location.href = "/opt_in_settings?type=rca&search=" + $(e.target).val()
     )

    $('#search_broadcast_opt_in').click ->
       $('#txt_broadcast_opt_in_search').val
       window.location.href = "/opt_in_settings?type=brd&search=" + $('#txt_broadcast_opt_in_search').val()
    $('#txt_broadcast_opt_in_search').bind('keypress', (e) ->
       if(e.keyCode==13)
         $('#txt_broadcast_opt_in_search').val
         window.location.href = "/opt_in_settings?type=brd&search=" + $(e.target).val()
     )

    $(document).on('click', '.phone_delete_opt_in', ( (e) ->
       if confirm "Do you want to delete selected phone number from Opt-In list?"
         id = $(this).data('val')
         url = "/opt_in_settings/delete_phone_opt_in/" + id
         $.ajax({
          url: url
          data: {'id':id}
          type: 'DELETE'
          success: (res) ->
           $('#'+id).remove();
           $('.opt_in_list_length').text("Opt-In List Length : " +res.opt_in_list_length)
          error: (res) ->
            return
          complete: (res) ->
          })
     )  )
    show_alert = () ->
      $('.info').html('')


