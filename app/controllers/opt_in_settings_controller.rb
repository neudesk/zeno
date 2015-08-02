class OptInSettingsController < ApplicationController
  before_filter :authenticate_user!
  require 'csv'


  def index
    @opt_in_list_length = OptInList.all.length
    @opt_in_list = OptInList.last(30)
    if params[:type] == "rca" || !params[:type].present?
      if params[:search].present?
        rca = DataGroupRca.where("data_group_rca.is_deleted = false and data_group_rca.title LIKE '#{params[:search]}%'").order(:title)        
      else
        rca = DataGroupRca.where(:is_deleted => false).order(:title)
      end
      @rca = rca.page params[:page]
      @page_no = Kaminari.paginate_array([], total_count: rca.length).page(params[:page]).per(25) 
    elsif params[:type] == "brd"
      if params[:search].present?
        broadcasters = DataGroupBroadcast.where("data_group_broadcast.is_deleted = false and data_group_broadcast.title LIKE '#{params[:search]}%'").order(:title)        
      else
        broadcasters = DataGroupBroadcast.where(:is_deleted => false).order(:title)
      end
      @broadcasters = broadcasters.page params[:page]
      @page_no = Kaminari.paginate_array([], total_count: broadcasters.length).page(params[:page]).per(25)
    end

  end

  def activate_brd
    id = params[:id]
    brd = DataGroupBroadcast.find(id)
    status = params[:status]
    success = brd.update_attribute(:opt_in_is_active, status)
    if success
      render :json =>{:message => "Succes",:brd => brd}
    else
      render :json =>{:message => "Error"}
    end
  end

  def upload_opt_in_file
    if params[:upload].present?
      accepted_formats = [".csv"]
      filename = params[:upload]['datafile'].original_filename
      folder_path = "public/"

      File.open(Rails.root.join("#{folder_path}",filename),'w+b') do |f| 
        f.write(params[:upload]['datafile'].read)
      end

      if accepted_formats.include? File.extname(Rails.root.join("#{folder_path}",filename))
        file_data = CSV.read(Rails.root.join("#{folder_path}",filename))
        result = []
        file_data_result = []
        file_data.each do |data|
          if data[0].to_s.match(/^\d+$/) && (data[0].length == 10 || data[0].length == 11)
            if data[0].length == 10
              file_data_result << ("1" + data[0].to_s)
            elsif data[0].length == 11
             file_data_result << data[0].to_s
           end
         end
       end
       opt_in_list = OptInList.all.map{|x| x.ani_e164.to_s}

       file_data_result = file_data_result - opt_in_list

       file_data_result.each do |data|
        result << "(" + data.to_s + ",' #{Time.now.to_s(:db)}')"
      end

      if result.present?
       sql = "INSERT into opt_in_list(ani_e164, created_at) VALUES #{result.join(',')}"
       ActiveRecord::Base.connection.execute(sql)
     end
   end

   File.delete(Rails.root.join("#{folder_path}",filename))
   redirect_to :back, :notice => "File uploaded"
 else
  redirect_to :back, :alert => "Please add a csv file."
end
end

def search_phone
  phone_number = params[:phone_number]
  opt_in_list = OptInList.where("ani_e164 LIKE '%#{phone_number}%'").first(3000)
  render :json => {:opt_in_list => opt_in_list}
end

def activate_rca
  id = params[:id]
  rca = DataGroupRca.find(id)
  status = params[:status]
  success = rca.update_attribute(:opt_in_is_active, status)
  if success
    render :json =>{:message => "Succes",:rca => rca}
  else
    render :json =>{:message => "Error"}
  end
end

def add_phone_opt_in
  phone_number = params[:phone_number]
  if !OptInList.find_by_ani_e164(phone_number).present?
    opt_in_list = OptInList.new(:ani_e164 => phone_number)

    if opt_in_list.save 
      opt_in_list_length = OptInList.all.length
      render :json => {:message => "Succes",:id => opt_in_list.id, :opt_in_list_length => opt_in_list_length }
    else
      render :json => {:message => "Bad format" }
    end
  else
    render :json =>  {:message => "Phone number already exists." }
  end
end

def delete_phone_opt_in
  id = params[:id]
  if OptInList.find(id).destroy
    opt_in_list_length = OptInList.all.length
    render :json => {:message =>"Succes",:opt_in_list_length => opt_in_list_length}
  else
    render :json => {:message => "Error" }
  end
end

def destroy_uploaded_phones
 OptInList.delete_all()
 redirect_to :back
end

protected
def validate_user
  if !current_user.is_marketer? 
    redirect_to root_path
  end
end
end
