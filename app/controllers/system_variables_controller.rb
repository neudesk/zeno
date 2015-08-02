class SystemVariablesController < ApplicationController

  def index
    @config = SysConfig.find_by_group_and_name("UI_CONFIG", "EMAIL")
  end

  def save
    @config = SysConfig.find_by_group_and_name("UI_CONFIG", "EMAIL")
    if params[:sys_config][:value].present?
      SysConfig.where(group: "UI_CONFIG", name: "EMAIL").update_all(value: params[:sys_config][:value])
      redirect_to system_variables_path, notice: "You have successfully updated email content."
    else
      @config.update_attributes(value: nil)
      render :index
    end
  end

  def update_email
    @email_config_form = EmailConfigForm.new(params[:email_config_form])
    if @email_config_form.valid?
      SysConfig.add_config(
        "UI_CONFIG",
        "EMAIL",
        @email_config_form.email)

      flash[:notice] = "Saved successfully"
    else
      flash[:error] = "Invalid inputed email"
    end
    
    redirect_to system_variables_path
  end

  
end
