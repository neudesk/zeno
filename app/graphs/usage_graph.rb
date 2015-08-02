class UsageGraph
  def initialize(user)
    @user = user
  end

  def total_users
    NowSession.where(call_gateway_id: @user.stations.pluck(:id)).compact
  end

  def phone_users
    @user.get_phone_listeners
  end

  def widget_users
    @user.get_widget_listeners
  end

  def app_users
    @user.get_app_listeners
  end

  def percent_of(n, x)
    return 0 if n == 0 || x == 0
    (n.to_f / x.to_f * 100.0)
  end

  def usage_percent
    return nil if @user.stations.nil?
    phone_percent = percent_of(phone_users.length, total_users.length)
    widget_percent = percent_of(widget_users.first, total_users.length)
    app_percent = percent_of(app_users.length, total_users.length)
    num_phone_users = phone_users.length
    num_widget_users = widget_users.length
    num_app_users = app_users.length

    {phone_percent: phone_percent,
     app_percent: app_percent,
     widget_percent: widget_percent,
     total_users: num_phone_users.to_i + num_widget_users.to_i + num_app_users.to_i,
     num_phone_users: num_phone_users,
     num_widget_users: num_widget_users,
     num_app_users: num_app_users
    }
  end
end