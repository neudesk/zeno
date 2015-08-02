# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class window.MyRadio
  constructor: ->
    @setup()
  setup: ->
    @stationSection = $(".my_radio.station")
    @initContentLanguageSelectBox()

  initContentLanguageSelectBox: ->
    @stationSection.find('.contents').find(".language_name").find(".remove_new_language_btn").find("a").click()
    @stationSection.find('.contents').find(".language_name").find('select').append("<option value = '-1'>---------------------------</option>
                                                             <option value='new_lang'>Other</option>")
    @stationSection.find('.contents').find(".language_name").find('select').off("click")
    @stationSection.find('.contents').find(".language_name").find('select').on("click", (event)=>

        target = $(event.target)
        if target.val() is "new_lang"
          target.val("new_lang")
          #target.parents(".language_name").find(".new_language_section").find(".add_new_language_btn").find("a").click()
          target.parents(".language_name").find(".new_language_section").find(".fields").show();
          target.parents(".language_name").find(".new_language_section").find(".remove_new_language_btn").find("input").val("false");


        else if target.val() is "-1"
          target.val("")
          target.parents(".language_name").find(".new_language_section").find(".remove_new_language_btn").find("a").click()
        else
          target.parents(".language_name").find(".new_language_section").find(".remove_new_language_btn").find("a").click()

      )
