class MappingRulesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_user
  
  def index
    @mapping_rule = ReachoutTabMappingRule.all
  end

  def save
    rule =  ReachoutTabMappingRule.where(:carrier_title => params[:selected_ani_carrier_ids], :entryway_provider => params[:selected_entry_ids])
    
    if rule.present?
      redirect_to :back, :alert => "Mapping rule already exists."
    else
      if params[:selected_ani_carrier_ids] == "ALL OTHER CARRIER"
        @reachout_tab_listener_minutes_by_gateway = ReachoutTabListenerMinutesByGateway.where("carrier_title IS NOT NULL").select(:carrier_title).order(:carrier_title).uniq
        rule = []
        @reachout_tab_listener_minutes_by_gateway.each do |r|
          rule << "('#{r.carrier_title}', '#{params[:selected_entry_ids]}', '#{Time.now.to_s(:db)}')"
        end
        ReachoutTabMappingRule.delete_all(:entryway_provider => params[:selected_entry_ids])
        sql = "INSERT INTO reachout_tab_mapping_rule(carrier_title, entryway_provider, created_at) Values #{rule.join(',')}"
        ActiveRecord::Base.connection.execute(sql)
      else
        ReachoutTabMappingRule.create(:carrier_title => params[:selected_ani_carrier_ids], :entryway_provider => params[:selected_entry_ids])
      end
      redirect_to :back, :notice => "Mapping rule saved."
    end
    return
  end
  
  def delete
    if params[:did].present?
       ReachoutTabMappingRule.delete_all(:entryway_provider => params[:did])
       redirect_to :back, :notice => "All mapping rules assigned to '#{params[:did]}' DID's provider was deleted."
    else
      if ReachoutTabMappingRule.find(params[:id]).destroy
        redirect_to :back, :notice => "Mapping rule has been deleted."
      end
    end
    return
  end
  
  protected
  def validate_user
    # TODO Check if Reachout Tab is enabled for current BRD
    if current_user.is_broadcaster? || current_user.is_rca? 
      redirect_to root_path 
    end
  end
end
