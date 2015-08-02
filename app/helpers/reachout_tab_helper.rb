module ReachoutTabHelper
  def reachout_tab_is_active
    # TODO Check if Reachout Tab is enabled for current BRD
    if current_user.is_broadcaster? 
      is_active = DataGroupBroadcast.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_broadcast.reachout_tab_is_active")
      is_active = is_active[0].present? ? is_active[0].reachout_tab_is_active : false
    elsif current_user.is_rca? 
      is_active = DataGroupRca.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_rca.reachout_tab_is_active")
      is_active = is_active[0].present? ? is_active[0].reachout_tab_is_active : false
    end
    current_user.is_marketer? || (current_user.is_broadcaster? && is_active) || (current_user.is_rca? && is_active)
  end
  
  def reachout_tab_is_active_rca
    # TODO Check if Reachout Tab is enabled for current BRD
    if current_user.is_rca? 
      is_active = DataGroupRca.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_rca.reachout_tab_is_active")
      is_active = is_active[0].present? ? is_active[0].reachout_tab_is_active : false
    end
    current_user.is_marketer?  || (current_user.is_rca? && is_active)
  end
  
  def upload_list_is_active
    # TODO Check if Reachout Tab is enabled for current BRD
    if current_user.is_broadcaster? 
      is_active = DataGroupBroadcast.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_broadcast.upload_list_is_active")
      is_active = is_active[0].present? ? is_active[0].upload_list_is_active : false
    elsif current_user.is_rca? 
      is_active = DataGroupRca.joins(:sys_users).where("sys_user.id=?",current_user.id).select("data_group_rca.upload_list_is_active")
      is_active = is_active[0].present? ? is_active[0].upload_list_is_active : false
    end
    current_user.is_marketer? || (current_user.is_broadcaster? && is_active) || (current_user.is_rca? && is_active)
  end
end

