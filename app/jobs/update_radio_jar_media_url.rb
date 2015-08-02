class UpdateRadioJarMediaUrl < Struct.new(:content_id)
  def perform
    @content = DataContent.find(content_id) rescue nil
    if @content.present?
      RADIO_JAR.info "Im using #{RADIO_JAR_ENDPOINT} as an endpoint."
      sendMediaUrl
    else
      RADIO_JAR.error "Content not found!"
    end
    RADIO_JAR.info "Done"
  end

  def sendMediaUrl
    RADIO_JAR.info "Now sending media url #{@content.media_url} to rtapi"
    if @content.media_url.present? and @content.media_url != ''
      RADIO_JAR.debug @content.sendMediaUrlToRadioJar
    else
      RADIO_JAR.info "Not sending media url to rtapi because the media url is empty"
    end
  end

end