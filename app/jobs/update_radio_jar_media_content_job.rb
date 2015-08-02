class UpdateRadioJarMediaContentJob < Struct.new(:content_id)
  def perform
  	@content = DataContent.find(content_id) rescue nil
  	if @content.present?
	  	RADIO_JAR.info "Refresh RadioJar content #{@content.try(:title)} ..."
			RADIO_JAR.info "Im using #{RADIO_JAR_ENDPOINT} as an endpoint."
	  	refreshContent(true)
	else
		RADIO_JAR.error "Content not found!"
	end  	
  	RADIO_JAR.info "Done"
  end

  def refreshContent(is_enabled)	
  	begin
  		if is_enabled
			RADIO_JAR.info "Enabling ..."
		else
			RADIO_JAR.info "Disabling ..."
		end	
		RADIO_JAR.debug @content.updateRadioJar(is_enabled)	
  	rescue exception => e
  		RADIO_JAR.error "#{e}"
  	end	
  end	

end