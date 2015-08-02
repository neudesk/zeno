class SearchController < ApplicationController
  before_filter :authenticate_user!
  before_filter :restrict_to_admin_rca_only
  
  def content_search
    @content_query = params[:content_query]
    # query = "%#{@content_query}%"
    # @contents = DataContent.where("title LIKE ? OR media_url LIKE ? OR backup_media_url LIKE ?", query, query, query).page(params[:page]).per(10) if @content_query.present?
    # @gateway_ids = current_user.stations.collect(&:id)
    @contents = get_content if @content_query
    # render json: get_content
  end

  def get_content
    query = params[:content_query].to_s.downcase.strip
    where = ""
    where += " AND (TRIM(LOWER(dc.title)) LIKE '%#{query}%' OR TRIM(LOWER(dc.media_url)) LIKE '%#{query}%' OR TRIM(LOWER(dc.backup_media_url)) LIKE '%#{query}%') " if query.present?
    sql = "
    SELECT
      dc.id id,
      dc.title,
      dc.media_url,
      dc.backup_media_url,
      group_concat(dgc.gateway_id) gateways,
      group_concat(dgc.extension) extension
    FROM data_gateway_conference as dgc
      LEFT JOIN data_content as dc on dc.id = dgc.content_id
      WHERE dgc.gateway_id IN (#{current_user.stations.collect(&:id).join(', ')}) #{where}
    group by dc.id order by dc.title
    "
    ActiveRecord::Base.connection.execute(sql).to_a
  end

end
