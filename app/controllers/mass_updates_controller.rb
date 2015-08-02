class MassUpdatesController < ApplicationController
  before_filter :authenticate_user!

  def data_groups
    case params[:group]
    when "RCA"
      @groups = DataGroupRca.all
      @objects = DataGateway.all
    when "BroadCaster"
      @groups = DataGroupBroadcast.all
      @objects = DataGateway.all
    when "ThirdParty"
      @groups = DataGroup3rdparty.all
      @objects = DataEntryway.all
    end
    if params[:country_id].present?
      @country = DataGroupCountry.find_by_id(params[:country_id])
    else
      @country = DataGroupCountry.where(iso_alpha_3: "USA").first
    end
  end

  def data_group_objects
    @group_class = params[:group_class]
    case @group_class
    when "DataGroupRca"
      @group = DataGroupRca.find_by_id(params[:group_id])
      if params[:country_id].present?
        @objects = DataGateway.where(country_id: params[:country_id]).order("title")
      else
        @objects = DataGateway.order("title")
      end
      @selected = @group.gateways.collect(&:id)
    when "DataGroupBroadcast"
      @group = DataGroupBroadcast.find_by_id(params[:group_id])
      if params[:country_id].present?
        @objects = DataGateway.where(country_id: params[:country_id]).order("title")
      else
        @objects = DataGateway.all.order("title")
      end
      @selected = @group.gateways.collect(&:id)
    when "DataGroup3rdparty"
      @group = DataGroup3rdparty.find_by_id(params[:group_id])
      if params[:country_id].present?
        @objects = DataEntryway.where(country_id: params[:country_id]).order("title")
      else
        @objects = DataEntryway.all.order("title")
      end
      @selected = @group.entryways.collect(&:id)
    end
    @selector = "#group_#{@group.id}"
  end

  def save_data_groups
    case params[:group_class]
    when "DataGroup3rdparty"
      @group = DataGroup3rdparty.find_by_id(params[:group_id])
      @group.refresh_entryways(params[:data_groups])
    when "DataGroupBroadcast"
      @group = DataGroupBroadcast.find_by_id(params[:group_id])
      @group.refresh_gateways(params[:data_groups])
    else
      @group = DataGroupRca.find_by_id(params[:group_id])
      @group.refresh_gateways(params[:data_groups])
    end
    flash[:notice] = "You have successfully updated the data groups."
  end

  def data_tags
    @tag = params[:tag]
    case @tag
    when "Country"
      @objects = DataGroupCountry.order("title")
    when "Language"
      @objects = DataGroupLanguage.order("title")
    when "Genre"
      @objects = DataGroupGenre.order("title")
    end
  end

  def data_tag_objects
    case params[:object_class]
    when "DataGroupCountry"
      @object = DataGroupCountry.find_by_id(params[:object_id])
      @objects = DataGateway.order("title")
      @selected = @object.gateways.collect(&:id)
    when "DataGroupLanguage"
      @object = DataGroupLanguage.find_by_id(params[:object_id])
      @objects = DataContent.order("title")
      @selected = @object.contents.collect(&:id)
    when "DataGroupGenre"
      @object = DataGroupGenre.find_by_id(params[:object_id])
      @objects = DataContent.order("title")
      @selected = @object.contents.collect(&:id)
    end
    @selector = "#object_#{@object.id}"
  end

  def save_data_tags
    case params[:object_class]
    when "DataGroupCountry"
      @object = DataGroupCountry.find_by_id(params[:object_id])
      @object.refresh_gateways(params[:data_tags])
    when "DataGroupLanguage"
      @object = DataGroupLanguage.find_by_id(params[:object_id])
      @object.refresh_contents(params[:data_tags])
    when "DataGroupGenre"
      @object = DataGroupGenre.find_by_id(params[:object_id])
      @object.refresh_contents(params[:data_tags])
    end
    flash[:notice] = "You have successfully updated the tags."
  end
end