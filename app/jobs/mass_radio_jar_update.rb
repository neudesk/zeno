class MassRadioJarUpdate < Struct.new(:gateway_id)
  def perform
    @station = DataGateway.find(gateway_id)
    if @station.widget_is_set_up
      @station.data_gateway_conferences.each do |conf|
        enableContent(conf.data_content)
      end
    else
      RADIO_JAR.info 'No need for RadioJar enabling. This task is already been performed.'
    end
    RADIO_JAR.info 'Done'
  end

  def enableContent(content)
    RADIO_JAR.info "Enabling and sending content #{content.title} media url "
    if content.media_url.present? and content.media_url != ''
      RADIO_JAR.debug content.sendMediaUrlToRadioJar
      RADIO_JAR.debug content.updateRadioJar(true)
    else
      RADIO_JAR.info 'Unable to enable or send media url because the media url is empty'
    end
  end

end