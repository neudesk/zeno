When /^I log in with email "(.*?)" and password "(.*?)"$/ do |email, password|
  with_scope(".login-section") do
    fill_in("user[email]", :with => email)
    fill_in("user[password]", :with => password)
  end
  find(".submit-btn").click
  @current_user = User.find_by_email(email)
end

