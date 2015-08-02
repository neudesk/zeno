module SignInHelpers
  def sign_in_as_admin
    user = create(:user)
    user.add_role Role::ROLES[:admin]
    post user_session_path, :'user[email]' => user.email, :'user[password]' => user.password
    user
  end
end

