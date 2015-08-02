class DataContentsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js, :html

  def edit
    @content = DataContent.find(params[:id])
    @content_query = params[:content_query]
    @data_content_off_air = DataContentOffAir.where(:content_id => params[:id])
    @week_day = ["Sunday :", "Monday :", "Tuesday :", "Wednesday :", "Thursday :", "Friday :", "Saturday :"]
  end

  def update
    @data_content = DataContent.find(params[:id])
    old_url = @data_content.media_url
    old_backup = @data_content.backup_media_url
    old_name = @data_content.title
    old_media_type = @data_content.media_type
    new_media_type = params[:data_content][:media_type]

    success_update = @data_content.update_attributes(params[:data_content])

    new_name = @data_content.title
    new_url = @data_content.media_url
    new_backup = @data_content.backup_media_url
    data_gateways = @data_content.data_gateways
    data_gateway_conferences = @data_content.data_gateway_conferences
    channels = ""
    if data_gateway_conferences.present?
      data_gateway_conferences.each_with_index do |ext, index|
        if index + 1 < data_gateway_conferences.length
          comma = ","
        else
          comma = ""
        end
        channels += data_gateways.where(:id => ext.gateway_id).select(:title).first.title.to_s + " (Extension #{ext.extension})#{comma} " if data_gateways.where(:id => ext.gateway_id).present?
      end
    end
    if success_update
      if current_user.is_rca? || current_user.is_marketer?
        (0..7).each do |d|
          day = params[:day][d]
          time_end = "00:00"
          time_start = "00:00"

          if params[:time_end][d].present? && (params[:time_end][d]).scan(/\d\d/)[1].present?
            time_start = (DateTime.parse(params[:time_end][d]) + 1.minute).strftime("%H:%M") if params[:time_end][d] != params[:time_start][d]
          end

          if params[:time_start][d].present? && (params[:time_start][d]).scan(/\d\d/)[1].present?
            time_end = (DateTime.parse(params[:time_start][d]) - 1.minute).strftime("%H:%M") if params[:time_end][d] != params[:time_start][d]
          end

          #stream_url = params[:stream_url][d].present? ? params[:stream_url][d] : ""
          #stream = params["stream" + (d - 1).to_s]

          if DataContentOffAir.where(:content_id => params[:content_id], :day => day).present?
            #if stream.present? 
            #  stream_url = "" 
            #end
            data_content_off_air = DataContentOffAir.where(:content_id => params[:content_id], :day => day).first
            #data_content_off_air.update_attributes({"time_start" => time_start, "time_end" => time_end, "stream_url" => stream_url, :stream => stream}) if data_content_off_air.present?
            data_content_off_air.update_attributes({"time_start" => time_start, "time_end" => time_end}) if data_content_off_air.present?
          else
            #if stream.present?
            #  stream_url = "" 
            #end
            #DataContentOffAir.create(:content_id =>params[:content_id], :day => day, :time_start => time_start, :time_end => time_end, :stream_url => stream_url, :stream => stream)
            DataContentOffAir.create(:content_id => params[:content_id], :day => day, :time_start => time_start, :time_end => time_end)
          end
        end
      end

      if old_media_type != new_media_type && old_media_type.present?
        @data_content.create_activity key: 'data_content.media_type', owner: current_user, trackable_title: @data_content.title, user_title: user_title,
                                      parameters: {:old_media_type => old_media_type, :new_media_type => new_media_type, :channels => channels}
      end


      if old_name != new_name
        @data_content.create_activity key: 'data_content.change_name', owner: current_user, trackable_title: @data_content.title, user_title: user_title,
                                      parameters: {:old_name => old_name, :new_name => new_name, :channels => channels}
      end

      if old_url == new_backup && old_backup == new_url
        @data_content.create_activity key: 'data_content.switch_stream', owner: current_user, user_title: user_title,
                                      trackable_title: @data_content.title, parameters: {:old_url => old_url, :new_url => new_url, :channels => channels}
      elsif old_url != new_url
        @data_content.create_activity key: 'data_content.change_stream_url', owner: current_user, trackable_title: @data_content.title, user_title: user_title,
                                      parameters: {:old_url => old_url, :new_url => new_url, :channels => channels}
      elsif new_backup != old_backup
        @data_content.create_activity key: 'data_content.backup_media_url', owner: current_user, user_title: user_title,
                                      trackable_title: @data_content.title, parameters: {:old_backup => old_backup, :new_backup => new_backup, :channels => channels}
      end
      redirect_to search_content_search_path(:content_query => params[:content_query]), notice: "Your content has been updated."
    else
      redirect_to search_content_search_path(:content_query => params[:content_query]), alert: "Error Occurred."
    end
  end


  def update_schedule
    if current_user.is_rca? || current_user.is_marketer?
      hasError = nil
      sched = nil
      data = []
      (-1..6).each do |day|
        begin
          onair_schedule = DataContentOffAir.find_or_create_by_content_id_and_day(params[:content_id], day)
          time_start = DateTime.parse(params[:time_start][day.to_s]).strftime("%H:%M")
          time_end = DateTime.parse(params[:time_end][day.to_s]).strftime("%H:%M")
          onair_schedule.time_start = time_start
          onair_schedule.time_end = time_end
          onair_schedule.save
        rescue => e
          hasError = e.message
        end
      end
      if hasError.nil?
        render json: {error: 0, message: 'Success'}
      else
        render json: {error: 1, message: hasError}
      end
    end
  end

  def show
    @data_content = DataContent.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def destroy
    data_content = DataContent.find_by_id(params[:id])
    if data_content.blank?
      redirect_to :back, alert: "Content already has been deleted."
    elsif data_content.is_deleted
      redirect_to search_content_search_path(:content_query => params[:content_query]), notice: "Your content has been deleted."
    else
      success_delete = data_content.update_attribute(:is_deleted, true)
      data_content.create_activity key: 'data_content.destroy', owner: current_user, trackable_title: data_content.title, user_title: user_title,
                                   parameters: {:content_id => data_content.id, :media_url => data_content.media_url, :channel_no => data_content.data_gateway_conferences.try(:first).try(:extension)}
      if success_delete
        data_gateway_conference = DataGatewayConference.where(:content_id => params[:id])
        if data_gateway_conference.present?
          data_gateway_conference.each do |dgc|
            dgc.destroy
          end
        end

        redirect_to search_content_search_path(:content_query => params[:content_query]), notice: "Your content was successfully deleted."
      else
        flash[:error] = "<ul>" + data_content.errors.messages.values.map { |o| o.map { |p| "<li>"+p+"</li>" }.join(" ") }.join(" ") + "</ul>"
        flash[:error] = flash[:error] + "<ul><li>Your content was unsuccessfully deleted.</li></ul>"
        redirect_to search_content_search_path(:content_query => params[:content_query])
      end
    end
  end

  def suggestion
    if params[:query].present?
      results = DataContent.where("media_url LIKE :key OR title LIKE :key", key: "%#{params[:query].strip}%").limit(10)
    else
      results = DataContent.limit(10)
    end
    final = results.collect { |x| {id: x.id, name: "#{x.title} - #{x.media_url}"} }
    render json: final.to_json
  end

  def switch
    content = DataContent.find_by_id(params[:id])
    old_url = content.media_url
    new_url = content.backup_media_url
    if content.update_attributes(media_url: new_url, backup_media_url: old_url)
      content.create_activity key: 'data_content.switch_stream', owner: current_user, trackable_title: content.title, user_title: user_title, parameters: {old_url: old_url, new_url: new_url}
      redirect_to search_content_search_path(content_query: params[:query]), notice: "Successfully switched media and backup URLs."
    else
      redirect_to search_content_search_path(content_query: params[:query]), notice: "Error Occured. Please contact System Administrator."
    end
  end

  def set_content_brd_id
    if request.xhr?
      content = DataContent.find(params[:content_id]) rescue nil
      if params[:brd_id] and content.present?
        content.update_attributes(broadcast_id: params[:brd_id])
        render json: {error: 0, message: 'success', data: content}
      else
        render json: {error: 1, message: 'insufficient parameters', data: []}
      end
    else
      render json: {error: 1, message: 'Invalid request!', data: []}
    end
  end

end
