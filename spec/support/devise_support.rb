module ValidUserRequestHelper
  def sign_in_as_a_valid_user(user = nil)
    @user ||= user || create(:user)
    post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
  end

  def sign_out
    delete destroy_user_session_path
  end
end

RSpec.configure do |config|
    config.include ValidUserRequestHelper, :type => :request
end