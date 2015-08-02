World(ApplicationHelper)
World(ActionView::Helpers::NumberHelper)

module NavigationHelpers
  def path_to(page_name)
    case page_name
      when /home page/ then
        root_path
      when /login page/ then
        new_user_session_path
    end
  end
end

World(NavigationHelpers)
