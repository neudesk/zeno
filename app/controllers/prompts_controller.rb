class PromptsController < ApplicationController
  before_filter :authenticate_user!

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - index.js.haml
  # Description: This page is loaded when there's no station selected
  # Notes: Need to be improved :)
  #==========================================================================
  def index
    @prompt = DataGatewayPrompt.new

    @station = @stations.first


    if @station
      @data_gateway_id = @station.id
      @selected_welcome_prompt = @station.welcome_prompt.id if @station.welcome_prompt != nil
      @selected_ask_prompt = @station.ask_prompt.id if @station.ask_prompt != nil
      @selected_invalid_prompt = @station.invalid_prompt.id if @station.invalid_prompt != nil

      @prompts = DataGatewayPrompt.where(gateway_id: @station.id)
    end

    render "data_gateways/prompts"
  end

  #==========================================================================
  # Method: post
  # Parameters:
  # + name:, format:
  # Responses:
  #  - prompts.js.haml
  # Description: upload an audio file and save its binary code to database
  # Notes: 
  #  - SoX - Sound eXchange must be installed 
  #  - Mp3 lib for SoX (libsox-fmt-mp3) must be installed
  #==========================================================================
  def save
    
    @prompt = DataGatewayPrompt.new(params[:data_gateway_prompt])
    @prompt.build_data_gateway_prompt_blob
    @prompt.raw_audio

    data = DataGatewayPrompt::convert_uploaded_audio(@prompt.raw_audio)


    if data.status == DataGatewayPrompt::CONVERT_OK
      @prompt.media_kb = data.media_kb
      @prompt.media_seconds = data.duration
      @prompt.date_last_change = Time.now


      @prompt.data_gateway_prompt_blob.binary = data

      success_save = @prompt.save
      flash[:notice] = "Saved successfully"
      if success_save
        station = @prompt.data_gateway
        station.create_activity key: 'data_gateway.create_prompt', owner: current_user,
            trackable_title: station.title, user_title: user_title, parameters: {:prompt_id => @prompt.id },
            sec_trackable_title: @prompt.title, sec_trackable_type: 'DataGatewayPrompt'
      end
      
      # redirect_to data_gateway_prompts_path(params[:data_gateway_id])
    else
      flash[:error] = "Invalid audio format. Ony wav/mp3 format is supported"
      # redirect_to data_gateway_prompts_path(params[:data_gateway_id])
    end

    load_prompts
    
    respond_to do |format|
      format.js {render "data_gateways/prompts"}
    end

  end

  def destroy
    flash[:hash] = "prompts"
    @prompt = DataGatewayPrompt.find(params[:id])
    gateway = @prompt.data_gateway
    if @prompt.destroy
      gateway.create_activity key: 'data_gateway.destroy_prompt', owner: current_user, trackable_title: gateway.title, user_title: user_title, parameters: {:prompt_id => @prompt.id }, sec_trackable_title: @prompt.title, sec_trackable_type: 'DataGatewayPrompt'
      redirect_to :back, notice: "Successfully deleted prompt"
    else
      redirect_to :back, alert: "Error Occured. Please contact System Administrator."
    end
  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - prompts.js.haml
  # Description: Show edit prompts dialog
  #==========================================================================
  def edit
    @prompt = DataGatewayPrompt.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  #==========================================================================
  # Method: put
  # Parameters:
  # + name:, format:
  # Responses:
  #  - prompts.js.haml
  # Description: Update edited prompts
  #==========================================================================
  def update
    @prompt = DataGatewayPrompt.find(params[:id])

    uploaded_data = params[:data_gateway_prompt][:raw_audio]
    if uploaded_data != nil

      data = DataGatewayPrompt::convert_uploaded_audio(uploaded_data)

      if data.status == DataGatewayPrompt::CONVERT_OK

        params[:data_gateway_prompt][:media_kb] = data.media_kb
        params[:data_gateway_prompt][:media_seconds] = data.duration
        params[:data_gateway_prompt][:date_last_change] = Time.now
        params[:data_gateway_prompt][:data_gateway_prompt_blob_attributes] = {:binary => data, :id => params[:id]}


        @prompt.update_attributes(params[:data_gateway_prompt])

        flash[:notice] = "Updated successfully"
        redirect_to data_gateway_prompts_path(params[:data_gateway_id])
      else
        flash[:error] = "Invalid audio format. Ony wav/mp3 format is supported"
        redirect_to data_gateway_prompts_path(params[:data_gateway_id])
      end
    else
      @prompt.update_attributes(params[:data_gateway_prompt])

      flash[:notice] = "Updated successfully"
      redirect_to data_gateway_prompts_path(params[:data_gateway_id])
    end

  end

  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - gsm_audio.gsm
  # Description: Get gsm audio file
  #==========================================================================
  def gsm_audio
    @prompt_blog = DataGatewayPromptBlob.find params[:id]
    render :text => @prompt_blog.binary, :content_type => "audio/x-gsm"
  end


  #==========================================================================
  # Method: get
  # Parameters:
  # + name:, format:
  # Responses:
  #  - gsm_audio.mp3
  # Description: Get mp3 audio file
  def mp3_audio
    @prompt_blog = DataGatewayPromptBlob.find params[:id]
    if @prompt_blog.present?
      render :text => @prompt_blog.get_mp3, :content_type => "audio/mpeg"
    else
      redirect_to :back, alert: "Can't find the sound file. Please ask System Administrator."
    end
  end

  def wav_audio
    @prompt_blog = DataGatewayPromptBlob.find_by_id(params[:id])
    if @prompt_blog.present?
      render :text => @prompt_blog.get_wav, :content_type => "audio/x-wav"
    else
      redirect_to :back, alert: "Can't find the sound file. Please ask System Administrator."
    end
  end

  def download_prompt
    @prompt_blog = DataGatewayPromptBlob.find_by_id(params[:id])
    if @prompt_blog.present?
      send_data @prompt_blog.get_wav, :type => "audio/x-wav", :filename =>  DataGatewayPrompt.find(params[:id]).title + ".wav", :disposition => 'attachment'
    else
      if request.referer.present?
        redirect_to :back, alert: "Can't find the sound file. Please ask System Administrator."
      else
        render :json => {:error => "Can't find the sound file. Please ask System Administrator."}
      end
    end
  end

  protected

  #==========================================================================
  # Method: put
  # Parameters:
  # + name:, format:
  # Responses:
  #  
  # Description: deprecateds
  #==========================================================================
  def load_prompts
    @prompt = DataGatewayPrompt.new
    @station = DataGateway.find params[:data_gateway_id]
    @prompts = @station.data_gateway_prompts
  end


end
