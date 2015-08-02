class SessionsController < Devise::SessionsController
  def create
    user = User.find_by_email(params[:user][:email])
    if user and !user.enabled
      sign_out
      redirect_to '/403.html'
    else
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
      session_activity = current_user.create_activity key: 'user.login', owner: current_user, user_title: user_title, trackable_title: user_title
      session[:session_activity_id] = session_activity.id
    end
  end

end