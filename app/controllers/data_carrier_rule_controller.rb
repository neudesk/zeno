class DataCarrierRuleController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_var, only: [:index, :create]

  def index
    if !marketer?
      flash[:error] = 'Unauthorized access'
      redirect_to root_path
    end
  end

  def create
    if params[:creation_type] == 'rule'
      @rule = DataCarrierRule.new(params[:data_carrier_rule])
      if validate_rule_existence.empty?
        if @rule.save
          flash[:notice] = "Added a new rule"
        else
          flash[:error] = "Something went wrong, Please contact administrator."
        end
        redirect_to :back
      else
        rule = validate_rule_existence
        flash[:error] = "Rule is already exists, Please check line #{rule.first.id} ." if rule.present?
        render :index
      end
    end
    if params[:creation_type] == 'carrier'
      if @carrier.save
        render json: {status: 'ok', carrier: @carrier.to_json}
      else
        render json: {status: 'error', error: @carrier.errors.messages}
      end
    elsif params[:creation_type] == 'prompt'
      @prompt.build_data_gateway_prompt_blob
      data = DataGatewayPrompt::convert_uploaded_audio(@prompt.raw_audio)
      if data.status == DataGatewayPrompt::CONVERT_OK
        @prompt.media_kb = data.media_kb
        @prompt.media_seconds = data.duration
        @prompt.date_last_change = Time.now
        @prompt.data_gateway_prompt_blob.binary = data
        if @prompt.save
          render json: {status: 'ok', prompt: @prompt.to_json}
        else
          render json: {status: 'error', error: @prompt.errors.messages, params: params}
        end
      else
        render json: {status: 'error', error: "Invalid audio format. Ony wav/mp3 format is supported"}
      end
    end
  end

  def update_rule
    rule = DataCarrierRule.find_by_id(params[:id])
    rules_params = params[:data_carrier_rule]
    has_empty = false
    if rule.present?      
      rules_params.each do |k, v|
        has_empty = v.to_s.empty?
      end
      if has_empty
        flash[:error] = 'Emptying a field when editing a rule is not allowed, Please fill up all fields.'
      else
        rule.update_attributes(rules_params)       
        flash[:notice] = "Rule has been successfully updated!"
      end
    end
    @rule = rule
    redirect_to :back
  end

  def destroy
    rule = DataCarrierRule.find_by_id(params[:id])
    rule.destroy if rule.present?
    redirect_to :back
  end

  def set_default_prompt_handler
    if params[:gateway_prompt_handler_id].present?
      gateway = DataGateway.find_by_id(params[:gateway_prompt_handler_id])
      config = GlobalSetting.find_by_name('default_prompt_list_handler')
      if config.present?
        config.update_attributes(value: gateway.id)
      else
        config = GlobalSetting.create(group: 'DATA_CARRIER_PROMPT', name: 'default_prompt_list_handler', value: gateway.id) if gateway.present?
      end
      render json: {status: 'ok', gateway_id: config.value}
    else
      render json: {status: 'error', reason: 'Gateway ID do not exists.'}
    end
  end

  private

  def validate_rule_existence
    rule_params = params[:data_carrier_rule]
    if rule_params.present?
      DataCarrierRule.where(gateway_id: rule_params[:gateway_id], 
                            entryway_provider_id: rule_params[:entryway_provider_id],
                            parent_carrier_id: rule_params[:parent_carrier_id])
    end
  end 

  def set_var
    config = GlobalSetting.find_by_name('default_prompt_list_handler')
    gateway = DataGateway.find_by_id(config.value) if config.present?
    @promptlists = gateway.present? ? gateway.data_gateway_prompts : []
    @prompt_handler_gateway_id = gateway.id if gateway.present?
    @rule = DataCarrierRule.new
    @prompt = DataGatewayPrompt.new(params[:data_gateway_prompt])
    @carrier = DataParentCarrier.new(params[:data_parent_carrier])
    @gateways = DataGateway.select([:id, :title]).order('title')
    @providers = DataEntrywayProvider.select([:id, :title]).order('title')
    mapping_rules = ReachoutTabMappingRule.select([:entryway_provider]).group('entryway_provider').map{|x| "'" + x.entryway_provider + "'"}
    @reroute_clec = @providers.where("title IN (#{mapping_rules.join(',')})")
    @carriers = DataParentCarrier.select([:id, :title]).order('title')
    rules = DataCarrierRule.order('created_at DESC')
    if params[:q].present?
      gateway_ids = @gateways.where("TRIM(LOWER(title)) LIKE '%#{params[:q].downcase.strip}%'").collect(&:id)
      provider_ids = @providers.where("TRIM(LOWER(title)) LIKE '%#{params[:q].downcase.strip}%'").collect(&:id)
      carrier_ids = @carriers.where("TRIM(LOWER(title)) LIKE '%#{params[:q].downcase.strip}%'").collect(&:id)
      rules = rules.where(gateway_id: gateway_ids) if gateway_ids.present?
      rules = rules.where(entryway_provider_id: provider_ids) if provider_ids.present?
      rules = rules.where(parent_carrier_id: carrier_ids) if carrier_ids.present?
    end 
    @rules = Kaminari.paginate_array(rules).page(params[:page]).per(16)
  end

end
