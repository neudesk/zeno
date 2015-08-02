# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
class window.Prompts
  constructor: ->
    @setup()
  setup: ->
    @gatewayPromptsSection = $(".gateway_prompts")
    @jquery_jplayer = $(".jquery_jplayer")
    @initJPlayer()
    @initJPlayerButtons()
    

  initJPlayer: ->

    $(".jquery_jplayer").jPlayer({
      ready: =>
        @jquery_jplayer.addClass("ready")
      ,
      swfPath: "/",
      solution:"flash, html",
      supplied: "wav"
    })

  initJPlayerButtons: ->
    
    @gatewayPromptsSection.find('.jp_container').find(".jp_prompt_stop").hide()

    @gatewayPromptsSection.find('.jp_container').find(".jp_prompt_play").on("click", (event)=>
        event.preventDefault()
        target = $(event.target)
        if @jquery_jplayer.hasClass("ready") 
          audio_url = target.attr("href")
          @jquery_jplayer.jPlayer("setMedia", {
            wav: audio_url
          });
          @jquery_jplayer.jPlayer("play")

          #Show all play button
          @gatewayPromptsSection.find('.jp_container').find(".jp_prompt_play").show()
          #Hide all stop button
          @gatewayPromptsSection.find('.jp_container').find(".jp_prompt_stop").hide()
          #Hide itself
          target.hide()
          #Show its stop button
          target.parents(".jp_container:first").find(".jp_prompt_stop").show();

      )
    @gatewayPromptsSection.find('.jp_container').find(".jp_prompt_stop").on("click", (event)=>
        event.preventDefault()
        target = $(event.target)
        @jquery_jplayer.jPlayer("stop")

        #Show all play button
        @gatewayPromptsSection.find('.jp_container').find(".jp_prompt_play").show()
        #Hide all stop button
        @gatewayPromptsSection.find('.jp_container').find(".jp_prompt_stop").hide()
        #Hide itself
        target.hide()
        #Show its stop button
        target.parents(".jp_container:first").find(".jp_prompt_play").show();

      )
