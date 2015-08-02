class SetDefaultDID < Struct.new(:params)
  def perform
  	prim, sec = AdminSetting.get_default_clec_config
  	prim.update_attributes({value: params[:primary_campaign_default_did_provider]}) if prim.present?
  	sec.update_attributes({value: params[:secondary_campaign_default_did_provider]}) if sec.present?
  	CAMPAIGNS_LOG.info "Primary:"
  	CAMPAIGNS_LOG.debug prim.to_json
  	CAMPAIGNS_LOG.info "Sec:"
  	CAMPAIGNS_LOG.debug sec.to_json
  end
end