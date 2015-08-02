class DataGatewayConferencesController < ApplicationController
  respond_to :js, :html
  def edit
    p @conference = DataGatewayConference.find_by_id(params[:id])
    @data_content_off_air = DataContentOffAir.where(:content_id => @conference.content_id) 
    @week_day = ["Sunday :", "Monday :", "Tuesday :", "Wednesday :", "Thursday :", "Friday :", "Saturday :"]
  end

  def update
    flash[:hash] = "extensions"
    @conference = DataGatewayConference.find_by_id(params[:id])
    @content = @conference.content
    old_url = @content.media_url
    old_backup = @content.backup_media_url
    old_name = @content.title
    old_extension = @conference.extension
    old_media_type = @conference.content.media_type
    new_media_type = params[:data_gateway_conference][:content_attributes][:media_type]

    if @conference.update_attributes(params[:data_gateway_conference])
      @content = @conference.content
      new_url = @content.media_url
      new_backup = @content.backup_media_url
      new_name = @content.title
      new_extension = @conference.extension

      if old_backup != new_backup
        @content.create_activity key: 'data_content.update_backup', owner: current_user, trackable_title: @content.title, user_title: user_title, parameters: {old_backup: old_backup, new_backup: new_backup}
      end

      if old_url == new_backup && old_backup == new_url
        @content.create_activity key: 'data_content.switch_stream', owner: current_user, trackable_title: @content.title, user_title: user_title, parameters: {old_url: old_url, new_url: new_url, channel_no: new_extension}
        Delayed::Job.enqueue UpdateRadioJarMediaUrl.new(@content.id), 0
        Delayed::Job.enqueue UpdateRadioJarMediaContentJob.new(@content.id), 0
        RADIO_JAR.info "Content #{@content.try(:title)} is enqued to update Radio Jar."
      elsif old_url != new_url
        @content.create_activity key: 'data_content.change_stream_url', owner: current_user, trackable_title: @content.title, user_title: user_title, parameters: {old_url: old_url, new_url: new_url, channel_no: new_extension}
        Delayed::Job.enqueue UpdateRadioJarMediaUrl.new(@content.id), 0
        Delayed::Job.enqueue UpdateRadioJarMediaContentJob.new(@content.id), 0
        RADIO_JAR.info "Content #{@content.try(:title)} is enqued to update Radio Jar."
      end

      if old_media_type != new_media_type && old_media_type.present?
       @content.create_activity key: 'data_content.media_type', owner: current_user, trackable_title: @content.title, user_title: user_title,
       parameters: {:old_media_type =>old_media_type, :new_media_type => new_media_type, channel_no: new_extension}
     end
      if old_name != new_name && old_name.present?
        @content.create_activity key: 'data_content.change_name', owner: current_user, trackable_title: @content.title, user_title: user_title, parameters: {old_url: old_url, new_url: new_url, channel_no: new_extension, old_name: old_name, new_name: new_name}
      end
      if old_extension != new_extension && old_extension.present?
        @conference.gateway.create_activity key: 'data_gateway.move_content', owner: current_user, parameters: {extension_id: @conference.id, content_id: @content.id, old_extension: old_extension, new_extension: new_extension, name: @content.title}, trackable_title: @conference.gateway.title, user_title: user_title, sec_trackable_title: @content.title, sec_trackable_type: 'DataContent'
      end
      redirect_to :back, notice: "Successfully updated extension details."
    else
      redirect_to :back, error: "Error Occured. Please contact System Administrator."
    end
  end

  def switch
    @conference = DataGatewayConference.find_by_id(params[:id])
    content = @conference.content
    old_url = content.media_url
    new_url = content.backup_media_url
    if content.update_attributes(media_url: new_url, backup_media_url: old_url)
      content.create_activity key: 'data_content.switch_stream', owner: current_user, trackable_title: content.title, user_title: user_title, parameters: {old_url: old_url, new_url: new_url, channel_no: @conference.extension}
      RADIO_JAR.info "Content #{content.try(:title)} is enqued to update Radio Jar."
      Delayed::Job.enqueue UpdateRadioJarMediaUrl.new(content.id), 0
      Delayed::Job.enqueue UpdateRadioJarMediaContentJob.new(content.id), 0
      redirect_to :back, notice: "Successfully switched media and backup URLs."
    else
      redirect_to :back, notice: "Error Occured. Please contact System Administrator."
    end
  end
end