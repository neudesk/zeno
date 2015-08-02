class TrackingUsersController < ApplicationController
  before_filter :authenticate_user!

  def index
     @activity_query = params[:activity_query]
     @activity_type = params[:activity_type]
     where = ''
     if @activity_query
       
       where = "(trackable_title LIKE '%#{@activity_query}%' OR user_title LIKE '%#{@activity_query}%' OR sec_trackable_title LIKE '#{@activity_query}%')"
     end
     unless @activity_type.blank?
       unless where.blank?
          where += ' AND '
       end
       case @activity_type
          when 'Login'
            where += "trackable_type LIKE 'User%' AND `key` LIKE 'user.login'"
          when 'Users Account'
            where += "trackable_type LIKE 'User%' AND `key` NOT LIKE 'user.login%'"
          when 'Content'
            where += "trackable_type LIKE 'DataContent' AND `key` NOT LIKE 'data_content.media_type'"
          when 'Gateway'
            where += "(trackable_type LIKE 'DataGateway' OR trackable_type LIKE 'DataGatewayConference')"
          when 'Data Groups'
            where += "trackable_type LIKE 'DataGateway' OR trackable_type LIKE 'DataEntryway' AND `key` LIKE 'data_gateway.data_group'"
          when 'Data Taggings'
            where += "trackable_type LIKE 'DataGateway' OR trackable_type LIKE 'DataEntryway' AND `key` LIKE 'data_gateway.data_tagging'"
          when 'Media Types'
            where += "trackable_type LIKE 'DataContent' AND `key` LIKE 'data_content.media_type'"
          end
     end
     if where.blank?
        @activities = PublicActivity::Activity.order("created_at desc").page(params[:page]).per(10)
     else
       @activities = PublicActivity::Activity.where(where).order("created_at desc").page(params[:page]).per(10)
     end

  end
end
