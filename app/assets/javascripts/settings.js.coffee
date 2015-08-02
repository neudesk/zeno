# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class window.Settings
  constructor: (options)->
    if options != undefined
      isAjaxLoading = options["ajax"]
      
    if isAjaxLoading != undefined && isAjaxLoading
      #page load
      @setupAjaxComponents()
    else
      #ajax load
      @setup(options)

  setupAjaxComponents: (options) ->
    @initDIDsSection()
    @initEnlessPageForDIDs()

  setup: (options)->
    @settingSection = $(".main .settings_page")
    @initDIDsSection()
    @initEnlessPageForDIDs()
    @initExtensionsTab()


  initExtensionsTab: =>
    @settingSection.find('.extensions-tab').find('a').click();

  initDIDsSection: =>
    $('.delete_btn').off("click");
    $('.delete_btn').on("click", (event)=>
        event.preventDefault();
        target = $(event.target)
        if confirm "Are you sure you want to delete?"
          $('.unassign_dids_form').submit()
          true
        else
          return false
    )

    $(".selected_did_chk").hide();
    $('.add_btn').hide();
    $('.delete_btn').hide();
    $('.cancel_btn').hide();
    
    $('.edit_btn').off("click");
    $('.edit_btn').on("click", (event)=>
      event.preventDefault();
      target = $(event.target)
      $('.add_btn').show();
      $('.delete_btn').show();
      $('.cancel_btn').show();
      $(".selected_did_chk").show();
      target.hide()
    )

    $('.cancel_btn').off("click");
    $('.cancel_btn').on("click", (event)=>
      event.preventDefault();
      target = $(event.target);
      $('.add_btn').hide();
      $('.delete_btn').hide(); 
      $(".selected_did_chk").hide();
      $('.edit_btn').show();

      target.hide();

    )

  initEnlessPageForDIDs: ->

    event_scroller = $(".did_section").find(".endless_scroll")
    $(event_scroller).scroll( (e) ->
      target = $(e.target)
      is_processing =  $(target).data("processing")
      if is_processing == undefined
        is_processing = false

      if is_processing
        return false

      if $(target).scrollTop() >= $(target).prop('scrollHeight') - 120 -10
        $(target).data("processing", true)
        #alert("processing")
        page = $(target).data("page")
        if page == undefined
          page = 1 


        gateway_id = $(target).data("gateway-id")

        $.ajax
            type: 'get'
            url: "/data_gateways/"+gateway_id+"/dids_scroll?page="+(page+1)
            success: (data) ->
              $(target).data("processing", false)

        $(target).scrollTop(  $(target).scrollTop() - 10 )
        
    )
    