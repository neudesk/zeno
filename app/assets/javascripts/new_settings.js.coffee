class window.NewSettings
    constructor: (options)->
        @setup(options)

    setup: (options)->
      slider()
      phoneDeletionOpener()

    $rca_id = $('#rca_id').val();
    $country_id = $('#country_id').val();
    $search = $('#query').val();

    phoneDeletionOpener = () ->
        if $(".close_delete").length > 0
            $(".close_delete").hide()
            $(".phone_form").hide()

        $(".open_delete").on "click", (e) ->
            e.preventDefault()
            $(".open_delete").hide()
            $(".phone_numbers").hide()
            $(".close_delete").show()
            $(".phone_form").show()

        $(".close_delete").on "click", (e) ->
            e.preventDefault()
            $(".open_delete").show()
            $(".phone_numbers").show()
            $(".close_delete").hide()
            $(".phone_form").hide()

    $search = "";
    $country_id = "";
    $rca_id = "";

    ajaxAnim = (x) ->
      $('#inside_slider').removeClass().addClass(x + ' animated').one 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', () ->
        $(this).removeClass()
      return

    ajaxSlide = (page) ->
      $.ajax({
        url: "/application/slider_content/" + page,
        data:
          search: $search
          country_id: $country_id
          rca_id: $rca_id
          controller_name: "new_settings"
        success: (data) ->
          $('#next-slide').show()
          $('#prev-slide').show()
      }).done (data) ->
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

    nextSlide = () ->
      $("#next-slide").click () ->
        if parseInt($('#page').val()) >= parseInt($('#total_page').text())
          $(this).hide()
        else
          ajaxAnim('bounceInRight')
          $page = parseInt($('#page').val())
          $('#page').val($page+1)
          ajaxSlide($page+1, $country_id)
          $("#prev-slide").show()
      return

    prevSlide = () ->
      $("#prev-slide").click () ->
        if parseInt($('#page').val()) == 0
          $(this).hide()
          $('#page').val(1)
        else
          ajaxAnim('bounceInLeft')
          $page = parseInt($('#page').val())
          $('#page').val($page-1)
          ajaxSlide($page-1)
          $("#next-slide").show()
      return

    setPage = () ->
      $('#page').keyup () ->
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
            $('.slider_content').removeClass('hide')
          else
            alert 'Please enter a valid page.'
        return
      return

    search = () ->
      $('.query-search-country-id').change () ->
        ajaxAnim('fadeIn')
        $country_id = $(this).val()
        ajaxSlide(1)
        $('.slider_content').slideDown(300)
        return

      $('.query-search-rca-id').change () ->
        ajaxAnim('fadeIn')
        $rca_id = $(this).val()
        ajaxSlide(1)
        $('.slider_content').slideDown(300)
        return

      $('input[name="query"]').on 'change', () ->
        ajaxAnim('fadeIn')
        $search = $('#query').val()
        $('#page').val(1)
        ajaxSlide(1)
        $('.slider_content').slideDown(300)
        return

      $('#searchStation').click () ->
        ajaxAnim('fadeIn')
        $search = $('#query').val()
        $('#page').val(1)
        ajaxSlide(1)
        $('.slider_content').slideDown(300)
        return

    setPreload = () ->
      $(document).ajaxStart ( event,request, settings ) ->
        $('.slider-loading').show()
        return
      $(document).ajaxComplete ( event,request, settings ) ->
        $('.slider-loading').hide()
        return

    slider = () ->
      ajaxSlide(1)
      nextSlide()
      prevSlide()
      setPage()
      search()
      setPreload()
      return
