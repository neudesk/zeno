class NewCampaignController < ApplicationController
	before_filter :authenticate_user!
	before_filter :validate_user

	def index
		render json: params
	end

	protected
	def validate_user
	  if current_user.is_rca?
	    is_active = DataGroupRca.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_rca.reachout_tab_is_active")
	    is_active = is_active[0].present? ? is_active[0].reachout_tab_is_active : false
	    redirect_to root_path if !is_active
	  elsif current_user.is_broadcaster?
	    is_active = DataGroupBroadcast.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_broadcast.reachout_tab_is_active")
	    is_active = is_active[0].present? ? is_active[0].reachout_tab_is_active : false
	    redirect_to root_path if !is_active
	  end
	end
end
