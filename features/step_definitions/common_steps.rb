require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))


module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

Given(/^I had an admin account$/) do
  if !SysUserPermission.exists?(:is_super_user => true)
    admin_permission = SysUserPermission.create({
      title: "Super Admin",
      is_super_user: true
    })
  end

  if !User.exists?(:email => 'admin@zenoradio.com')
    admin = User.create({
      title: "Admin",
      email: "admin@zenoradio.com",
      password: "1234qwer",
      permission_id: admin_permission.id,
      password_confirmation: "1234qwer",
      enabled: true
    })
  end
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end


Then(/^I should see "(.*?)" button$/) do |content|
  page.should have_css(".btn")
  page.should have_content(content)
end

#Wanna sleep to wait for loading
Then /^I wanna sleep "([^"]*)" seconds$/ do |arg1|
  sleep arg1.to_i
end